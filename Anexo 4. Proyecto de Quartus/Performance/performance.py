#Performance.py
import cv2
import platform
import pandas as pd
from glob import glob 
import matplotlib.pyplot as plt
from .mypackage.generateReport import generatePDF
from .mypackage.softwareParse import parseInfo, parseInfo1

#Get data
def performanceReport(softwareTime,hardwareTime,option):
    functions = pd.read_excel('Performance//Resources//Functions.xlsx')
    functionName = functions['FUNCTIONS'].values.tolist()
    functionShortName = functions['SHORT NAME'].values.tolist()
    data = open("Output//Performance//reporte.txt","r")
    #Parse info
    dframe = parseInfo(data,functionName,functionShortName)
    tables = parseInfo1(data,functionName,functionShortName)
    
    #Plot
    dframe.plot(x ='name', y='calls',kind = 'bar')
    plt.tight_layout()
    plt.savefig('Output//Performance//images//img1.png')
    dframe.plot(x ='name', y='Self seconds',kind = 'bar')
    plt.tight_layout()
    plt.savefig('Output//Performance//images//img2.png')
    generatePDF(dframe,tables,softwareTime,hardwareTime)