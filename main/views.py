from django.http.response import HttpResponse
from django.utils import timezone
from django.core.exceptions import BadRequest
from django.views.decorators.csrf import csrf_exempt
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.parsers import FileUploadParser
import os
from .utils import ImageHandle
from .models import ImageUpload

class UploadView(APIView):
    parser_classes = (FileUploadParser,)
    # print(timezone.now().strftime("%m/%d/%Y, %H:%M:%S"))
    today = timezone.now().strftime("%d-%m-%Y")
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    directory = os.path.join(BASE_DIR, "media", "upload_images", today)

    def get(self, request):
        return HttpResponse("Welcome !! Crowd Density Detection")

    def post(self, request, format='jpg'):
        try:
            try:
                up_file = self.request.FILES.get('file')
            except:
                raise BadRequest("Image Upload Failed")
            
            if str(up_file).lower().endswith(".jpg") or str(up_file).lower().endswith(".jpeg"):            
                try:
                    if not os.path.exists(self.directory):
                        os.makedirs(self.directory)
                except FileExistsError:
                    raise BadRequest("Directory Creation Failed")
                
                file_name = f"image{ImageUpload.objects.all().count()}_{timezone.now().strftime('%d_%m_%Y')}.jpg"
                file_path = os.path.join(self.directory, file_name)
                
                image_h_obj = ImageHandle(self.directory, file_name, up_file)
                image_h_obj.create_file()
                data = image_h_obj.analyze_file()
                if data == None:
                    raise BadRequest("Cude is required to run the model")
                count = data['count']
                ratio = data['ratio']
                color = image_h_obj.get_availablity(data['ratio'])
                
                image_db_obj = ImageUpload()
                image_db_obj.file_name = str(up_file)
                image_db_obj.file_path = str(file_path)
                image_db_obj.head_count = count
                image_db_obj.ratio = ratio
                image_db_obj.availablity = color
                image_db_obj.save()
                
                return Response({"errorCode" : 0,
                                "message" : "Success",
                                "head_count" : count,
                                "density_ratio" : ratio,
                                "availablity" : color}, status=status.HTTP_202_ACCEPTED)
            else:
                raise BadRequest("Invalid Image Format")
        
        except Exception as e:
            print(e)
            return Response({"message": str(e), "errorCode" : 1}, status=status.HTTP_203_NON_AUTHORITATIVE_INFORMATION)

    def put(self, request, filename, **kwargs):
        print(request.data)
        uploaded_file = request.data['file']
        print(uploaded_file)
        return Response("Put Request")