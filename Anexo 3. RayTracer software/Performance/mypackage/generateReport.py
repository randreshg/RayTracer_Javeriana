import platform
import cpuinfo
import os
import pandas as pd
import pdfkit as pdf
currentDirectory = os.getcwd()
from .Comparation import Method1,Method2,Method3

def generatePDF(dframe,tables,softwareTime,hardwareTime,option):
	pd.set_option('colheader_justify', 'center')   # FOR TABLE <th>
	html_string = ""
	if option == 1:
		html_string = '''
		<html>
			<head><title>Performance analysis</title></head>
			<link rel="stylesheet" type="text/css" href="{dirActual}/Performance/Resources/Stylesheet.css"/>
			<link rel="stylesheet" type="text/css" href="{dirActual}/Performance/Resources/df_style.css"/>
			<body> 
			<div>			
				<h1>PERFORMANCE ANALYSIS</h1>
				{Software}
			</div>
			</body>
		</html>.
		'''
		html_string = html_string.format(	Software= getSoftware(dframe,tables,softwareTime),
											dirActual= currentDirectory)
	elif option == 2:
		html_string = '''
		<html>
			<head><title>Performance analysis</title></head>
			<link rel="stylesheet" type="text/css" href="{dirActual}/Performance/Resources/Stylesheet.css"/>
			<link rel="stylesheet" type="text/css" href="{dirActual}/Performance/Resources/df_style.css"/>
			<body> 
			<div>			
				<h1>PERFORMANCE ANALYSIS</h1>
				{Hardware}
			</div>
			</body>
		</html>.
		'''
		html_string = html_string.format(	Hardware= getHardware(hardwareTime),
											dirActual= currentDirectory)
	elif option == 3:
		html_string = '''
		<html>
			<head><title>Performance analysis</title></head>
			<link rel="stylesheet" type="text/css" href="{dirActual}/Performance/Resources/Stylesheet.css"/>
			<link rel="stylesheet" type="text/css" href="{dirActual}/Performance/Resources/df_style.css"/>
			<body> 
			<div>			
				<h1>PERFORMANCE ANALYSIS</h1>
				{Software}
				{Hardware}
				{Comparation}
			</div>
			</body>
		</html>.
		'''
		html_string = html_string.format(	Software= getSoftware(dframe,tables,softwareTime),
											Hardware= getHardware(hardwareTime),
											dirActual= currentDirectory,
											Comparation = getComparation())


	# OUTPUT AN HTML FILE
	htmlDir = currentDirectory + "/Output/Performance/myhtml.html"
	with open(htmlDir, 'w') as f:
		f.write(html_string)
	PdfFilename=currentDirectory +'/Output/Performance/Report.pdf'
	pdf.from_file(htmlDir, PdfFilename)



def getComparation():
	Method1()
	Method2()
	[comE,rms] = Method3()
	comparation_string = '''
		<h3>Computer characteristics</h3>
		<ul>
			<li><p>Método de Histogramas usando OpenCV:
				Como segundo método se emplearon las funciones provistas por la librería de OpenCV para poder determinar los histogramas de las 
				imágenes a evaluar. Para ello después de obtener la imagen se procede a pasar la imagen a escala de grises para posteriormente 
				hallar el histograma.  El histograma utilizado hace referencia a la frecuencia con la que aparecen los distintos niveles de 
				intensidad de una imagen a escala de grises, cuyo rango de intensidad va de 0 a 255, a partir de un histograma también podemos 
				determinar información extra como el brillo, contraste y dinámica de una imagen.
				<img src="{dirActual}/Output/Performance/images/imgMethod2.png" alt="Image 2"> </p></li>
			<li><p>Método de Histogramas en archivo de texto plano:
				El tercer método es muy parecido al anterior ya que cumple el mismo principio de representar una imagen a través de un 
				histograma en donde podemos evaluar la distribución de los distintos niveles de intensidad, pero a diferencia del segundo método, 
				en este tercer método no se lee directamente la imagen sino el archivo en texto plano que contiene toda la información de la 
				imagen.
				<img src="{dirActual}/Output/Performance/images/imgMethod3.png" alt="Image 3"> </p></li>
			<li><p>Método de Comparación Exacta y RMS:
				Para este cuarto método se utilizó la librería de ImageChops la cual nos permite hallar la diferencia entre dos imágenes, 
				así como también sus respectivos histogramas. De este método obtenemos dos resultados importantes, el primero es el valor RMS, 
				para ello se halla la diferencia, posteriormente se obtiene el histograma de la diferencia y a este resultado se procede a 
				calcular su correspondiente valor RMS, entre más cercano sea el valor RMS de la diferencia de las imágenes, más idénticas 
				son entre ellas.  <br>
				El segundo valor que ofrece este método es la diferencia de cada uno de los pixeles de las imágenes más un vector que calcula 
				el cuadro delimitador de las regiones distintas a cero entre las imágenes, entre más cercano sea el valor a cero, más idénticas 
				son las imágenes. De los valores mencionados el que tiene mayor peso es el valor RMS, mientras que la comparación exacta debe 
				analizarse utilizando el primer valor provisto por el método. <br>
				Comparacion exacta = {exactComparation}  <br>
				Valor RMS = {rmsValue}  <br>
		</ul>'''
	comparation_string = comparation_string.format(	dirActual= currentDirectory,
													exactComparation= comE,
													rmsValue= rms)
	return comparation_string
    
    
