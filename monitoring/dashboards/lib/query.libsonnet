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
			histogramQuantile: super.histogram_quantile,
			
			rate( interval = '$__rate_interval', resolution = '$__interval' ):
				super.rate( [ interval, resolution ] ),
			
			op( operator, expression ):
				self.withFuncTemplate( '%%s %s %s' % [ operator, expression ] ),
			
			opL( expression, operator ):
				self.withFuncTemplate( '%s %s %%s' % [ expression, operator ] ),
		}
	},
	
	
	local baseQuery( dataSourceType, dataSource, expression, legend ) = utils {
		local addOpt = self.addOpt,
		local query = grafonnet.query[dataSourceType],
		
		
		init( dataSource, expression ):	addOpt( query.new( dataSource, expression.build() ) ),
		legend( legend ):				addOpt( query.withLegendFormat( legend ) ),
	}
		.init( dataSource, expression )
		.legend( legend ),
	
	
	prometheus( dataSource, expression, legend ):
		baseQuery( 'prometheus', dataSource, expression, legend ),
}