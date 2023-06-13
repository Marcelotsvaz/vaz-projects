# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from os import environ
from pathlib import Path

from django.utils.translation import gettext_lazy as _



# General
#---------------------------------------
BASE_DIR = Path( __file__ ).resolve().parents[1]
ROOT_URLCONF = 'urls'
WSGI_APPLICATION = 'wsgi.application'

ALLOWED_HOSTS = [ environ['domain'] ]
SECRET_KEY = environ['djangoSecretKey']


# Static and media files
#---------------------------------------
STATICFILES_STORAGE = 'commonApp.backends.StaticCloudfrontStorage'
DEFAULT_FILE_STORAGE = 'commonApp.backends.CloudfrontStorage'

AWS_S3_ENDPOINT_URL = environ['s3Endpoint']
AWS_STORAGE_BUCKET_NAME = environ['bucket']
AWS_S3_OBJECT_PARAMETERS = { 'CacheControl': 'max-age=3600' }
AWS_QUERYSTRING_AUTH = False

STATICFILES_DIRS = [ BASE_DIR / 'deployment/static' ]
STATIC_ROOT = 'static/'
STATIC_URL = environ["staticFilesUrl"]

MEDIA_ROOT = 'media/'
MEDIA_URL = STATIC_URL


# Localization
#---------------------------------------
USE_TZ = True
USE_THOUSAND_SEPARATOR = True

LANGUAGE_CODE = 'en'
LANGUAGES = [
	( 'en', _('English') ),
]
TIME_ZONE = 'America/Sao_Paulo'


# Security
#---------------------------------------
CSRF_TRUSTED_ORIGINS = [ f'https://{host}' for host in ALLOWED_HOSTS ]
LANGUAGE_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True


# Admin
#---------------------------------------
JET_DEFAULT_THEME = 'dark-gray'
JET_SIDE_MENU_COMPACT = True


# Email
#---------------------------------------
# EMAIL_HOST = ''
# EMAIL_PORT = 465
# EMAIL_USE_SSL = True

SERVER_EMAIL = f'VAZ Projects <server@{environ["domain"]}>'
ADMINS = [ ( 'Marcelo Vaz', 'marcelotsvaz@gmail.com' ) ]


# Tests
#---------------------------------------
TEST_RUNNER = 'xmlrunner.extra.djangotestrunner.XMLTestRunner'
TEST_OUTPUT_DIR = BASE_DIR / 'deployment/tests'
TEST_OUTPUT_FILE_NAME = 'unitTests.xml'


# Apps
#---------------------------------------
INSTALLED_APPS = [
	'imagekit',
	'jet.dashboard',
	'jet',
	'django.contrib.admin',
	'django.contrib.auth',
	'django.contrib.contenttypes',
	'django.contrib.sessions',
	'django.contrib.messages',
	'django.contrib.staticfiles',
	'commonApp.apps.commonAppConfig',
	'siteApp.apps.siteAppConfig',
	'projectsApp.apps.projectsAppConfig',
	'blogApp.apps.blogAppConfig',
	'taggit',
	'django_elasticsearch_dsl',
	'rest_framework',
	'django_object_actions',
	'django_cleanup.apps.CleanupConfig',
]


# Middleware
#---------------------------------------
MIDDLEWARE = [
	'commonApp.middleware.ServerCacheMiddleware',
	'django.middleware.http.ConditionalGetMiddleware',
	'compression_middleware.middleware.CompressionMiddleware',
	'django.middleware.cache.UpdateCacheMiddleware',
	'django.contrib.sessions.middleware.SessionMiddleware',
	'django.middleware.locale.LocaleMiddleware',
	'django.middleware.common.CommonMiddleware',
	'django.middleware.csrf.CsrfViewMiddleware',
	'django.contrib.auth.middleware.AuthenticationMiddleware',
	'django.contrib.messages.middleware.MessageMiddleware',
	'django.middleware.cache.FetchFromCacheMiddleware',
]


# Templates
#---------------------------------------
TEMPLATES = [
	{
		'BACKEND': 'django.template.backends.jinja2.Jinja2',
		'APP_DIRS': True,
		'OPTIONS': {
			'environment': 'jinjaEnv.environment',
		},
	},
	{
		'BACKEND': 'django.template.backends.django.DjangoTemplates',
		'APP_DIRS': True,
		'OPTIONS': {
			'context_processors': [
				'django.template.context_processors.debug',
				'django.template.context_processors.request',
				'django.contrib.auth.context_processors.auth',
				'django.contrib.messages.context_processors.messages',
			],
		},
	},
]


# Password validators
#---------------------------------------
AUTH_PASSWORD_VALIDATORS = [
	{ 'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator' },
	{ 'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator' },
	{ 'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator' },
	{ 'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator' },
]


# Databases
#---------------------------------------
DATABASES = {
	'default': {
		'ENGINE': 'django.db.backends.postgresql',
		'HOST': 'postgres',
		'USER': 'postgres',
		'PASSWORD': environ['POSTGRES_PASSWORD'],
		'NAME': 'postgres',
	},
}

DEFAULT_AUTO_FIELD = 'django.db.models.AutoField'


# Cache
#---------------------------------------
CACHES = {
	'default':
	{
		'BACKEND': 'django.core.cache.backends.memcached.PyLibMCCache',
		'TIMEOUT': 365 * 24 * 60 * 60,	# 1 year.
		'LOCATION': 'memcached',
	},
}
CACHE_MIDDLEWARE_SECONDS = CACHES['default']['TIMEOUT']


# Django Elasticsearch DSL
#---------------------------------------
ELASTICSEARCH_DSL = {
	'default': {
		'hosts': [ 'elasticsearch' ],
		'http_auth': [ 'elastic', environ['ELASTIC_PASSWORD'] ],
	},
}


# django-imagekit
#---------------------------------------
IMAGEKIT_CACHEFILE_DIR = 'cache'
IMAGEKIT_DEFAULT_CACHEFILE_STRATEGY = 'commonApp.misc.Optimistic'
IMAGEKIT_SPEC_CACHEFILE_NAMER = 'imagekit.cachefiles.namers.source_name_dot_hash'
IMAGE_OPTIONS = {
	'WEBP': {
		'quality': 90,
		'method': 6,
	},
	'WEBP_LOSSLESS': {
		'lossless': True,
	},
}


# Disqus
#---------------------------------------
DISQUS_API_PUBLIC_KEY = 'sVt2thYWTTP5vy3uCJb2E7KVRgAF3ULId6h42in9WiA0AxM3TGmHFdMrf91jH2WM'