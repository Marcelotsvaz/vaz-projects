# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';

local a = import 'aliases.libsonnet';

local timeSeries = grafonnet.panel.timeSeries;
local prometheus = grafonnet.query.prometheus;



{
	timeSeries( title, x, y ):
		timeSeries.new( title ) {
			gridPos: {
				w: 12,
				h: 8,
				x: x,
				y: y,
			},
		}
		+ a.min( 0 )
		+ a.fillOpacity( 25 )
		+ a.showPoints( 'never' ),
	
	
	threshold( theshold ):
		a.gradientMode( 'scheme' )
		+ a.colorScheme( 'thresholds' )
		+ a.colorSeriesBy( 'min' )
		+ a.steps( [
			{
				color: 'green',
				value: null,
			},
			{
				color: 'red',
				value: theshold,
			},
		] ),
	
	
	query( legend, query ):
		local target = prometheus.new( 'Prometheus', query )
		+ prometheus.withLegendFormat( legend );
		
		timeSeries.queryOptions.withTargets( [ target ] ),
}