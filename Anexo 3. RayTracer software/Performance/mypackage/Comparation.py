import os
import cv2
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image, ImageChops
import math
from functools import reduce
import operator
currentDirectory = os.getcwd();
softwarePath = currentDirectory+'/Output/Pictures/file.ppm'
hardwarePath = currentDirectory+'/Output/Pictures/FPGA.ppm'

softwarePath1 = currentDirectory+'/Output/Pictures/file.png'
hardwarePath1 = currentDirectory+'/Output/Pictures/FPGA.png'
  
def Method1():
    #Open Image
    imgS = cv2.imread(softwarePath)
    imgH = cv2.imread(hardwarePath)
    #Convertion to GrayScale
    gScaleS = cv2.cvtColor(imgS,cv2.COLOR_RGB2GRAY)
    gScaleH = cv2.cvtColor(imgH,cv2.COLOR_RGB2GRAY)
    #Histograms Calculation
    hSoftware = cv2.calcHist([gScaleS],[0],None,[256],[0.001,255])
    hHardware = cv2.calcHist([gScaleH],[0],None,[256],[0.001,255])
    #Plot Histograms
    fig=plt.figure(1)
    pl1=fig.add_subplot(312)
    pl1.plot(hSoftware, label='Software')
    pl1.plot(hHardware, label='Hardware')
    plt.title('Histrogram of Software Image vs Hardware Image')
    plt.xlabel('Intensity')
    plt.ylabel('Pixel Quantity')
    plt.savefig('Output//Performance//images//imgMethod2.png')
    leg=plt.legend()
    plt.close()
    cv2.waitKey(0)

def Method2():
    #Image Dataset
    textS = open(softwarePath,'r')
    textH = open(hardwarePath,'r')
    infoS = textS.readlines()
    infoH = textH.readlines()
    #Hardware Variables
    infoH.pop(0)
    infoH.pop(0)
    infoH.pop(0)
    infoH.pop()
    listHA=[]
    listHAux=[]
    listH=[]
    #Software Variables
    infoS.pop(0)
    infoS.pop(0)
    infoS.pop(0)
    infoS.pop()
    listSA=[]
    listSAux=[]
    listS=[]
    #Hardware Preparation
    for line in infoH:
        splitH = line.rstrip('\n')
        listHA.append(splitH)
    for i in listHA:
        listHAux = i.split(' ')
        listH1 = [ int(x) for x in listHAux ]
        auxH=sum(listH1)/len(listH1)
        listH.append(auxH)
    #Hardware Preparation
    for line in infoS:
        splitS = line.rstrip('\n')
        listSA.append(splitS)
    for j in listSA:
        listSAux = j.split(' ')
        listS1 = [ int(x) for x in listSAux ]
        auxS=sum(listS1)/len(listS1)
        listS.append(auxS)
    #Histrogam of the Dataset
    plt.xlabel('Intensity')
    plt.ylabel('Pixel Quantity')
    plt.title('Comparison between Software and Hardware Images')
    plt.hist([listS,listH],rwidth=0.95,color=['red','blue'],label=['Software','Hardware'])
    plt.legend()
    plt.savefig('Output//Performance//images//imgMethod3.png')
    plt.close()

def Method3():
    imSoftware = Image.open(softwarePath1)
    imHardware = Image.open(hardwarePath1)
    diff = ImageChops.difference(imSoftware, imHardware)
    plt.figure(1)
    plt.imshow(diff)
    plt.xlabel('Pixel Quantity')
    plt.ylabel('Pixel Quantity')
    plt.title('Difference between the Software and Hardware Images')
    plt.savefig('Output//Performance//images//diffMethod4.png')
    plt.close()
    plt.figure(2)
    h = diff.histogram()
    plt.xlabel('Intensity')
    plt.ylabel('Pixel Quantity')
    plt.title('Histogram of the difference between the Software and Hardware Images')
    plt.plot(h)
    plt.savefig('Output//Performance//images//histMethod4.png')
    plt.close()
    comE = ImageChops.difference(imSoftware, imHardware).getbbox()
    rms = math.sqrt(reduce(operator.add,map(lambda h, i: h*(i**2), h, range(256))) / (float(imSoftware.size[0]) * imSoftware.size[1]))
    return [comE,rms]