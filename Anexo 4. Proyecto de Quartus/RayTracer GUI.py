#Libraries definition
from tkinter import ttk,Tk,Button,Label,Frame,IntVar,Checkbutton,StringVar,Toplevel,Canvas,PhotoImage
from tkinter.ttk import Style,Button
from tkinter import filedialog as FileDialog
from tkdocviewer import DocViewer
import serial.tools.list_ports
from io import open
import subprocess
import serial
import time
import cv2
import os
import struct
from PIL import Image, ImageTk, ImageChops
from glob import glob 
from Performance.performance import performanceReport

currentDirectory = os.getcwd();
#Definición de Funciones y selfs
class RayTracerGUI:
    def __init__(self):
        self.GUI = Tk()
        #View Image
        self.img = None
        #Scene info
        self.scenePath = ""
        self.sceneInfo = []
        self.sceneName = ""
        self.sceneFileName= StringVar()
        #Option
        self.software = IntVar()
        self.softwareTime = None
        self.hardwareTime = None
        self.hardware = IntVar()
        self.report = IntVar()
        self.com = None
        self.portName = None
        #Serial
        self.port = None
        self.portLabel = None
        self.portList = None
        #Frame positions
        self.frame1 = 0
        self.frame2 = 150
        self.frame3 = 300
        #GUI Font
        self.labelFont = ('Times',12)
        self.iLabelFont = ('Times',12,'italic')
        self.labelHeaderFont = ('Times',12,'bold')
        self.buttonFont = ('Times',9,'bold italic')
        
    def pick(self): #Permite abrir el documento de texto donde se encuentra la información
        self.scenePath = FileDialog.askopenfilename(initialdir='.', 
                                               filetypes=(("Scenes NFF", "*.nff"),),
                                               title="Open .nff file")
        try:
            sf = self.scenePath.split('/')
            fileName = sf[-1]
            sn = fileName.split(".")
            if sn[-1] == 'nff':
                self.sceneName = sn[0]
                self.updatesceneFileName(fileName)
                scene = open(self.scenePath, 'r')
                self.sceneInfo = scene.readlines()
                scene.close()
        except:
            pass
        
    def popup(self,msg):
        win = Toplevel(self.GUI)
        win.wm_title("Info")
        l = Label(win, text= msg)
        l.grid(row=0, column=0)
        b = ttk.Button(win, text="OK", command=win.destroy)
        b.grid(row=1, column=0)
    
    def openImage(self):
        #Open Image
        imgSoft = cv2.imread('Output/Pictures/file.png')
        cv2.imshow("Software image", imgSoft)

    def sendInfo(self):
        try:
            print("Sending info")
            scene = open('Output/FPGA.txt', 'r')
            info = scene.readline()
            try:
                self.port = serial.Serial(self.com,57600,timeout=20)
                aux = 0
                rint = 0
                while info:                    
                    time.sleep(0.5)
                    line = info.split()
                    for x in line:
                        if aux == 1:
                            aux = 0
                            self.port.write(rint)
                        else:
                            try:
                                rs = bytearray(struct.pack("f", float(x)))
                            except:
                                rs = bytearray(x,'utf-8')                                                              
                                if(x == 'C' or x=='S' or x=='O' or x=='E' or x=='L'):
                                    aux = 0
                                else:
                                    num = int(line[1])
                                    rint = num.to_bytes(1, byteorder ='big')                             
                                    aux = 1
                            try:
                                self.port.write(rs)                                
                            except serial.SerialException:
                                self.popup('Port is not available')                    
                    print("ENTRA CON: " + info)
                    info = scene.readline()
                print("SALE")
                self.popup("Scene info sent!")
            except serial.SerialException:
                self.popup("Couldn't open port")
            scene.close()
        except serial.SerialException:
            self.popup("Couldn't find 'Output/FPGA.txt'")
        
    def getImage(self):
        #Receive time info
        mills = self.port.read()
        hundredth = self.port.read()
        ten = self.port.read()
        unity = self.port.read()
        
        mills = int.from_bytes(mills, byteorder='big')
        hundredth = int.from_bytes(hundredth, byteorder='big')
        unity = int.from_bytes(unity, byteorder='big')
        ten = int.from_bytes(ten, byteorder='big')
        totalTime = mills/1000 + hundredth/100 + ten/10 + unity        
        self.hardwareTime = str(totalTime)
        print(self.hardwareTime)
        
        #Receive pixel info
        size = 640*480
        iterator = 0        
        img = []
        while iterator <size:
            img.append (self.port.read())
            iterator = iterator + 1       
        
        text = open('Output/Pictures/FPGA.ppm','w')
        text.write('P3 \n')
        text.write('640 480\n')
        text.write('255\n')
        for info in img:
            data = int.from_bytes(info, byteorder='big')
            text.write(str(data)+ " "+ str(data) + " " + str(data) + '\n')
        text.close()
        print("ACABA")
        self.port.close()
        #Convert to PNG
        imS = glob("Output/Pictures/FPGA.ppm")
        for ppm in imS: 
            cv2.imwrite("Output/Pictures/FPGA.png", cv2.imread(ppm))
   
    def updatesceneFileName(self,txt):
        (self.sceneFileName).set(txt)

    def hardwareAction(self):
        self.getCOM()
        self.softwareAction(4)
        self.sendInfo()
        self.getImage()
    
    def getPorts(self):
        #Detección del Puerto Serial
        comList = serial.tools.list_ports.comports()
        portName = []
        portDevice = []
        for element in comList:
            portName.append(element.description)
            portDevice.append(element.device)
        return [portName, portDevice]

    def getCOM(self,event=None): 
        [portNames, portDevices] = self.getPorts()
        self.portName = self.portList.get()
        try:
            indexPosition = portNames.index(self.portName) 
            self.com = portDevices[indexPosition]
        except:
            pass

    def showAvaliablePorts(self):
        #Set avaliable ports at RayTracerGUI
        if(self.hardware.get() or self.report.get()):
            self.portLabel=Label(self.GUI,font=self.iLabelFont,text="Select port")
            self.portLabel.place(x=40,y=self.frame2+120)
            self.portList=ttk.Combobox(self.GUI,state="readonly")
            self.portList.place(x=160,y=self.frame2+120)
            portNames = self.getPorts()[0]
            self.portList["values"] = portNames
        else:
            try:
                self.portList.destroy()
                self.portLabel.destroy()
            except:
                pass
    
    def softwareAction(self,option):
        print(self.sceneName)
        command = "main.exe " + self.sceneName + " " + str(option) 
        returned = subprocess.check_output(command,shell=True)       
        if(option != 4):
            self.softwareTime = str(returned.split()[5])[2:-1]
            #Convert to PNG
            imS = glob("Output/Pictures/file.ppm")
            for ppm in imS: 
                cv2.imwrite("Output/Pictures/file.png", cv2.imread(ppm))
            self.popup(returned)
            
    def openReport(self):
        reportPath = currentDirectory+"/Output/Performance/Report.pdf"
        subprocess.Popen(reportPath,shell=True)
        
    def run(self): 
        if len(self.sceneInfo) != 0:
            if(self.software.get() and self.report.get() and self.hardware.get()):
                 self.softwareAction(3)
                 subprocess.check_call("gprof main.exe gmon.out > Output/Performance/reporte.txt ",shell=True)
                 performanceReport(self.softwareTime,self.hardwareTimem,1)
            elif (self.software.get()):
                if(self.report.get()):
                    self.softwareAction(1)
                    subprocess.check_call("gprof main.exe gmon.out > Output/Performance/reporte.txt ",shell=True)
                    performanceReport(self.softwareTime,self.hardwareTime,1)
                else:
                    self.softwareAction(1)
            elif (self.hardware.get()):
                self.hardwareAction()
            elif (self.hardware.get() and self.software.get()):
                self.hardwareAction()
                self.softwareAction(1)
            else:
                self.popup("Select an option first")
        else:
            self.popup("Select a scene first")

    def initializeGUI(self):
        #Screen settings
        self.GUI.title("RayTracerGUI")
        self.GUI.geometry("380x350")
        self.GUI.configure()
        myFrame=Frame(self.GUI)
        myFrame.pack()
        myFrame.config(width=380,height=40)
        #Set labels
        self.updatesceneFileName("None")
    
        Label(self.GUI,font=('Times',16,'bold'),text="RAYTRACER GUI").place(x=100,y=self.frame1+10)
        Label(self.GUI,font=self.labelFont,text="Pick Scene").place(x=80,y=self.frame1+ 60)
        Label(self.GUI,font=self.labelFont,text="Scene selected:").place(x=80,y=self.frame1+100)
        Label(self.GUI,font=self.labelFont,textvariable=self.sceneFileName).place(x=200,y=self.frame1+100)
        Label(self.GUI,font=self.labelHeaderFont,text="SELECT OPTION").place(x=40,y=self.frame2)
        Label(self.GUI,font=self.labelFont,text="Software").place(x=40,y=self.frame2+30)
        Label(self.GUI,font=self.labelFont,text="Hardware").place(x=40,y=self.frame2+60)
        Label(self.GUI,font=self.labelFont,text="Report").place(x=40,y=self.frame2+90)
        #Set check button
        Checkbutton(self.GUI,variable=self.software,onvalue=1,offvalue=0).place(x=150,y=self.frame2+30)
        Checkbutton(self.GUI,variable=self.hardware,onvalue=1,offvalue=0,command=self.showAvaliablePorts).place(x=150,y=self.frame2+60)
        Checkbutton(self.GUI,variable=self.report,onvalue=1,offvalue=0).place(x=150,y=self.frame2+90)
        style = Style() 
        style.configure('TButton', font = ('calibri', 8, 'bold italic'),foreground = 'black') 
        #Set buttons
        Button(self.GUI,style='TButton',text="Pick",width=5,command=self.pick).place(x=200,y=self.frame1+60)
        Button(self.GUI,style='TButton',text="Open",width=5,command=self.openReport).place(x=230,y=self.frame2+90)
        Button(self.GUI,style='TButton',text="View image",width=11,command=self.openImage).place(x=230,y=self.frame2+40)
        Button(self.GUI,style='TButton',text="RUN",width=5,command=self.run).place(x=160,y=self.frame3)	
        #Create software object
        subprocess.check_call("g++ -Wall -pg RayTracer/main.cpp -o main.exe",shell=True)

def my_main():
    rayTracer = RayTracerGUI()
    rayTracer.initializeGUI()
    rayTracer.GUI.mainloop()

if __name__ == "__main__":
    my_main()
