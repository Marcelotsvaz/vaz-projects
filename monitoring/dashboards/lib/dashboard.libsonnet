# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';

local util = import 'util.libsonnet';
local panel = import 'panel.libsonnet';

local dashboard = grafonnet.dashboard;



{
	local utils = {
		addOpt( opt ): self { data+: opt },
	},
	
	
	base( name, description ): utils {
		# Private fields and locals.
		_panelRows:: [],
		
		local addOpt = self.addOpt,
		
		
		# Main methods.
		init( name ): addOpt( dashboard.new( name ) ),
		build(): self.data
			+ dashboard.withPanels( util.layoutPanels( self._panelRows ) ),
		
		
		# Fields.
		local graphTooltipEnum = {
			default: {},
			sharedCroshair: dashboard.graphTooltip.withSharedCrosshair(),
			sharedTooltip: dashboard.graphTooltip.withSharedTooltip(),
		},
		
		description( value ):			addOpt( dashboard.withDescription( value ) ),
		editable( value ):				addOpt( dashboard.withEditable( value ) ),
		graphTooltip( value ):			addOpt( graphTooltipEnum[value] ),
		refreshIntervals( intervals ):	addOpt( dashboard.timepicker.withRefreshIntervals( intervals ) ),
		tags( tag ):					addOpt( dashboard.withTags( tag ) ),
		timezone( value ):				addOpt( dashboard.withTimezone( value ) ),
		
		panelRows( panelRows ):			self { _panelRows:: panelRows },
		addRow( row ):					self { _panelRows:: super._panelRows + [ row ] },
		
		
	}
	.init( name )
	.description( description )
	.graphTooltip( 'sharedCroshair' )
	.timezone( '' )
	.refreshIntervals( [
		'15s',
		'30s',
		'1m',
		'5m',
	] )
	.editable( false ),
	
	
	default( name, description ):
		local headerText = |||
			# %s
			
			%s
		||| % [ name, description ];
		
		local headerPanel =
			panel.text( '', headerText )
			.transparent( true );
		
		self.base( name, description )
		.addRow( [ headerPanel ] ),
}