#importing libraries
import PIL.Image as Image
import numpy as np
import os
from torchvision import transforms
transform=transforms.Compose([
                      transforms.ToTensor(),transforms.Normalize(mean=[0.485, 0.456, 0.406],
                                    std=[0.229, 0.224, 0.225]),
                  ])
import pickle

class ImageHandle:
    def __init__(self, directory, filename, file):
        self.directory = directory
        self.filename = filename
        self.path = os.path.join(self.directory, self.filename)
        self.file = file
        self.custom_model = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "media", "model_details", "finalized_model.pkl")
    
    
    def create_file(self):
        print(f'Creating File At : {self.path}')
        with open(self.path, 'wb+') as destination:
            for chunk in self.file.chunks():
                destination.write(chunk)
                
                
    def analyze_file(self):
        print(f"Model : {self.custom_model}")
        pickled_model = pickle.load(open(self.custom_model, 'rb'))

        img = transform(Image.open(self.path).convert('RGB')).cuda()
        output = pickled_model(img.unsqueeze(0))
        count = int(output.detach().cpu().sum().numpy())
        print("Predicted Count : ",count)
        temp = np.asarray(output.detach().cpu().reshape(output.detach().cpu().shape[2],output.detach().cpu().shape[3]))
        ps, ns = [], []
        for i in range(len(temp)):
            for j in range(len(temp[i])):
                if temp[i][j] > 0:
                    ps.append(temp[i][j])
                else:
                    ns.append(temp[i][j])
        print(len(ps))
        print(len(ns))
        ratio = len(ps)/len(ns)
        print(f"Ratio : {ratio}")
        return {"count" : count, "ratio" : ratio}