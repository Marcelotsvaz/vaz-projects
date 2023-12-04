# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local panelOptions = import 'panelOptions.libsonnet';
local promql = import 'promql.libsonnet';



{
	local basePanel( panelType, title, width, height ) =
		panelOptions.basePanel( panelType )
		.init( title )
		.width( width )
		.height( height ),
	
	
	row( title ):
		basePanel( 'row', title, 24, 1 )
		.mergeOpts( panelOptions.row ),
	
	
	text( title, text ):
		basePanel( 'text', title, 24, 3 )
		.mergeOpts( panelOptions.text )
		.content( text ),
	
	
	gauge( title ):
		basePanel( 'gauge', title, 6, 4 )
		.mergeOpts( panelOptions.gauge ),
	
	
	stat( title ):
		basePanel( 'stat', title, 6, 4 )
		.mergeOpts( panelOptions.stat ),
	
	
	timeSeries( title, description, query, queryLegend, unity ):
		basePanel( 'timeSeries', title, 12, 8 )
		.mergeOpts( panelOptions.timeSeries )
		.description( description )
		.targets( [ promql.makeQuery( query, queryLegend ) ] )
		.unit( unity )
		.min( 0 )
		.fillOpacity( 25 )
		.showPoints( 'never' ),
	
	
	logs( title ):
		basePanel( 'logs', title, 6, 4 )
		.mergeOpts( panelOptions.logs ),
}