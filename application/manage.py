#!/usr/bin/env python
#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import sys



if __name__ == '__main__':
	try:
		from django.core.management import execute_from_command_line
	except ImportError as exc:	# pragma: no cover
		raise ImportError(
			'Couldn\'t import Django. Are you sure it\'s installed and '
			'available on your PYTHONPATH environment variable? Did you '
			'forget to activate a virtual environment?'
		) from exc
		
	execute_from_command_line( sys.argv )