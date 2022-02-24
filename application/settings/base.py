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

ALLOWED_HOSTS = [ environ['domain'] ]

ROOT_URLCONF = 'urls'
WSGI_APPLICATION = 'wsgi.application'

SECRET_KEY = environ['djangoSecretKey']


# Static and media files
#---------------------------------------
STATICFILES_DIRS = [
	BASE_DIR / 'deployment/static',
]


# Localization
#---------------------------------------
USE_TZ = True
USE_THOUSAND_SEPARATOR = True

LANGUAGE_CODE = 'en-US'
LANGUAGES = [
	( 'en-US', _('American English') ),
]
TIME_ZONE = 'America/Sao_Paulo'


# Admin
#---------------------------------------
JET_DEFAULT_THEME = 'dark-gray'
JET_SIDE_MENU_COMPACT = True


# Email
#---------------------------------------
# TODO: Fix email.
EMAIL_HOST = 'email-ssl.com.br'
EMAIL_PORT = 465
EMAIL_USE_SSL = True

SERVER_EMAIL = 'UTL Server <server@utlturismo.com.br>'
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
	'django_cleanup.apps.CleanupConfig',
	'django_object_actions',
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
	'JPEG': {
		'optimize': True,
		'quality': 95,
		'progressive': True,
	},
	'PNG': {
		'optimize': True,
	},
}


# Disqus
#---------------------------------------
DISQUS_API_KEY = 'a5pgeL0uQcBBwVusQO1HM4GIx1P1MdCNeqkamBAVuBLnuT0scmmmtrDiQxKdrJoG'