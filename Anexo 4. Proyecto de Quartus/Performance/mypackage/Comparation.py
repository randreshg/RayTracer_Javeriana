import os
import cv2
import numpy as np
import matplotlib.pyplot as plt
currentDirectory = os.getcwd();
softwarePath = currentDirectory+'/Output/Pictures/file.ppm'
hardwarePath = currentDirectory+'/Output/Pictures/FPGA.ppm'

softwarePath1 = currentDirectory+'/Output/Pictures/file.png'
hardwarePath1 = currentDirectory+'/Output/Pictures/FPGA.png'

def Method1():
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
    
    #Image Characteristics
    imageMeanS = np.mean(listS)
    imageStandardDS = np.std(listS)
    imageMeanH = np.mean(listH)
    imageStandardDH = np.std(listH)
    
    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111) 
    # Set the axis lables
    ax.set_xlabel('Pixels', fontsize = 18)
    ax.set_ylabel('Grey Scale', fontsize = 18)
    # X axis is day numbers from 1 to 921600
    xaxis = np.array(range(1,307200))
    # Line color for error bar
    colorS = 'red'
    colorH = 'darkgreen' 
    # Line style for each dataset
    lineStyleS={"linestyle":"--", "linewidth":2, "markeredgewidth":2, "elinewidth":2, "capsize":3}
    lineStyleH={"linestyle":"-", "linewidth":2, "markeredgewidth":2, "elinewidth":2, "capsize":3}
    # Create an error bar for each dataset
    lineimgS=ax.errorbar(xaxis, listS, yerr=imageStandardDS, **lineStyleS, color=colorS, label='ImagenS')
    lineimgH=ax.errorbar(xaxis, listH, yerr=imageStandardDH, **lineStyleH, color=colorH, label='ImagenH')
    
    lineimgS2=ax.errorbar(xaxis, listS, yerr=imageMeanS, **lineStyleS, color=colorS, label='ImagenS')
    lineimgH2=ax.errorbar(xaxis, listH, yerr=imageMeanH, **lineStyleH, color=colorH, label='ImagenH')
    # Label each dataset on the graph, xytext is the label's position 
    for i, txt in enumerate(listS):
            ax.annotate(txt, xy=(xaxis[i], listS[i]), xytext=(xaxis[i]+0.03, listS[i]+0.3),color=colorS)
    
    for i, txt in enumerate(listH):
            ax.annotate(txt, xy=(xaxis[i], listH[i]), xytext=(xaxis[i]+0.03, listH[i]+0.3),color=colorH)
            
    
    # Draw a legend bar
    plt.legend(handles=[lineimgS, lineimgH], loc='upper right')
    plt.legend(handles=[lineimgS2, lineimgH2], loc='upper right')
    # Customize the tickes on the graph
    plt.xticks(xaxis)               
    plt.yticks(np.arange(20, 47, 2))
    
    # Customize the legend font and handle length
    params = {'legend.fontsize': 13,
              'legend.handlelength': 2}
    plt.rcParams.update(params)
    
    # Customize the font
    font = {'family' : 'Arial',
            'weight':'bold',
            'size'   : 12}
    matplotlib.rc('font', **font)
    
    # Draw a grid for the graph
    ax.grid(color='lightgrey', linestyle='-')
    ax.set_facecolor('w')
    
    plt.show()
    plt.savefig('Output//Performance//images//imgMethod1.png')
    cv2.waitKey(0)
    
def Method2():
    #Open Image
    imgS = cv2.imread(softwarePath)
    imgH = cv2.imread(hardwarePath)
    #Convertion to GrayScale
    gScaleS = cv2.cvtColor(imgS,cv2.COLOR_RGB2GRAY)
    gScaleH = cv2.cvtColor(imgH,cv2.COLOR_RGB2GRAY)
    #Histograms Calculation
    hSoftware = cv2.calcHist([gScaleS],[0],None,[256],[0,255])
    hHardware = cv2.calcHist([gScaleH],[0],None,[256],[0,255])
    #Plot Histograms
    fig=plt.figure(1)
    pl1=fig.add_subplot(311)
    pl1.plot(hSoftware)
    plt.title('Histrograma de la Imagen en Software')
    plt.xlabel('Intensidad')
    plt.ylabel('Cantidad de Pixeles')
    fig=plt.figure(1)
    pl1=fig.add_subplot(313)
    pl1.plot(hHardware)
    plt.title('Histrograma de la Imagen en Hardware')
    plt.xlabel('Intensidad')
    plt.ylabel('Cantidad de Pixeles')
    fig.show()
    plt.savefig('Output//Performance//images//imgMethod2.png')
    cv2.waitKey(0)

def Method3():
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
    plt.xlabel('Intensidad')
    plt.ylabel('Cantidad de Pixeles')
    plt.title('Comparación de Imágenes en Software y Hardware')
    plt.hist([listS,listH],rwidth=0.95,color=['red','blue'],label=['Software','Hardware'])
    plt.legend()
    plt.savefig('Output//Performance//images//imgMethod3.png')

def Method4():
    imSoftware = Image.open(softwarePath1)
    imHardware = Image.open(hardwarePath1)
    h = ImageChops.difference(imSoftware, imHardware).histogram()
    comE = ImageChops.difference(imSoftware, imHardware).getbbox()
    rms = math.sqrt(reduce(operator.add,map(lambda h, i: h*(i**2), h, range(256))) / (float(imSoftware.size[0]) * imSoftware.size[1]))
    return [comE,rms]