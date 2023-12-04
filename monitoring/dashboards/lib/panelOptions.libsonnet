# 
# VAZ Projects
# 
# 
# Author:: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';



{
	local utils = {
		addOpt( opt ): self { data+: opt },
		mergeOpts( opts ): self + opts,
	},
	
	
	basePanel( panelType ): utils {
		local addOpt = self.addOpt,
		local panel = grafonnet.panel[panelType],
		local opts = {
			field: grafonnet.panel.timeSeries.fieldConfig.defaults.custom,
			panel: grafonnet.panel.timeSeries.panelOptions,
			position: grafonnet.panel.timeSeries.gridPos,
			query: grafonnet.panel.timeSeries.queryOptions,
			standard: grafonnet.panel.timeSeries.standardOptions,
		},
		
		
		# Constructor.
		init( title ):				addOpt( panel.new( title ) ),
		
		
		# fieldConfig.defaults.custom.
		showPoints( value ):		addOpt( opts.field.withShowPoints( value ) ),
		axisLabel( value ):			addOpt( opts.field.withAxisLabel( value ) ),
		softMin( value ):			addOpt( opts.field.withAxisSoftMin( value ) ),
		softMax( value ):			addOpt( opts.field.withAxisSoftMax( value ) ),
		fillOpacity( value ):		addOpt( opts.field.withFillOpacity( value ) ),
		gradientMode( value ):		addOpt( opts.field.withGradientMode( value ) ),
		
		
		# panelOptions.
		description( value ):		addOpt( opts.panel.withDescription( value ) ),
		
		
		# gridPos.
		width( value ):				addOpt( opts.position.withW( value ) ),
		height( value ):			addOpt( opts.position.withH( value ) ),
		x( value ):					addOpt( opts.position.withX( value ) ),
		y( value ):					addOpt( opts.position.withY( value ) ),
		
		
		# queryOptions.
		targets( value ):			addOpt( opts.query.withTargets( value ) ),
		
		
		# standardOptions.
		unit( value ):				addOpt( opts.standard.withUnit( value ) ),
		noValue( value ):			addOpt( opts.standard.withNoValue( value ) ),
		min( value ):				addOpt( opts.standard.withMin( value ) ),
		max( value ):				addOpt( opts.standard.withMax( value ) ),
		
		colorScheme( value ):		addOpt( opts.standard.color.withMode( value ) ),
		colorSeriesBy( value ):		addOpt( opts.standard.color.withSeriesBy( value ) ),
		
		steps( value ):				addOpt( opts.standard.thresholds.withSteps( value ) ),
		
		
		# Complex setters.
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
	
	
	timeSeries: utils {
		
	},
	
	
	logs: utils {
		
	},
}