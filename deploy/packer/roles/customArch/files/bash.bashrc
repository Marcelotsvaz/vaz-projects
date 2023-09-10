# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Environment
#-------------------------------------------------------------------------------
export AWS_DEFAULT_OUTPUT='table'



# 
# Prompt
#-------------------------------------------------------------------------------
userColor='\e[1;32m'	# Green.
pwdColor='\e[1;34m'		# Blue.
statusColor='\e[1;31m'	# Red.
resetColor='\e[m'

currentTime='\A'
user="${userColor}\u${resetColor}"
host="${userColor}\h${resetColor}"
pwd="${pwdColor}\w${resetColor}"
error='$(code=${?}; test ${code} != 0 && printf "[${statusColor}${code}${resetColor}]")'

PS1="┌[${currentTime}][${user}@${host} ${pwd}]${error}\n└> "

PS2='└> '



# 
# Aliases
#-------------------------------------------------------------------------------
alias ls='ls --group-directories-first --color=auto'
alias ll='ls -l -h --full-time'
alias la='ll -a'
alias ip='ip --color=auto'
alias bridge='bridge --color=auto'