# 
# VAZ Projects
# 
# 
# Author:: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';

local timeSeries = grafonnet.panel.timeSeries;

local field = timeSeries.fieldConfig.defaults.custom;
local panel = timeSeries.panelOptions;
local position = timeSeries.gridPos;
local query = timeSeries.queryOptions;
local standard = timeSeries.standardOptions;



{
	# fieldConfig.defaults.custom.
	showPoints:		field.withShowPoints,
	axisLabel:		field.withAxisLabel,
	softMin:		field.withAxisSoftMin,
	softMax:		field.withAxisSoftMax,
	fillOpacity:	field.withFillOpacity,
	gradientMode:	field.withGradientMode,
	
	
	# panelOptions.
	description:	panel.withDescription,
	
	
	# gridPos.
	width:			position.withW,
	height:			position.withH,
	x:				position.withX,
	y:				position.withY,
	
	
	# queryOptions.
	targets:		query.withTargets,
	
	
	# standardOptions.
	unit:			standard.withUnit,
	noValue:		standard.withNoValue,
	min:			standard.withMin,
	max:			standard.withMax,
	
	colorScheme:	standard.color.withMode,
	colorSeriesBy:	standard.color.withSeriesBy,
	
	steps:			standard.thresholds.withSteps,
}