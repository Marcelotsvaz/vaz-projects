// 
// VAZ Projects
// 
// 
// Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



'use strict';



// 
// General stuff.
//------------------------------------------------------------------------------
function init() {
	document.querySelectorAll( '.imageGallery > a' ).forEach( elem => elem.onclick = showFigure );
	document.querySelectorAll( '.imageGallery > div' ).forEach( elem => elem.onclick = hideFigure );
	
	updateCommentsCount();
}

if ( document.readyState === 'loading' ) {
	document.addEventListener( 'DOMContentLoaded', init );
}
else {
	init();
}


// 
// Show the image gallery modal.
//------------------------------------------------------------------------------
function showFigure( event ) {
	event.preventDefault();
	
	event.currentTarget.nextElementSibling.style.display = 'initial';
}


// 
// Hide the image gallery modal.
//------------------------------------------------------------------------------
function hideFigure( event ) {
	if( event.target.matches( 'div, button' ) ) {
		event.currentTarget.style.display = 'none';
	}
}


// 
// Disqus.
//------------------------------------------------------------------------------
var disqus_container_id = 'disqusThread';


function disqus_config() {
	const disqusDiv = document.getElementById( disqus_container_id );
	
	this.page.identifier = disqusDiv.dataset.identifier;
	this.page.title = disqusDiv.dataset.title;
	this.page.url = disqusDiv.dataset.url;
}


async function updateCommentsCount() {
	const tags = {};
	
	for ( const tag of document.querySelectorAll( '.commentCount' ) ) {
		tags[tag.dataset.identifier] = tag;
	}
	
	if ( Object.keys( tags ).length == 0 ) {
		return;
	}
	
	try {
		const parameters = new URLSearchParams( Object.keys( tags ).map( identifier => [ 'identifiers', identifier ] ) );
		const response = await fetch( '/api/comments-count?' + parameters );
		
		if ( response.status != 200 ) {
			throw new Error( `Error, server answered with status code ${response.status}.` );
		}
		
		const commentsCount = await response.json();
		
		for ( const [ identifier, commentCount ] of Object.entries( commentsCount ) ) {
			// TODO: Handle plural.
			tags[identifier].textContent = tags[identifier].textContent.replace( /-?\d+/, commentCount );
		}
	}
	catch ( error ) {
		console.log( error );
	}
}