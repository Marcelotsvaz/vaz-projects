# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local promql = import 'github.com/satyanash/promql-jsonnet/promql.libsonnet';
local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';
local dashboard = grafonnet.dashboard;
local timeSeries = grafonnet.panel.timeSeries;
local withUnit = timeSeries.standardOptions.withUnit;

local base = import 'base.libsonnet';



# 
# Traffic Panel
#---------------------------------------------------------------------------------------------------
local trafficQuery = promql.new( 'traefik_service_requests_total' )
	.withLabels( { service: 'application@file' } )
	.rate( [ '$__rate_interval', '$__interval' ] )
	.sum()
	.build();

local trafficPanel = base.baseTimeSeries( 'Traffic', 0, 0 )
	+ timeSeries.panelOptions.withDescription( '' )
	+ base.withQuery( 'Traefik', trafficQuery )
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

local saturationPanel = base.baseTimeSeries( 'Saturation', 12, 0 )
	+ timeSeries.panelOptions.withDescription( '' )
	+ base.withQuery( 'Application Server', saturationQuery )
	+ base.withThreshold( 0.70 )
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

local latencyPanel = base.baseTimeSeries( 'Latency (95th percentile)', 0, 8 )
	+ timeSeries.panelOptions.withDescription( '' )
	+ base.withQuery( '2xx', latencyQuery )
	+ base.withThreshold( 0.5 )
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

local errorRatePanel = base.baseTimeSeries( 'Error Rate', 12, 8 )
	+ timeSeries.panelOptions.withDescription( '' )
	+ base.withQuery( 'Traefik', errorRateQuery )
	+ base.withThreshold( 0.01 )
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