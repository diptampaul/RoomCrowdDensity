# Generated by Django 4.1.4 on 2022-12-10 00:23

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('main', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='imageupload',
            name='availablity',
            field=models.CharField(max_length=10, null=True),
        ),
    ]
