---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;

----------------------------------------------------------
ENTITY primaryRay IS
	GENERIC(	xResolution		: INTEGER := 15;
				yResolution		: INTEGER := 10;
				delay				: INTEGER := 100;
				adderDelay	 	: INTEGER := 7;
				dotPointDelay 	: INTEGER := 5;
				invsqrtDelay	: INTEGER := 7);
	PORT	 (	enable			: IN  STD_LOGIC;
				clock   			: IN  STD_LOGIC;
				rst				: IN  STD_LOGIC;				
				scan				: IN  VECTOR;
				observer			: IN  VECTOR;
				pixelWidth		: IN  VECTOR;
				pixelHeight		: IN  VECTOR;
				I					: IN  FLOAT;
				J					: IN  FLOAT;	
				ray				: OUT VECTOR;
				done				: OUT STD_LOGIC);
END primaryRay;

ARCHITECTURE primaryRay_arch OF primaryRay IS
	--Signals
	SIGNAL yPixel		  	: VECTOR; 	--PixelWidth*j
	SIGNAL xPixel		  	: VECTOR; 	--PixelHeight*i
	SIGNAL result1  		: VECTOR;	--(Scan + PixelWidth*j)
	SIGNAL result2  		: VECTOR;	--(Scan + PixelWidth*j) - PixelHeight*i
	SIGNAL resultR  		: VECTOR;	--((Scan + PixelWidth*j) - PixelHeight*i)-observer
	SIGNAL Runit	 		: VECTOR;
	--Pipeline counter signals
	SIGNAL max_tickPP		: STD_LOGIC;
	SIGNAL pipelineEna	: STD_LOGIC;

BEGIN
	
	-----------------------------------------------------PIPELINE COUNTER------------------------------------------------------------------	
	-------------------------Pipeline counter----------------------------------
	--Takes the time to get the first result
	ppCounter: ENTITY WORK.counterTick  			GENERIC MAP(delay)
																PORT MAP	  (clock,rst,pipelineEna,max_tickPP);																
	--Enables pipeline counter
	pipelineEna <= (NOT max_tickPP) AND enable;
	
	-----------------------------------------------------RAY GENERATION--------------------------------------------------------------------
	---------------------------Ray generation----------------------------------
	--Does the math to get the ray
	PixelHxI: ENTITY WORK.scalarProduct 	PORT MAP(clock,I,pixelHeight,xPixel);
	PixelWxJ: ENTITY WORK.scalarProduct 	PORT MAP(clock,J,pixelWidth,yPixel);
	RayADD  : ENTITY WORK.vectorSum	   	PORT MAP('0',clock,yPixel,xPixel,result1);									
	RaySUB  : ENTITY WORK.vectorSum	   	PORT MAP('1',clock,scan,result1,result2);
	RayR	  : ENTITY WORK.vectorSum	   	PORT MAP('0',clock,result2,observer,resultR);			
	normalV : ENTITY WORK.normalVector  	GENERIC MAP(adderDelay,dotPointDelay,invsqrtDelay)
														PORT MAP(clock,resultR,Runit);
	
	----------------------------------------------------------OUTPUT-----------------------------------------------------------------------	
	ray <= Runit WHEN max_tickPP = '1' ELSE zero;
	done <= max_tickPP;
	
END primaryRay_arch;
