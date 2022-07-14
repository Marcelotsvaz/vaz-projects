// 
// VAZ Projects
// 
// 
// Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



'use strict';



// 
// General stuff.
//------------------------------------------------------------------------------
function init()
{
	document.querySelectorAll( 'div.imageGallery > a' ).forEach( elem => elem.onclick = showFigure );
	document.querySelectorAll( 'div.imageGallery > div' ).forEach( elem => elem.onclick = hideFigure );
}

if ( document.readyState === 'loading' )
{
	document.addEventListener( 'DOMContentLoaded', init );
}
else
{
	init();
}


// 
// Show the image gallery modal.
//------------------------------------------------------------------------------
function showFigure( event )
{
	event.currentTarget.nextElementSibling.style.display = 'initial';
	
	event.preventDefault();
}


// 
// Hide the image gallery modal.
//------------------------------------------------------------------------------
function hideFigure( event )
{
	if( event.target.matches( 'div, button' ) )
	{
		event.currentTarget.style.display = 'none';
	}
}


// 
// Disqus.
//------------------------------------------------------------------------------
var disqus_container_id = 'disqusThread';


function disqus_config()
{
	const disqusDiv = document.getElementById( disqus_container_id );
	
	this.page.identifier = disqusDiv.dataset.identifier;
	this.page.title = disqusDiv.dataset.title;
	this.page.url = disqusDiv.dataset.url;
}