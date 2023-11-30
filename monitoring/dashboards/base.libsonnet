# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';

local a = import 'aliases.libsonnet';

local timeSeries = grafonnet.panel.timeSeries;
local prometheus = grafonnet.query.prometheus;



local makeQuery( query, queryLegend ) =
	prometheus.new( 'Prometheus', query )
	+ prometheus.withLegendFormat( queryLegend );



{
	timeSeries( title, description, query, queryLegend, unity ):
		timeSeries.new( title )
		+ a.width( 12 )
		+ a.height( 8 )
		+ a.description( description )
		+ a.targets( [ makeQuery( query, queryLegend ) ] )
		+ a.unit( unity )
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
}