# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local promql = import 'github.com/satyanash/promql-jsonnet/promql.libsonnet';
local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';
local dashboard = grafonnet.dashboard;
local timeSeries = grafonnet.panel.timeSeries;
local prometheus = grafonnet.query.prometheus;
local withUnit = timeSeries.standardOptions.withUnit;



# 
# Base Definitions
#---------------------------------------------------------------------------------------------------
local baseTimeSeries( title, x, y ) = timeSeries.new( title ) {
		gridPos: {
			w: 12,
			h: 8,
			x: x,
			y: y,
		},
	}
	+ timeSeries.standardOptions.withMin( 0 )
	+ timeSeries.fieldConfig.defaults.custom.withFillOpacity( 25 )
	+ timeSeries.fieldConfig.defaults.custom.withShowPoints( 'never' );

local withThreshold( theshold ) = timeSeries.fieldConfig.defaults.custom.withGradientMode( 'scheme' )
	+ timeSeries.standardOptions.color.withMode( 'thresholds' )
	+ timeSeries.standardOptions.color.withSeriesBy( 'min' )
	+ timeSeries.standardOptions.thresholds.withSteps( [
		{
			color: 'green',
			value: null,
		},
		{
			color: 'red',
			value: theshold,
		},
	] );

local withQuery( legend, query ) = timeSeries.queryOptions.withTargets( [
	prometheus.new(
		'Prometheus',
		query,
	)
	+ prometheus.withLegendFormat( legend ),
] );



# 
# Traffic Panel
#---------------------------------------------------------------------------------------------------
local trafficQuery = promql.new( 'traefik_service_requests_total' )
	.withLabels( { service: 'application@file' } )
	.rate( [ '$__rate_interval', '$__interval' ] )
	.sum()
	.build();

local trafficPanel = baseTimeSeries( 'Traffic', 0, 0 )
	+ timeSeries.panelOptions.withDescription( '' )
	+ withQuery( 'Traefik', trafficQuery )
	+ timeSeries.standardOptions.withNoValue( '0' )
	+ withUnit( 'reqps' );



# 
# Saturation Panel
#---------------------------------------------------------------------------------------------------
local cpuLoadQuery = promql.new( 'node_cpu_seconds_total' )
	.withLabels( {
		instance: 'VAZ Projects Application Server',
		mode: 'idle',
	} )
	.rate( [ '$__rate_interval', '$__interval' ] )
	.sum();

local cpuCoreCountQuery = promql.new( 'machine_cpu_cores' )
	.withLabels( { instance: 'VAZ Projects Application Server' } )
	.sum();

local saturationQuery = '1 - %s / %s' % [ cpuLoadQuery.build(), cpuCoreCountQuery.build() ];

local saturationPanel = baseTimeSeries( 'Saturation', 12, 0 )
	+ timeSeries.panelOptions.withDescription( '' )
	+ withQuery( 'Application Server', saturationQuery )
	+ withThreshold( 0.70 )
	+ timeSeries.fieldConfig.defaults.custom.withAxisSoftMax( 1.00 )
	+ timeSeries.fieldConfig.defaults.custom.withAxisLabel( 'CPU Load' )
	+ withUnit( 'percentunit' );



# 
# Latency Panel
#---------------------------------------------------------------------------------------------------
local latencyQuery = promql.new( 'traefik_service_request_duration_seconds_bucket' )
	.withLabels( { service: 'application@file' } )
	.rate( [ '$__rate_interval', '$__interval' ] )
	.sum( by = [ 'le' ] )
	.histogram_quantile( 0.95 )
	.build();

local latencyPanel = baseTimeSeries( 'Latency (95th percentile)', 0, 8 )
	+ timeSeries.panelOptions.withDescription( '' )
	+ withQuery( '2xx', latencyQuery )
	+ withThreshold( 0.5 )
	+ withUnit( 's' );



# 
# Error Rate Panel
#---------------------------------------------------------------------------------------------------
local allRequestsQuery = promql.new( 'traefik_service_requests_total' )
	.withLabels( { service: 'application@file' } )
	.rate( [ '$__rate_interval', '$__interval' ] )
	.sum();

local errorRequestsQuery = allRequestsQuery
	.withLabel( {
		key: 'code',
		op: '=~',
		value: '5..'
	} );

local errorRateQuery = '%s / %s or vector( 0 )' % [ errorRequestsQuery.build(), allRequestsQuery.build() ];

local errorRatePanel = baseTimeSeries( 'Error Rate', 12, 8 )
	+ timeSeries.panelOptions.withDescription( '' )
	+ withQuery( 'Traefik', errorRateQuery )
	+ withThreshold( 0.01 )
	+ withUnit( 'percentunit' )
	+ timeSeries.fieldConfig.defaults.custom.withAxisSoftMax( 0.05 );



# 
# Dashboard
#---------------------------------------------------------------------------------------------------
dashboard.new( 'Application Overview' ) {
		description: 'High level metrics for monitoring application health and performance.',
		tags: [
			'Monitoring'
		],
		editable: false,
		timezone: '',
	}
	+ dashboard.timepicker.withRefreshIntervals( [
		'15s',
		'30s',
		'1m',
		'5m',
	] )
	+ dashboard.graphTooltip.withSharedCrosshair()
	+ dashboard.withPanels( [
		trafficPanel,
		saturationPanel,
		latencyPanel,
		errorRatePanel,
	] )