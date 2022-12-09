from django.db import models

# Create your models here.
class ImageUpload(models.Model):
    image_id = models.AutoField(primary_key=True)
    file_name = models.CharField(max_length = 20)
    file_path = models.CharField(max_length = 150)
    head_count = models.IntegerField(null=True)
    ratio = models.FloatField(null=True)
    created_timestamp = models.DateTimeField(blank=False, auto_now_add=True)