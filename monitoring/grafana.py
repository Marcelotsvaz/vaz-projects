#! /usr/bin/env python
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>

import argparse
import json
import os
from typing import Any

import requests



def main() -> int:
	'''
	CLI entry point.
	'''
	
	# Parser setup.
	parser = argparse.ArgumentParser(
		description = 'TODO',
		add_help = False,
	)
	subparsers = parser.add_subparsers( title = 'command' )
	
	parser.set_defaults( command = lambda **_: parser.print_usage() )
	parser.add_argument( '-h', '--help', action = 'help', help = 'Show this help message.' )
	parser.add_argument(
		'--version',
		action = 'version',
		version = f'{parser.prog} 0.1',
		help = 'Show program\'s version number.',
	)
	
	# Commands.
	uploadParser = subparsers.add_parser(
		'upload',
		help = upload.__doc__,
		description = upload.__doc__,
	)
	uploadParser.set_defaults( command = upload )
	uploadParser.add_argument( 'dashboard', help = 'Path to a Grafana dashboard in JSON format.' )
	
	# Run.
	args = parser.parse_args()
	
	return args.command( **vars( args ) )



def upload( dashboard: str, **_kwargs: Any ) -> int:
	'''
	
	'''
	
	with open( dashboard ) as file:
		dashboardJson = json.load( file )
	
	sendUploadRequest( dashboardJson, os.environ['grafanaHost'], os.environ['grafanaApiKey'] )
	
	return 0



def sendUploadRequest( dashboard: str, grafanaHost: str, apiKey: str ) -> None:
	'''
	
	'''
	
	requestData = json.dumps( {
		'dashboard': dashboard,
		'overwrite': True,
		'message': 'Updated with HTTP API.'
	} )
	
	headers = {
		'Authorization': f'Bearer {apiKey}',
		'Content-Type': 'application/json'
	}
	
	response = requests.post(
		f'{grafanaHost}/api/dashboards/db',
		data = requestData,
		headers = headers
	)
	
	print( f'{response.status_code} - {response.json()}' )



if __name__ == '__main__':
	main()