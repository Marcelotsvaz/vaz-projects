# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Custom configuration.
export AWS_DEFAULT_OUTPUT=table

green='\[\e[0;32m\]'
blue='\[\e[1;34m\]'
reset='\[\e[m\]'
PS1="┌[\A][${green}\u@\h ${blue}\w${reset}]\$\n└> "

alias grep='grep --color=auto'
alias ls='ls --color=auto'