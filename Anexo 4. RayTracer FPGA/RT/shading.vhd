---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.ALL;

----------------------------------------------------------
ENTITY shading IS
	GENERIC(	delay					: INTEGER := 10;
				sqrtDelay			: INTEGER := 16;
				multiplierDelay 	: INTEGER := 5;
				adderDelay			: INTEGER := 7;
				invsqrtDelay		: INTEGER := 26;
				dotPointDelay     : INTEGER := 20;
				conversionDelay   : INTEGER := 20);
	PORT	 (	clock   				: IN  STD_LOGIC;
				rst					: IN  STD_LOGIC;
				shade					: IN  STD_LOGIC;
				enable				: IN  STD_LOGIC;
				prm					: IN  STD_LOGIC;
				p						: IN  VECTOR;
				m						: IN  FLOAT;
				v						: IN  VECTOR;
				light					: IN  VECTOR;
				center				: IN  VECTOR;
				colorOut				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				done					: OUT STD_LOGIC;
				takeData				: OUT STD_LOGIC);	
				
END shading;

ARCHITECTURE shading_arch OF shading IS
	--Accumulated delay
	CONSTANT delayFirstStep	 	: INTEGER:= adderDelay + adderDelay + multiplierDelay;
	CONSTANT delaySecondStep 	: INTEGER:= dotPointDelay + invsqrtDelay + multiplierDelay + delayFirstStep;											
	CONSTANT delayThirdStep	 	: INTEGER:=  dotPointDelay + delaySecondStep;
	CONSTANT delayFourthStep	: INTEGER:=  multiplierDelay + delayThirdStep;
	CONSTANT pipelineDelay	 	: INTEGER:=  multiplierDelay + adderDelay;
	CONSTANT finalDelay			: INTEGER:= (delayFourthStep +conversionDelay);
	
	--Delay signals
	--L delay
	TYPE   data1 IS ARRAY (pipelineDelay DOWNTO 0) OF VECTOR;
	SIGNAL lDelay : data1;
	--prm delay
	TYPE   data2 IS ARRAY (delayFirstStep DOWNTO 0) OF STD_LOGIC;
	SIGNAL prmDelay : data2;
	--agb delay
	CONSTANT delayAgb : INTEGER := multiplierDelay + conversionDelay -1;
	TYPE   data3 IS ARRAY (delayAgb DOWNTO 0) OF STD_LOGIC;
	SIGNAL agbDelay : data3;
	--SHADE delay
	TYPE   data4 IS ARRAY (delay DOWNTO 0) OF STD_LOGIC;
	SIGNAL shadeDelay : data4;
	--SIGNALS
	----Primitive normal
	SIGNAL Ns,Nc,N,L	    	: VECTOR;
	----Normalize vector
	SIGNAL Nunit,Lunit		: VECTOR;
	----Diffuse component
	SIGNAL color,color1		: FLOAT;
	SIGNAL agb					: STD_LOGIC;
	----Conversion
	SIGNAL intColor			: STD_LOGIC_VECTOR(8 DOWNTO 0);
	----Pipeline counter
	SIGNAL max_tickPP			: STD_LOGIC;
	SIGNAL pipelineEna		: STD_LOGIC;

		
BEGIN
	pipelineEna <= (NOT max_tickPP) AND enable;
	-----------------------------------------Pipeline counter--------------------------------------------------
	ppCounter: 	ENTITY WORK.counterTick  	GENERIC MAP (delay)
														PORT MAP	   (clock,rst,pipelineEna,max_tickPP);
													
	-----------------------------------------Primitive normal--------------------------------------------------
	LVector: 	ENTITY WORK.vectorSum		PORT MAP		('0',clock,light,p,L);
	Nsphere:    ENTITY WORK.sphereNormal   GENERIC MAP (pipelineDelay)
														PORT MAP		(clock,p,center,Ns);															
	Ncylinder:  ENTITY WORK.cylinderNormal GENERIC MAP (adderDelay,multiplierDelay)
														PORT MAP		(clock,p,m,v,center,Nc);												
	N <= Nc WHEN prmDelay(delayFirstStep) ='1' 	ELSE Ns;
	----------------------------------------Normalize vector----------------------------------------------------
	NormalN: 	ENTITY WORK.normalVector  	GENERIC MAP (adderDelay,dotPointDelay,invsqrtDelay)
														PORT MAP		(clock,N,Nunit); 			 
	NormalL: 	ENTITY WORK.normalVector  	GENERIC MAP (adderDelay,dotPointDelay,invsqrtDelay)
														PORT MAP		(clock,lDelay(pipelineDelay),Lunit);
  ----------------------------------------Diffuse component----------------------------------------------------
	colorCalc:  ENTITY WORK.dotPointDelay 	GENERIC MAP (adderDelay)
														PORT MAP(clock,Nunit,Lunit,color);
	grtThan: 	ENTITY WORK.greaterThan 	PORT MAP(clock,color,zeros,agb);
	------------------------------------------Color scale-------------------------------------------------------	
	mult1_x:  	ENTITY WORK.multiplier 		PORT MAP(clock,color,X"437f0000",color1);
	------------------------------------From Float to 8bit Integer----------------------------------------------
	conv1: 		ENTITY WORK.converter 		PORT MAP(clock,color1,intColor);
	----------------------------------------Output--------------------------------------------------------------
	colorOut <= intColor(7 DOWNTO 0) WHEN agbDelay(delayAgb) = '1' ELSE background;
	takeData <= shadeDelay(delay);
	done 		<= max_tickPP;
	-----------------------------------------------Delays-------------------------------------------------------											
	--L delay
	lDelay(0) <= L;
	delays1: FOR i IN 1 TO pipelineDelay
		GENERATE		
			dly1 : ENTITY WORK.vectorRegister PORT MAP(clock,rst,enable,lDelay(i-1),lDelay(i));
		END GENERATE;
	--Prm delay
	prmDelay(0) <= prm;
	delays2: FOR i IN 1 TO delayFirstStep
		GENERATE		
			dly2 : ENTITY WORK.bitRegister 	PORT MAP(clock,rst,enable,prmDelay(i-1),prmDelay(i));
		END GENERATE;
	--Comparation delay
	agbDelay(0) <= agb;
	delays3: FOR i IN 1 TO delayAgb
		GENERATE		
			dly3:  ENTITY WORK.bitRegister 	PORT MAP(clock,rst,enable,agbDelay(i-1),agbDelay(i));
		END GENERATE;
	--Comparation delay
	shadeDelay(0) <= shade;
	delays4: FOR i IN 1 TO delay
		GENERATE		
			dly4:  ENTITY WORK.bitRegister 	PORT MAP(clock,rst,enable,shadeDelay(i-1),shadeDelay(i));
		END GENERATE;
END shading_arch;