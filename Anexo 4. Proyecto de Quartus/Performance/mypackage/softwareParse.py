import matplotlib.pyplot as plt
import pdfkit as pdf
import pandas as pd

def parseInfo1(data,functionName,functionShortName):
	column = getHeader1(data)
	line = data.readline()
	line = data.readline()
	counter = 0
	tableArray = {}
	table = pd.DataFrame()
	while counter < 7:
		if line != '-----------------------------------------------\n':
			if line.split()[0].find('[') != -1:
				try:
					float(line.split()[4])
					line = getRow1(line,5)
					df = pd.DataFrame(data = [[line[0],line[1],line[2],line[3],line[4],line[5]]],columns=column)
				except:
					line = getRow1(line,4)
					df = pd.DataFrame(data = [[line[0],line[1],line[2],line[3],'',line[4]]],columns=column)
			else:
				try:
					line = getRow1(line,3)
					df = pd.DataFrame(data = [['','',line[0],line[1],line[2],line[3]]],columns=column)
				except:
					pass
			table = table.append(df,ignore_index=True)
		else:
			table = changeName(table,functionName,functionShortName)
			tableArray[counter] = table
			table = pd.DataFrame()
			counter = counter + 1
		line = data.readline()
	return tableArray
	
def parseInfo(data,functionName,functionShortName):
    column = getHeader(data)
    dframe = pd.DataFrame(columns=column)
    line = data.readline()
    while line != "\n":
        try:
            line = getRow(line,6)
            df = pd.DataFrame(data = [line[0:7]],columns=column)
            dframe = dframe.append(df,ignore_index=True)
        except:
            pass
        line = data.readline()
    #Filter functions
    dframe = dataFrameByList(dframe,functionName)
    #Convert to float
    for i in range (0,dframe.shape[1]):
        try:
            dframe.iloc[:,i] = dframe.iloc[:,i].astype(float)
        except:
            pass
    dframe = dframe.infer_objects()
    dframe = changeName(dframe,functionName,functionShortName)
    return dframe

def changeName(df,dataList,dataChange):
    for i, data in enumerate(dataList):
        df.loc[df.name == data,'name'] = dataChange[i]
    return df

def dataFrameByList(df,dataList):
    dframe = pd.DataFrame()
    for data in dataList:
        aux = df[df.name == data]
        dframe = dframe.append(aux)
    return dframe

def getHeader(data):
    line = data.readline()
    while line:
        column = line.split()
        try:
            if column[0] == "time":
                column[0] = "Time"
                column[1] = "Accumulative seconds"
                column[2] = "Self seconds"
                return column
        except:
            pass
        line = data.readline()

def getHeader1(data):
    line = data.readline()
    while line:
        column = line.split()
        try:
            if column[0] == "index":
                column[0] = column[0]
                column[1] = column[1] + " " + column[2]
                column[2] = column[3]
                column[3] = column[4]
                column[4] = column[5]
                column[5] = column[6]
                return column[0:6]
        except:
            pass
        line = data.readline()

def getRow(line,itr):
    line = line.split()
    newData = ""
    for index, value in enumerate(line):
        if index >= itr:
            newData = newData + value + " "
    line[itr] = newData
    return line

def getRow1(line,itr):
    line = line.split()
    newData = ""
    for index, value in enumerate(line):
        if index >= itr and index < len(line)-1:
            newData = newData + value + " "
    line[itr] = newData
    return line

