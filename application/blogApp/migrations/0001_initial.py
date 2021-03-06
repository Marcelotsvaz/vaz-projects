# Generated by Django 4.0.1 on 2022-03-02 01:00

import commonApp.fields
import commonApp.models
from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import django.utils.timezone
import taggit.managers


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('taggit', '0004_alter_taggeditem_content_type_alter_taggeditem_tag'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='BlogPost',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('slug', models.SlugField(max_length=100, unique=True, verbose_name='slug')),
                ('title', models.CharField(max_length=100, verbose_name='title')),
                ('banner_original', models.ImageField(upload_to=commonApp.models.getUploadFolder('banner-original'), verbose_name='banner')),
                ('content', commonApp.fields.MarkdownField(verbose_name='content')),
                ('draft', models.BooleanField(default=True, verbose_name='draft')),
                ('posted', models.DateTimeField(default=django.utils.timezone.now, verbose_name='posted')),
                ('last_edited', models.DateTimeField(auto_now=True, verbose_name='last edited')),
                ('author', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='posts', to=settings.AUTH_USER_MODEL, verbose_name='author')),
                ('tags', taggit.managers.TaggableManager(help_text='A comma-separated list of tags.', through='taggit.TaggedItem', to='taggit.Tag', verbose_name='tags')),
            ],
            options={
                'verbose_name': 'post',
                'verbose_name_plural': 'posts',
                'ordering': ('-posted',),
            },
        ),
    ]
