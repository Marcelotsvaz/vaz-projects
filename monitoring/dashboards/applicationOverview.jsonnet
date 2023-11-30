# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local promql = import 'github.com/satyanash/promql-jsonnet/promql.libsonnet';
local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';

local a = import 'aliases.libsonnet';
local base = import 'base.libsonnet';

local dashboard = grafonnet.dashboard;



# 
# Traffic Panel
#---------------------------------------------------------------------------------------------------
local trafficQuery = promql.new( 'traefik_service_requests_total' )
	.withLabels( { service: 'application@file' } )
	.rate( [ '$__rate_interval', '$__interval' ] )
	.sum()
	.build();

local trafficPanel = base.timeSeries( 'Traffic', 0, 0 )
	+ a.description( '' )
	+ base.query( 'Traefik', trafficQuery )
	+ a.noValue( '0' )
	+ a.unit( 'reqps' );



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

local saturationPanel = base.timeSeries( 'Saturation', 12, 0 )
	+ a.description( '' )
	+ base.query( 'Application Server', saturationQuery )
	+ base.threshold( 0.70 )
	+ a.softMax( 1.00 )
	+ a.axisLabel( 'CPU Load' )
	+ a.unit( 'percentunit' );



# 
# Latency Panel
#---------------------------------------------------------------------------------------------------
local latencyQuery = promql.new( 'traefik_service_request_duration_seconds_bucket' )
	.withLabels( { service: 'application@file' } )
	.rate( [ '$__rate_interval', '$__interval' ] )
	.sum( by = [ 'le' ] )
	.histogram_quantile( 0.95 )
	.build();

local latencyPanel = base.timeSeries( 'Latency (95th percentile)', 0, 8 )
	+ a.description( '' )
	+ base.query( '2xx', latencyQuery )
	+ base.threshold( 0.5 )
	+ a.unit( 's' );



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

local errorRatePanel = base.timeSeries( 'Error Rate', 12, 8 )
	+ a.description( '' )
	+ base.query( 'Traefik', errorRateQuery )
	+ base.threshold( 0.01 )
	+ a.unit( 'percentunit' )
	+ a.softMax( 0.05 );



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