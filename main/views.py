from django.http.response import HttpResponse
from rest_framework.utils import json
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.parsers import FileUploadParser

# Create your views here.
class UploadView(APIView):
    parser_classes = (FileUploadParser,)

    def get(self, request):
        return HttpResponse("Welcome !! Crowd Density Detection")

    parser_classes = (FileUploadParser, )

    def post(self, request, format='jpg'):
        print (request.FILES)
        # to access data
        print (request.data)
        up_file = request.FILES['file']
        return Response(up_file.name, status.HTTP_201_CREATED)

    def put(self, request, filename, **kwargs):
        print(request.data)
        uploaded_file = request.data['file']
        print(uploaded_file)
        return Response("Put Request")