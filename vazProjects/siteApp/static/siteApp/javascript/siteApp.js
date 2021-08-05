//
// VAZ Projects
//
//
// Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



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