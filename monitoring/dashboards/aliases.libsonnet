# 
# VAZ Projects
# 
# 
# Author:: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

local grafonnet = import 'github.com/grafana/grafonnet/gen/grafonnet-v10.1.0/main.libsonnet';

local timeSeries = grafonnet.panel.timeSeries;
local panel = timeSeries.panelOptions;
local standard = timeSeries.standardOptions;
local field = timeSeries.fieldConfig;



{
	description:	panel.withDescription,
	
	unit:			standard.withUnit,
	noValue:		standard.withNoValue,
	min:			standard.withMin,
	max:			standard.withMax,
	
	colorScheme:	standard.color.withMode,
	colorSeriesBy:	standard.color.withSeriesBy,
	
	steps:			standard.thresholds.withSteps,
	
	showPoints:		field.defaults.custom.withShowPoints,
	axisLabel:		field.defaults.custom.withAxisLabel,
	softMin:		field.defaults.custom.withAxisSoftMin,
	softMax:		field.defaults.custom.withAxisSoftMax,
	fillOpacity:	field.defaults.custom.withFillOpacity,
	gradientMode:	field.defaults.custom.withGradientMode,
}