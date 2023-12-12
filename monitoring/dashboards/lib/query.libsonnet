# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';
local promql = import 'github.com/satyanash/promql-jsonnet/promql.libsonnet';



{
	local utils = {
		addOpt( opt ): self { data+: opt },
	},
	
	
	expression: {
		promql( metricName ): promql.new( metricName ) {
			# Local helpers.
			local range( interval, resolution = null ) =
				local resolutionString = if resolution != null then ':' + resolution else '';
				'[%s%s]' % [ interval, resolutionString ],
			
			local buildExpression( expression ) =
				if std.isObject( expression ) && std.objectHas(expression, 'build')
				then expression.build()
				else expression,
			
			
			# Methods.
			histogramQuantile: super.histogram_quantile,
			
			rate( interval = '$__rate_interval', resolution = null ):
				self.withFuncTemplate( 'rate( %%s%s )' % range( interval, resolution ) ),
			
			increase( interval = '$__rate_interval', resolution = null ):
				self.withFuncTemplate( 'increase( %%s%s )' % range( interval, resolution ) ),
			
			op( operator, expression ):
				self.withFuncTemplate( '%%s %s %s' % [ operator, buildExpression( expression ) ] ),
			
			opL( expression, operator ):
				self.withFuncTemplate( '%s %s %%s' % [ buildExpression( expression ), operator ] ),
		}
	},
	
	
	local baseQuery( dataSourceType, dataSource, expression ) = utils {
		local addOpt = self.addOpt,
		local query = grafonnet.query[dataSourceType],
		
		local typeEnum = {
			timeSeries: false,
			instant: true,
		},
		
		init( dataSource, expression ):	addOpt( query.new( dataSource, expression.build() ) ),
		legend( legend ):				addOpt( query.withLegendFormat( legend ) ),
		type( type ):					addOpt( query.withInstant( typeEnum[type] ) ),
		format( format ):				addOpt( query.withFormat( format ) ),
	}
		.init( dataSource, expression )
		.legend( '__auto' ),
	
	
	prometheus( dataSource, expression ):
		baseQuery( 'prometheus', dataSource, expression ),
	
	
	prometheusInstant( dataSource, expression ):
		baseQuery( 'prometheus', dataSource, expression )
		.type( 'instant' )
		.format( 'table' ),
	
	
	cloudWatchMetric( dataSource, region, namespace, metric, statistic ): utils {
			local addOpt = self.addOpt,
			local cloudWatchQuery = grafonnet.query.cloudWatch.CloudWatchMetricsQuery,
			
			local modeEnum = {
				metric: "Metrics",
				logs: "Logs",
				annotation: "Annotations",
			},
			
			local typeEnum = {
				search: 0,
				query: 1,
			},
			
			local editorModeEnum = {
				builder: 0,
				code: 1,
			},
			
			mode( value ):			addOpt( cloudWatchQuery.withQueryMode( modeEnum[value] ) ),
			type( value ):			addOpt( cloudWatchQuery.withMetricQueryType( typeEnum[value] ) ),
			editorMode( value ):	addOpt( cloudWatchQuery.withMetricEditorMode( editorModeEnum[value] ) ),
			region( value ):		addOpt( cloudWatchQuery.withRegion( value ) ),
			namespace( value ):		addOpt( cloudWatchQuery.withNamespace( value ) ),
			metricName( value ):	addOpt( cloudWatchQuery.withMetricName( value ) ),
			datasource( value ):	addOpt( cloudWatchQuery.withDatasource( value ) ),
			statistic( value ):		addOpt( cloudWatchQuery.withStatistic( value ) ),
			matchExact( value ):	addOpt( cloudWatchQuery.withMatchExact( value ) ),
		}
		.mode( "metric" )
		.type( "search" )
		.editorMode( "builder" )
		.datasource( dataSource )
		.region( region )
		.namespace( namespace )
		.metricName( metric )
		.statistic( statistic ),
}