import nibabel
import sys
import numpy as np

# load data and print the dimensions
inData=str(sys.argv[1])
extension=str(sys.argv[2])

# load data
if "txt" in extension:
    data=np.loadtxt(inData)
    vert_k=int(round(data.shape[0], -3))
elif "curv" in extension:
    data=nibabel.freesurfer.io.read_morph_data(inData)
    vert_k=int(round(data.shape[0], -3))
elif "annot" in extension:                                                                                                  
    data = nibabel.freesurfer.io.read_annot(inData)                                                                             
    vert_k=int(round(data[0].shape[0], -3))
else:
    data=nibabel.load(inData)
    vert_k=int(round(data.darrays[0].data.shape[0], -3))

# get number of vertices and round to nearest thousand
print(str.strip(str(vert_k),"0"))
