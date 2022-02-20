// 
// VAZ Projects
// 
// 
// Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



function handler( event )
{
	var request = event.request;
	
	request.uri = '/siteApp/images/favicon.png';
	
	return request;
}