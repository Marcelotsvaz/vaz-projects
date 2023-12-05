# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource aws_ce_anomaly_monitor main {
	name = local.project_code
	monitor_type = "DIMENSIONAL"
	monitor_dimension = "SERVICE"
	
	tags = {
		Name = "${local.project_name} Cost Anomaly Monitor"
	}
}


resource aws_ce_anomaly_subscription main {
	name = local.project_code
	frequency = "DAILY"
	monitor_arn_list = [ aws_ce_anomaly_monitor.main.arn ]
	
	subscriber {
		type = "EMAIL"
		address = local.admin_email
	}
	
	threshold_expression {
		dimension {
			key = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
			match_options = [ "GREATER_THAN_OR_EQUAL" ]
			values = [ "10.0" ]
		}
	}
	
	tags = {
		Name = "${local.project_name} Cost Anomaly Subscription"
	}
}