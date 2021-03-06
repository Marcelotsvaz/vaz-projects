# Generated by Django 4.0.1 on 2022-03-02 01:00

import commonApp.fields
import commonApp.models
from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import django.utils.timezone


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Category',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('slug', models.SlugField(max_length=100, unique=True, verbose_name='slug')),
                ('name', models.CharField(max_length=100, verbose_name='name')),
                ('order', models.IntegerField(default=0, verbose_name='order')),
            ],
            options={
                'verbose_name': 'category',
                'verbose_name_plural': 'categories',
                'ordering': ('order', 'name'),
            },
        ),
        migrations.CreateModel(
            name='Project',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('slug', models.SlugField(max_length=100, unique=True, verbose_name='slug')),
                ('name', models.CharField(max_length=100, verbose_name='name')),
                ('banner_original', models.ImageField(upload_to=commonApp.models.getUploadFolder('banner-original'), verbose_name='banner')),
                ('thumbnail_original', models.ImageField(upload_to=commonApp.models.getUploadFolder('thumbnail-original'), verbose_name='thumbnail')),
                ('description', commonApp.fields.TextField(verbose_name='description')),
                ('content', commonApp.fields.MarkdownField(verbose_name='content')),
                ('draft', models.BooleanField(default=True, verbose_name='draft')),
                ('highlight', models.BooleanField(default=False, verbose_name='highlight')),
                ('posted', models.DateTimeField(default=django.utils.timezone.now, verbose_name='posted')),
                ('base_last_edited', models.DateTimeField(auto_now=True, verbose_name='base last edited')),
                ('notes', commonApp.fields.TextField(blank=True, verbose_name='notes')),
                ('author', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='projects', to=settings.AUTH_USER_MODEL, verbose_name='author')),
                ('category', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='projects', to='projectsApp.category', verbose_name='category')),
            ],
            options={
                'verbose_name': 'project',
                'verbose_name_plural': 'projects',
                'ordering': ('category', 'name'),
            },
        ),
        migrations.CreateModel(
            name='Page',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('number', models.PositiveIntegerField(verbose_name='page number')),
                ('type', models.CharField(blank=True, max_length=100, verbose_name='type')),
                ('name', models.CharField(max_length=100, verbose_name='name')),
                ('banner_original', models.ImageField(upload_to=commonApp.models.getUploadFolder('banner-original'), verbose_name='banner')),
                ('thumbnail_original', models.ImageField(upload_to=commonApp.models.getUploadFolder('thumbnail-original'), verbose_name='thumbnail')),
                ('description', commonApp.fields.TextField(verbose_name='description')),
                ('content', commonApp.fields.MarkdownField(verbose_name='content')),
                ('draft', models.BooleanField(default=True, verbose_name='draft')),
                ('posted', models.DateTimeField(default=django.utils.timezone.now, verbose_name='posted')),
                ('last_edited', models.DateTimeField(auto_now=True, verbose_name='last edited')),
                ('project', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='pages', to='projectsApp.project', verbose_name='project')),
            ],
            options={
                'verbose_name': 'project page',
                'verbose_name_plural': 'project pages',
                'ordering': ('project', 'number'),
            },
        ),
        migrations.AddConstraint(
            model_name='page',
            constraint=models.UniqueConstraint(fields=('project', 'number'), name='uniqueForProject'),
        ),
    ]
