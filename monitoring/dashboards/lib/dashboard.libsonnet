# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';

local util = import 'util.libsonnet';

local dashboard = grafonnet.dashboard;



{
	local utils = {
		addOpt( opt ): self { data+: opt },
	},
	
	
	default( name, description ): utils {
		# Private fields and locals.
		local addOpt = self.addOpt,
		
		
		# Main methods.
		init( name ): addOpt( dashboard.new( name ) ),
		build(): self.data,
		
		
		# Fields.
		local graphTooltipEnum = {
			default: {},
			sharedCroshair: dashboard.graphTooltip.withSharedCrosshair(),
			sharedTooltip: dashboard.graphTooltip.withSharedTooltip(),
		},
		
		description( value ):			addOpt( dashboard.withDescription( value ) ),
		editable( value ):				addOpt( dashboard.withEditable( value ) ),
		graphTooltip( value ):			addOpt( graphTooltipEnum[value] ),
		panels( panels ):				addOpt( dashboard.withPanels( util.layoutPanels( panels ) ) ),
		refreshIntervals( intervals ):	addOpt( dashboard.timepicker.withRefreshIntervals( intervals ) ),
		tags( tag ):					addOpt( dashboard.withTags( tag ) ),
		timezone( value ):				addOpt( dashboard.withTimezone( value ) ),
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
}