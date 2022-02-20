// 
// VAZ Projects
// 
// 
// Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



'use strict';



// 
// General stuff.
//------------------------------------------------------------------------------
$( document ).ready( documentReady );
function documentReady()
{
	$( 'div.imageGallery > a' ).on( 'click', showFigure );
	$( 'div.imageGallery > div' ).on( 'click', hideFigure );
}


// 
// Show the image gallery modal.
//------------------------------------------------------------------------------
function showFigure( event )
{
	$( event.currentTarget ).next().show();
	
	event.preventDefault();
}


// 
// Hide the image gallery modal.
//------------------------------------------------------------------------------
function hideFigure( event )
{
	if( $( event.target ).is( 'div, button' ) )
	{
		$( event.currentTarget ).hide();
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