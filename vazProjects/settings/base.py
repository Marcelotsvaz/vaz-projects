#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import os
from pathlib import Path

from django.utils.translation import gettext_lazy as _



# General
########################################
BASE_DIR = Path( __file__ ).resolve().parents[2]

ALLOWED_HOSTS = [ os.environ['hostname'] ]

ROOT_URLCONF = 'urls'
WSGI_APPLICATION = 'wsgi.application'


# Static and media files
########################################
STATICFILES_DIRS = [
	BASE_DIR / 'deployment/static',
]


# Localization
########################################
USE_I18N = True
USE_L10N = True
USE_TZ = True

USE_THOUSAND_SEPARATOR = True

LANGUAGE_CODE = 'en'
LANGUAGES = (
	( 'en', _('English') ),
	( 'pt-br', _('Brazilian Portuguese') ),
)
TIME_ZONE = 'America/Sao_Paulo'


# Admin
########################################
JET_DEFAULT_THEME = 'dark-gray'
JET_SIDE_MENU_COMPACT = True


# Databases
########################################
DATABASES = {
	'default': {
		'ENGINE': 'django.db.backends.sqlite3',
		'NAME': BASE_DIR / 'deployment/vazProjects.sqlite3',
	},
}


# Email
########################################
EMAIL_HOST = 'email-ssl.com.br'
EMAIL_PORT = 465
EMAIL_USE_SSL = True

SERVER_EMAIL = 'UTL Server <server@utlturismo.com.br>'
ADMINS = [ ( 'Marcelo Vaz', 'marcelotsvaz@gmail.com' ) ]


# django-imagekit
########################################
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


# Apps
########################################
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
	'django_cleanup.apps.CleanupConfig',
]


# Middleware
########################################
MIDDLEWARE = [
	'commonApp.middleware.ServerCacheMiddleware',
	'django.middleware.http.ConditionalGetMiddleware',
	'django.middleware.cache.UpdateCacheMiddleware',
	'compression_middleware.middleware.CompressionMiddleware',
	'django.contrib.sessions.middleware.SessionMiddleware',
	'django.middleware.locale.LocaleMiddleware',
	'django.middleware.common.CommonMiddleware',
	'django.middleware.csrf.CsrfViewMiddleware',
	'django.contrib.auth.middleware.AuthenticationMiddleware',
	'django.contrib.messages.middleware.MessageMiddleware',
	'django.middleware.cache.FetchFromCacheMiddleware',
]


# Templates
########################################
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
########################################
AUTH_PASSWORD_VALIDATORS = [
	{ 'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator', },
	{ 'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator', },
	{ 'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator', },
	{ 'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator', },
]