def getHardware(hardwareTime):
	hardware_string = '''
		<h2>Hardware analysis</h2>
		<p>The process took {Time} seconds to execute</p>
		<p> The image generated by the FPGA is the following one: </p>
		<img src="{dirActual}/Output/Pictures/FPGA.png" alt=""/>	'''
	hardware_string = hardware_string.format(	dirActual= currentDirectory,
												Time= hardwareTime)
	return hardware_string

def getComputerInfo():
	computer_string = '''
		<h3>Computer characteristics</h3>
		<ul>
			<li><p>Computer: {computer}.</p></li>
			<li><p>Operative system: {operativeSystem} </p></li>
			<li><p>Version: {version}.</p></li>
			<li><p>Processor: {processor}</p></li>
			<li><p>CPU: {cpu}</p></li>
		</ul> '''
	computer_string = computer_string.format(	computer= platform.uname()[1],
												operativeSystem= platform.uname()[0],
												version= platform.uname()[2],
												processor= platform.processor(),
												cpu= cpuinfo.get_cpu_info()['brand'])
	return computer_string

def getSoftware(dframe,tables,softwareTime): 
	
	software_string = '''
			<h2>Software analysis</h2>
			{ComputerInfo}
			<p>The process took {Time} seconds to execute</p>
			<img src="{dirActual}/Output/Pictures/file.png" alt=""/>			
			<h3>Table 1</h3>
			<p> This table gives us the following information: </p>
			<ul>
				<li><p>time: the percentage of the total running time of the program used by this function. </p></li>
				<li><p>Accumulative seconds: a running sum of the number of seconds accounted for by this function and those listed above it.</p></li>
				<li><p>Self seconds: the number of seconds accounted for by this function alone. This is the major sort for this listing.</p></li>
				<li><p>Calls: the number of times this function was invoked, if this function is profiled, else blank.</p></li>
				<li><p>Self ms/call: the average number of milliseconds spent in this ms/call function per call, if this function is profiled, else blank.</p></li>
				<li><p>total ms/call: the average number of milliseconds spent in this function and its descendents per call, if this function is profiled, else blank.</p></li>
				<li><p>Name: the name of the function.</p></li>
			</ul>
			<p>Each sample counts as 0.01 seconds.</p>
			{table0}
			<p>To get a better understanding, some table columns were graphed</p>
			<img src="{dirActual}/Output/Performance/images/img1.png" alt="Image 1">
			<img src="{dirActual}/Output/Performance/images/img2.png" alt="Image 2">
			
			<h3>Table 2</h3>
			<p>This table describes the call tree of the program, and was sorted by the total amount of time spent in each function and its children.
			Each entry in this table consists of several lines.  The line with the
			index number at the left hand margin lists the current function.
			The lines above it list the functions that called this function,
			and the lines below it list the functions this one called. 
			This line lists:</p>
			<ul>
				<li><p>index: A unique number given to each element of the table. Index numbers are sorted numerically.
							The index number is printed next to every function name so it is easier to look up where the function is in the table. </p></li>
				<li><p>time:  This is the percentage of the 'total' time that was spent
							in this function and its children.  Note that due to
							different viewpoints, functions excluded by options, etc,
							these numbers will NOT add up to 100%.</p></li>
				<li><p>self:  This is the total amount of time spent in this function.</p></li>
				<li><p>children:  This is the total amount of time propagated into this function by its children.</p></li>
				<li><p>called:  This is the number of times the function was called. If the function called itself recursively, the number
								only includes non-recursive calls, and is followed by
								a '+' and the number of recursive calls.</p></li>
				<li><p>total ms/call: the average number of milliseconds spent in this function and its descendents per call, if this function is profiled, else blank.</p></li>
				<li><p>total ms/call: the average number of milliseconds spent in this function and its descendents per call, if this function is profiled, else blank.</p></li>
				<li><p>Name: the name of the function.</p></li>
			</ul> 
			<p>For the function's parents, the fields have the following meanings:</p>
			<ul>
				<li><p>self		This is the amount of time that was propagated directly from the function into this parent.</p></li>
				<li><p>children	This is the amount of time that was propagated from the function's children into this parent.</p></li>
				<li><p>called	This is the number of times this parent called the function '/' the total number of times the function
								was called.  Recursive calls to the function are not included in the number after the '/'.</p></li>
				<li><p>name		This is the name of the parent.  The parent's index
								number is printed after it.  If the parent is a
								member of a cycle, the cycle number is printed between
								the name and the index number.</p></li>
			</ul> 
		
			<h3>Table 2.1</h3> {table1} <br>
			<h3>Table 2.2</h3> {table2} <br> 
			<h3>Table 2.3</h3> {table3} <br> 
			<h3>Table 2.4</h3> {table4} <br> 
			<h3>Table 2.5</h3> {table5} <br>
			<h3>Table 2.6</h3> {table6} <br>'''
	software_string = software_string.format( 	ComputerInfo= getComputerInfo(),
												Time=softwareTime,
                                                dirActual= currentDirectory,
                                                table0=dframe.to_html(classes='mystyle',index=False),
												table1=tables[0].to_html(classes='mystyle',index=False),
												table2=tables[1].to_html(classes='mystyle',index=False),
												table3=tables[2].to_html(classes='mystyle',index=False),
												table4=tables[3].to_html(classes='mystyle',index=False),
												table5=tables[4].to_html(classes='mystyle',index=False),
												table6=tables[5].to_html(classes='mystyle',index=False),
												table7=tables[6].to_html(classes='mystyle',index=False))
	return software_string
