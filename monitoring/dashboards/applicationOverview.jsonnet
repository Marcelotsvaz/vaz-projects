# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local dashboard = import 'lib/dashboard.libsonnet';
local panel = import 'lib/panel.libsonnet';
local query = import 'lib/query.libsonnet';



# 
# Queries
#---------------------------------------------------------------------------------------------------
# Traffic.
local trafficExpression =
	query.expression.promql( 'traefik_service_requests_total' )
	.withLabels( { service: 'application@file' } )
	.rate()
	.sum();

local trafficQuery = query.prometheus( 'Prometheus', trafficExpression ).legend( 'Traefik' );


# Saturation.
local cpuLoadExpression =
	query.expression.promql( 'node_cpu_seconds_total' )
	.withLabels( {
		instance: 'VAZ Projects Application Server',
		mode: 'idle',
	} )
	.rate()
	.sum();

local cpuCoreCountExpression =
	query.expression.promql( 'machine_cpu_cores' )
	.withLabels( { instance: 'VAZ Projects Application Server' } )
	.sum();

local saturationExpression = cpuLoadExpression.op( '/', cpuCoreCountExpression.build() ).opL( 1, '-' );
local saturationQuery = query.prometheus( 'Prometheus', saturationExpression ).legend( 'Application Server' );


# Latency.
local latencyExpression =
	query.expression.promql( 'traefik_service_request_duration_seconds_bucket' )
	.withLabels( { service: 'application@file' } )
	.rate()
	.sum( by = [ 'le' ] )
	.histogramQuantile( 0.95 );

local latencyQuery = query.prometheus( 'Prometheus', latencyExpression ).legend( '2xx' );


# Error Rate.
local allRequestsExpression =
	query.expression.promql( 'traefik_service_requests_total' )
	.withLabels( { service: 'application@file' } )
	.rate()
	.sum();

local errorRequestsExpression =
	allRequestsExpression
	.withLabel( {
		key: 'code',
		op: '=~',
		value: '5..'
	} );

local errorRateExpression =
	errorRequestsExpression
	.op( '/', allRequestsExpression.build() )
	.op( 'or', 'vector( 0 )' );

local errorRateQuery = query.prometheus( 'Prometheus', errorRateExpression ).legend( 'Traefik' );


# Request distribution.
local requestsExpression =
	query.expression.promql( 'traefik_service_requests_total' )
	.withLabels( { service: 'application@file' } )
	.increase( '$__range' );

local requestDistributionExpression =
	requestsExpression
	.sum( by = [ 'code' ] )
	.op( '/ on() group_left', requestsExpression.sum().build() )
	.op( '>', 0 );

local requestDistributionQuery = query.prometheusInstant( 'Prometheus', requestDistributionExpression );



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


local requestDistributionPanel = panel.pieChart(
		title = 'Request Status',
		description = '',
		query = requestDistributionQuery,
	);



# 
# Dashboard
#---------------------------------------------------------------------------------------------------
local mainDashboard = dashboard.default(
		name = 'Application Overview',
		description = 'High level metrics for monitoring application health and performance.',
	)
	.tags( [ 'Monitoring' ] )
	.panels( [
		[ trafficPanel, saturationPanel ],
		[ latencyPanel, errorRatePanel ],
		[ requestDistributionPanel ],
	] );


mainDashboard.build()