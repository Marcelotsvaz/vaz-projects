#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import os
import socket
from pathlib import Path

from django.utils.translation import gettext_lazy as _



# General
#---------------------------------------
BASE_DIR = Path( __file__ ).resolve().parents[2]

ALLOWED_HOSTS = [ socket.gethostname() ]

ROOT_URLCONF = 'urls'
WSGI_APPLICATION = 'wsgi.application'


# Localization
#---------------------------------------
USE_I18N = True
USE_L10N = True
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


# Databases
#---------------------------------------
DATABASES = {
	'default': {
		'ENGINE': 'django.db.backends.sqlite3',
		'NAME': BASE_DIR / 'deployment/vazProjects.sqlite3',
	},
}

DEFAULT_AUTO_FIELD = 'django.db.models.AutoField'


# Email
#---------------------------------------
EMAIL_HOST = 'email-ssl.com.br'
EMAIL_PORT = 465
EMAIL_USE_SSL = True

SERVER_EMAIL = 'UTL Server <server@utlturismo.com.br>'
ADMINS = [ ( 'Marcelo Vaz', 'marcelotsvaz@gmail.com' ) ]



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
	{ 'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator', },
	{ 'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator', },
	{ 'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator', },
	{ 'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator', },
]


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


# Django Elasticsearch DSL
#---------------------------------------
ELASTICSEARCH_DSL = {
	'default': {
		'hosts': 'localhost:9200'
	},
}