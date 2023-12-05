# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';

local panel = import 'lib/panel.libsonnet';
local query = import 'lib/query.libsonnet';
local util = import 'lib/util.libsonnet';

local dashboard = grafonnet.dashboard;



# 
# Queries
#---------------------------------------------------------------------------------------------------
# Traffic.
local trafficExpression = query.expression.promql( 'traefik_service_requests_total' )
	.withLabels( { service: 'application@file' } )
	.rate()
	.sum();

local trafficQuery = query.prometheus( 'Prometheus', trafficExpression, 'Traefik' );


# Saturation.
local cpuLoadExpression = query.expression.promql( 'node_cpu_seconds_total' )
	.withLabels( {
		instance: 'VAZ Projects Application Server',
		mode: 'idle',
	} )
	.rate()
	.sum();

local cpuCoreCountExpression = query.expression.promql( 'machine_cpu_cores' )
	.withLabels( { instance: 'VAZ Projects Application Server' } )
	.sum();

local saturationExpression = cpuLoadExpression.op( '/', cpuCoreCountExpression.build() ).opL( 1, '-' );
local saturationQuery = query.prometheus( 'Prometheus', saturationExpression, 'Application Server' );


# Latency.
local latencyExpression = query.expression.promql( 'traefik_service_request_duration_seconds_bucket' )
	.withLabels( { service: 'application@file' } )
	.rate()
	.sum( by = [ 'le' ] )
	.histogramQuantile( 0.95 );

local latencyQuery = query.prometheus( 'Prometheus', latencyExpression, '2xx' );


# Error Rate.
local allRequestsExpression = query.expression.promql( 'traefik_service_requests_total' )
	.withLabels( { service: 'application@file' } )
	.rate()
	.sum();

local errorRequestsExpression = allRequestsExpression
	.withLabel( {
		key: 'code',
		op: '=~',
		value: '5..'
	} );

local errorRateExpression = errorRequestsExpression.op( '/', allRequestsExpression.build() ).op( 'or', 'vector( 0 )' );
local errorRateQuery = query.prometheus( 'Prometheus', errorRateExpression, 'Traefik' );



# 
# Panels
#---------------------------------------------------------------------------------------------------
local trafficPanel = panel.timeSeries(
		title = 'Traffic',
		description = '',
		query = trafficQuery,
		unity = 'reqps',
	)
	.noValue( '0' );


local saturationPanel = panel.timeSeries(
		title = 'Saturation',
		description = '',
		query = saturationQuery,
		unity = 'percentunit',
	)
	.threshold( 0.70 )
	.softMax( 1.00 )
	.axisLabel( 'CPU Load' );


local latencyPanel = panel.timeSeries(
		title = 'Latency (95th percentile)',
		description = '',
		query = latencyQuery,
		unity = 's',
	)
	.threshold( 0.5 );


local errorRatePanel = panel.timeSeries(
		title = 'Error Rate',
		description = '',
		query = errorRateQuery,
		unity = 'percentunit',
	)
	.threshold( 0.01 )
	.softMax( 0.05 );



# 
# Dashboard
#---------------------------------------------------------------------------------------------------
local panels = util.layoutPanels( [
	[ trafficPanel, saturationPanel ],
	[ latencyPanel, errorRatePanel ],
] );

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
	+ dashboard.withPanels( panels )