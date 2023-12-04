# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';



local makeQuery( query, queryLegend ) =
	grafonnet.query.prometheus.new( 'Prometheus', query )
	+ grafonnet.query.prometheus.withLegendFormat( queryLegend );



{
	makeQuery: makeQuery,
}