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
		.mergeOpts( panelOptions[panelType] )
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
		self.basePanel( 'row', title, '', 24, 1 ),
	
	
	text( title, content ):
		self.basePanel( 'text', title, '', 24, 3 )
		.content( content ),
	
	
	gauge( title, description, query ):
		self.queryPanel( 'gauge', title, description, 6, 4, query ),
	
	
	stat( title, description, query ):
		self.queryPanel( 'stat', title, description, 3, 4, query ),
	
	
	pieChart( title, description, query ):
		self.queryPanel( 'pieChart', title, description, 4, 6, query )
		.aggregate( false )
		.decimals( 1 )
		.unit( 'percentunit' )
		.overrideField.byType( 'string', 'unit' )
		.legendMode( 'table' )
		.legendPlacement( 'right' )
		.legendValue( 'value' )
		.tooltipMode( 'multi' ),
	
	
	timeSeries( title, description, query, unity ):
		self.queryPanel( 'timeSeries', title, description, 12, 8, query )
		.unit( unity )
		.min( 0 )
		.fillOpacity( 25 )
		.showPoints( 'never' ),
	
	
	logs( title, description ):
		self.basePanel( 'logs', title, description, 6, 4 ),
}