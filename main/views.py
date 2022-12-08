from django.http.response import HttpResponse

# Create your views here.
def home(request):
    return HttpResponse("Heeloo")