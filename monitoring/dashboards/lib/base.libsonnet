# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';

local a = import 'aliases.libsonnet';



local makeQuery( query, queryLegend ) =
	grafonnet.query.prometheus.new( 'Prometheus', query )
	+ grafonnet.query.prometheus.withLegendFormat( queryLegend );



{
	local panel( type, title, width, height ) =
		grafonnet.panel[type].new( title )
		+ a.width( width )
		+ a.height( height ),
	
	
	row( title ):
		panel( 'row', title, 24, 1 ),
	
	
	text( title, text ):
		panel( 'text', title, 24, 3 )
		+ grafonnet.panel.text.options.withContent( text ),
	
	
	gauge( title ):
		panel( 'gauge', title, 6, 4 ),
	
	
	stat( title ):
		panel( 'stat', title, 6, 4 ),
	
	
	timeSeries( title, description, query, queryLegend, unity ):
		panel( 'timeSeries', title, 12, 8 )
		+ a.description( description )
		+ a.targets( [ makeQuery( query, queryLegend ) ] )
		+ a.unit( unity )
		+ a.min( 0 )
		+ a.fillOpacity( 25 )
		+ a.showPoints( 'never' ),
	
	
	logs( title ):
		panel( 'logs', title, 6, 4 ),
	
	
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