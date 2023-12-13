from locust import HttpUser, between, task



class WebsiteUser( HttpUser ):
	wait_time = between( 1, 10 )
	
	@task( 10 )
	def projects( self ) -> None:
		self.client.get( '/' )
		self.client.get( '/projects' )
		self.client.get( '/projects/test-project-1' )
		self.client.get( '/projects/test-project-1/page/1' )
	
	
	@task( 10 )
	def blog( self ) -> None:
		self.client.get( '/' )
		self.client.get( '/blog' )
		self.client.get( '/blog/test-post-1' )
	
	
	@task( 10 )
	def search( self ) -> None:
		self.client.get( '/' )
		self.client.get( '/search?query=test' )
		self.client.get( '/projects/test-project-1' )
		self.client.get( '/projects/test-project-1/page/1' )
		self.client.get( '/blog/test-post-1' )
	
	
	@task( 1 )
	def nonExistent( self ) -> None:
		with self.client.get( '/non-existent', catch_response = True ) as response:
			if response.status_code == 404:
				response.success()