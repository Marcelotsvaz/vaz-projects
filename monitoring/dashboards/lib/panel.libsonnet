# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local panelOptions = import 'panelOptions.libsonnet';
local promql = import 'promql.libsonnet';



{
	local basePanel( panelType, title, description, width, height ) =
		panelOptions.basePanel( panelType )
		.init( title )
		.description( description )
		.width( width )
		.height( height ),
	
	
	# Base for all panels that use queries.
	local queryPanel( panelType, title, description, width, height, query ) =
		basePanel( panelType, title, description, width, height )
		.targets( [ query.data ] ),
	
	
	
	# 
	# Concrete panels.
	#---------------------------------------------------------------------------
	row( title ):
		basePanel( 'row', title, 24, 1 )
		.mergeOpts( panelOptions.row ),
	
	
	text( title, content ):
		basePanel( 'text', title, 24, 3 )
		.mergeOpts( panelOptions.text )
		.content( content ),
	
	
	gauge( title ):
		basePanel( 'gauge', title, 6, 4 )
		.mergeOpts( panelOptions.gauge ),
	
	
	stat( title ):
		basePanel( 'stat', title, 6, 4 )
		.mergeOpts( panelOptions.stat ),
	
	
	timeSeries( title, description, query, unity ):
		queryPanel( 'timeSeries', title, description, 12, 8, query )
		.mergeOpts( panelOptions.timeSeries )
		.unit( unity )
		.min( 0 )
		.fillOpacity( 25 )
		.showPoints( 'never' ),
	
	
	logs( title ):
		basePanel( 'logs', title, 6, 4 )
		.mergeOpts( panelOptions.logs ),
}