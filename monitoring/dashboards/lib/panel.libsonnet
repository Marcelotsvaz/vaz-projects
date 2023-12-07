# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local panelOptions = import 'panelOptions.libsonnet';
local promql = import 'promql.libsonnet';



{
	basePanel( panelType, title, description, width, height ):
		panelOptions.basePanel( panelType )
		.init( title )
		.description( description )
		.width( width )
		.height( height ),
	
	
	# Base for all panels that use queries.
	queryPanel( panelType, title, description, width, height, query ):
		self.basePanel( panelType, title, description, width, height )
		.targets( [ query.data ] ),
	
	
	
	# 
	# Concrete panels.
	#---------------------------------------------------------------------------
	row( title ):
		self.basePanel( 'row', title, 24, 1 )
		.mergeOpts( panelOptions.row ),
	
	
	text( title, content ):
		self.basePanel( 'text', title, '', 24, 3 )
		.mergeOpts( panelOptions.text )
		.content( content ),
	
	
	gauge( title ):
		self.basePanel( 'gauge', title, 6, 4 )
		.mergeOpts( panelOptions.gauge ),
	
	
	stat( title ):
		self.basePanel( 'stat', title, 6, 4 )
		.mergeOpts( panelOptions.stat ),
	
	
	pieChart( title, description, query ):
		self.queryPanel( 'pieChart', title, description, 4, 6, query )
		.mergeOpts( panelOptions.pieChart )
		.showValues( 'all' )
		.decimals( 1 )
		.unit( 'percentunit' )
		.overrideField.byType( 'string', 'unit' )
		.legendMode( 'table' )
		.legendPlacement( 'right' )
		.legendValue( 'value' )
		.tooltipMode( 'multi' ),
	
	
	timeSeries( title, description, query, unity ):
		self.queryPanel( 'timeSeries', title, description, 12, 8, query )
		.mergeOpts( panelOptions.timeSeries )
		.unit( unity )
		.min( 0 )
		.fillOpacity( 25 )
		.showPoints( 'never' ),
	
	
	logs( title ):
		self.basePanel( 'logs', title, 6, 4 )
		.mergeOpts( panelOptions.logs ),
}