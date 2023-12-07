# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';



{
	local utils = {
		addOpt( opt ): self { data+: opt },
		mergeOpts( opts ): self + opts,
	},
	
	
	basePanel( panelType ): utils {
		# Private fields and locals.
		_overrides:: [],
		
		local addOpt = self.addOpt,
		local panel = grafonnet.panel[panelType],
		local opts = {
			field: panel.fieldConfig.defaults.custom,
			panel: panel.panelOptions,
			position: panel.gridPos,
			query: panel.queryOptions,
			standard: panel.standardOptions,
		},
		
		
		# Main methods.
		init( title ): addOpt( panel.new( title ) ),
		build(): self.data
			+ opts.standard.withOverrides( self._overrides ),
		
		
		# Fields.
		
		# fieldConfig.defaults.custom.
		showPoints( value ):		addOpt( opts.field.withShowPoints( value ) ),
		axisLabel( value ):			addOpt( opts.field.withAxisLabel( value ) ),
		softMin( value ):			addOpt( opts.field.withAxisSoftMin( value ) ),
		softMax( value ):			addOpt( opts.field.withAxisSoftMax( value ) ),
		fillOpacity( value ):		addOpt( opts.field.withFillOpacity( value ) ),
		gradientMode( value ):		addOpt( opts.field.withGradientMode( value ) ),
		
		
		# panelOptions.
		description( value ):		addOpt( opts.panel.withDescription( value ) ),
		transparent( value ):		addOpt( opts.panel.withTransparent( value ) ),
		
		
		# gridPos.
		width( value ):				addOpt( opts.position.withW( value ) ),
		height( value ):			addOpt( opts.position.withH( value ) ),
		x( value ):					addOpt( opts.position.withX( value ) ),
		y( value ):					addOpt( opts.position.withY( value ) ),
		
		
		# queryOptions.
		targets( value ):			addOpt( opts.query.withTargets( value ) ),
		
		
		# standardOptions.
		decimals( value ):			addOpt( opts.standard.withDecimals( value ) ),
		unit( value ):				addOpt( opts.standard.withUnit( value ) ),
		noValue( value ):			addOpt( opts.standard.withNoValue( value ) ),
		min( value ):				addOpt( opts.standard.withMin( value ) ),
		max( value ):				addOpt( opts.standard.withMax( value ) ),
		
		colorScheme( value ):		addOpt( opts.standard.color.withMode( value ) ),
		colorSeriesBy( value ):		addOpt( opts.standard.color.withSeriesBy( value ) ),
		
		steps( value ):				addOpt( opts.standard.thresholds.withSteps( value ) ),
		
		
		# Custom setters.
		local addOverride( override ) = self {
			_overrides:: super._overrides + [ override ]
		},
		
		overrideField: {
			byType( type, property, value = null ): addOverride( {
				matcher: {
					id: 'byType',
					options: type,
				},
				
				properties: [
					{
						id: property,
						[if value != null then 'value']: value,
					},
				],
			} ),
		},
		
		threshold( theshold ):
			self
			.gradientMode( 'scheme' )
			.colorScheme( 'thresholds' )
			.colorSeriesBy( 'min' )
			.steps( [
				{
					color: 'green',
					value: null,
				},
				{
					color: 'red',
					value: theshold,
				},
			] ),
	},
	
	
	row: utils {
		
	},
	
	
	text: utils {
		content( value ): self.addOpt( grafonnet.panel.text.options.withContent( value ) ),
	},
	
	
	gauge: utils {
		
	},
	
	
	stat: utils {
		
	},
	
	
	pieChart: utils {
		local showValuesEnum = {
			all: true,
			calculate: false,
		},
		
		showValues( value ): self.addOpt( grafonnet.panel.pieChart.options.reduceOptions.withValues( showValuesEnum[value] ) ),
		legendMode( mode ): self.addOpt( grafonnet.panel.pieChart.options.legend.withDisplayMode( mode ) ),
		legendPlacement( placement ): self.addOpt( grafonnet.panel.pieChart.options.legend.withPlacement( placement ) ),
		legendValue( value ): self.addOpt( grafonnet.panel.pieChart.options.legend.withValues( [ value ] ) ),
		tooltipMode( mode ): self.addOpt( grafonnet.panel.pieChart.options.tooltip.withMode( mode ) ),
	},
	
	
	timeSeries: utils {
		
	},
	
	
	logs: utils {
		
	},
}