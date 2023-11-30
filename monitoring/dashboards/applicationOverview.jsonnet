# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local promql = import 'github.com/satyanash/promql-jsonnet/promql.libsonnet';
local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';

local base = import 'lib/base.libsonnet';
local util = import 'lib/util.libsonnet';
local a = import 'lib/aliases.libsonnet';

local dashboard = grafonnet.dashboard;



# 
# Queries
#---------------------------------------------------------------------------------------------------
# Traffic.
local trafficQuery = promql.new( 'traefik_service_requests_total' )
	.withLabels( { service: 'application@file' } )
	.rate( [ '$__rate_interval', '$__interval' ] )
	.sum()
	.build();


# Saturation.
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


# Latency.
local latencyQuery = promql.new( 'traefik_service_request_duration_seconds_bucket' )
	.withLabels( { service: 'application@file' } )
	.rate( [ '$__rate_interval', '$__interval' ] )
	.sum( by = [ 'le' ] )
	.histogram_quantile( 0.95 )
	.build();


# Error Rate.
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



# 
# Panels
#---------------------------------------------------------------------------------------------------
local trafficPanel = base.timeSeries(
		title = 'Traffic',
		description = '',
		query = trafficQuery,
		queryLegend = 'Traefik',
		unity = 'reqps',
	)
	+ a.noValue( '0' );


local saturationPanel = base.timeSeries(
		title = 'Saturation',
		description = '',
		query = saturationQuery,
		queryLegend = 'Application Server',
		unity = 'percentunit',
	)
	+ base.threshold( 0.70 )
	+ a.softMax( 1.00 )
	+ a.axisLabel( 'CPU Load' );


local latencyPanel = base.timeSeries(
		title = 'Latency (95th percentile)',
		description = '',
		query = latencyQuery,
		queryLegend = '2xx',
		unity = 's',
	)
	+ base.threshold( 0.5 );


local errorRatePanel = base.timeSeries(
		title = 'Error Rate',
		description = '',
		query = errorRateQuery,
		queryLegend = 'Traefik',
		unity = 'percentunit',
	)
	+ base.threshold( 0.01 )
	+ a.softMax( 0.05 );



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