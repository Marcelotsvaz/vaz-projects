# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';
local timeSeries = grafonnet.panel.timeSeries;
local prometheus = grafonnet.query.prometheus;



# 
# Base Definitions
#---------------------------------------------------------------------------------------------------
{
	baseTimeSeries( title, x, y )::
		timeSeries.new( title ) {
			gridPos: {
				w: 12,
				h: 8,
				x: x,
				y: y,
			},
		}
		+ timeSeries.standardOptions.withMin( 0 )
		+ timeSeries.fieldConfig.defaults.custom.withFillOpacity( 25 )
		+ timeSeries.fieldConfig.defaults.custom.withShowPoints( 'never' ),
	
	
	withThreshold( theshold )::
		timeSeries.fieldConfig.defaults.custom.withGradientMode( 'scheme' )
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
		] ),
	
	
	withQuery( legend, query )::
		local target = prometheus.new( 'Prometheus', query )
		+ prometheus.withLegendFormat( legend );
		
		timeSeries.queryOptions.withTargets( [ target ] ),
}