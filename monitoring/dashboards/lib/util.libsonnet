# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



{
	local get( obj, attr ) =
		local keys = std.split( attr, '.' );
		
		std.foldl(
			function( obj, key ) obj[key],
			keys,
			obj
		),
	
	
	local set( attr, value ) =
		local keys = std.split( attr, '.' );
		
		std.foldl(
			function( obj, key ) { [key]+: obj },
			std.reverse( keys ),
			value
		),
	
	
	layoutArray( array, sizeAttr, positionAttr ):
		std.foldl(
			function( acc, item ) {
				x: acc.x + get( item, sizeAttr ),
				array: acc.array + [ item + set( positionAttr, acc.x ) ],
			},
			array,
			{ x: 0, array: [] }
		).array,
	
	
	layoutPanels( rows ):
		local rawRows = [
			[ panel.build() for panel in row ] for row in rows
		];
		
		# Annotate each row with the height of the tallest element.
		local rowsWithHeight = [
			{
				row: row,
				height: std.foldl( std.max, [ panel.gridPos.h for panel in row ], 1 ),
			} for row in rawRows
		];
		
		# Lay out column, than lay out each row, and update each panel's vertical position from
		# calculated row height.
		local layedOutRows = [
			[
				# Set panel's vertical position after laying out column.
				panel + set( 'gridPos.y', rowObj.y )
				
				# Lay out row.
				for panel in $.layoutArray( rowObj.row, 'gridPos.w', 'gridPos.x' )
				
			] for rowObj in $.layoutArray( rowsWithHeight, 'height', 'y' )	# Lay out column.
		];
		
		std.flattenArrays( layedOutRows ),
}