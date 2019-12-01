---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------
ENTITY raytracing IS
	GENERIC(	maxPrm				: INTEGER := 10;
				colorBits			: INTEGER := 8;
				xResolution			: INTEGER := 15;
				yResolution			: INTEGER := 11;
				--FloatingPoint pipelines
				invsqrtDelay		: INTEGER := 26;
				sqrtDelay			: INTEGER := 16;				
				multiplierDelay 	: INTEGER := 5;
				adderDelay			: INTEGER := 7;
				conversionDelay	: INTEGER := 6;
				comparationTime	: INTEGER := 3;
				divisionDelay		: INTEGER := 6);
	PORT	 (	enable				: IN  STD_LOGIC;
				clock   				: IN  STD_LOGIC;
				rst					: IN  STD_LOGIC;
				prmTI					: IN  PRIMITIVE;
				prmTypeTI			: IN  STD_LOGIC;
				prmSH					: IN  PRIMITIVE;
				prmTypeSH			: IN  STD_LOGIC;
				prmSize				: IN  INTEGER RANGE 0 TO (maxPrm-1);
				light					: IN  VECTOR;
				origin				: IN	VECTOR;
				pixelWidth	 		: IN	VECTOR;
				pixelHeight	 		: IN	VECTOR;
				scan			 		: IN	VECTOR;
				idTI					: OUT INTEGER RANGE 0 TO (maxPrm-1);
				idSH					: OUT INTEGER RANGE 0 TO (maxPrm-1);
				color					: OUT STD_LOGIC_VECTOR (colorBits-1 DOWNTO 0);
				colorDone			: OUT STD_LOGIC;
				takeData				: OUT STD_LOGIC);
END raytracing;

ARCHITECTURE raytracing_arch OF raytracing IS	
	--RAYTRACING
	SIGNAL rtEnable			   : STD_LOGIC;
	--BLOCK ENABLE
	SIGNAL rayGen,rayInt			: STD_LOGIC;
	SIGNAL minDst		 			: STD_LOGIC;
	--SCREEN ITERATOR
	----Ray frequency
	SIGNAL addPixel				: STD_LOGIC;
	SIGNAL rayCount				: INTEGER RANGE 0 TO (maxPrm-1);
	SIGNAL I,J						: FLOAT;
	SIGNAL screenDone,beginRT	: STD_LOGIC;	
	--SCENE
	SIGNAL centerTI,vTI			: VECTOR;
	SIGNAL rTI,mMaxTI				: FLOAT;
	SIGNAL CbSH,vSH,centerSH  	: VECTOR;
	SIGNAL rSH,mMaxSH				: FLOAT;
	--RAY GENERATION
	SIGNAL rayGenEnable			: STD_LOGIC;
	----Primary ray
	SIGNAL Rdir						: VECTOR;
	SIGNAL rayDone 				: STD_LOGIC;
	--TEST INTERSECTION
	SIGNAL rayIntEnable			: STD_LOGIC;
	SIGNAL m							: FLOAT;
	SIGNAL p  						: VECTOR;
	----Primitive iterator
	SIGNAL maxTickIdTI			: STD_LOGIC;
	----Test intersection
	SIGNAL distance				: FLOAT;
	SIGNAL distDone				: STD_LOGIC;
	--MINIMUM DISTANCE
	SIGNAL minDstEnable			: STD_LOGIC;
	----Primitive iterator
	SIGNAL maxTickPrimID			: STD_LOGIC;
	SIGNAL idPrm					: INTEGER RANGE 0 TO (maxPrm-1);
	----Min distance
	SIGNAL minM						: FLOAT;
	SIGNAL minP						: VECTOR;
	SIGNAL shade					: STD_LOGIC;
	--SHADING
	SIGNAL shadeEnable			: STD_LOGIC;
	----Primitive iterator
	SIGNAL maxTickIdSH			: STD_LOGIC;
	--AUXILIAR
	----Operations pipelines
	CONSTANT dotPointDelay		: INTEGER := multiplierDelay + adderDelay + adderDelay;
	CONSTANT vectorSumDelay		: INTEGER := adderDelay;
	CONSTANT scalaProductDelay	: INTEGER := multiplierDelay;
	CONSTANT RGDelay				: INTEGER := multiplierDelay + adderDelay + adderDelay + adderDelay + invsqrtDelay +
														 multiplierDelay + dotPointDelay + 1;
	CONSTANT TIDelay				: INTEGER := dotPointDelay + multiplierDelay + adderDelay+ multiplierDelay + adderDelay + 
														 adderDelay + dotPointDelay + 1 + multiplierDelay + adderDelay + sqrtDelay +
														 adderDelay + divisionDelay + 1 + adderDelay + 1;
	CONSTANT SHDelay 				: INTEGER := multiplierDelay + dotPointDelay + dotPointDelay + invsqrtDelay + 
														 multiplierDelay + adderDelay + adderDelay + multiplierDelay +conversionDelay;
	
BEGIN
	--PRIMITIVES
	--Test intersection output
	centerTI	   <= (prmTI(0),prmTI(1),prmTI(2));
	rTI			<=  prmTI(3);
	vTI   		<= (prmTI(4),prmTI(5),prmTI(6));
	mMaxTI		<=  prmTI(7);
	--Shading output
	CenterSH 	<= (prmSH(0),prmSH(1),prmSH(2));
	rSH		   <= prmSH(3);
	vSH   		<= (prmSH(4),prmSH(5),prmSH(6));
	mMaxSH		<= prmSH(7);
	--SCREEN ITERATOR
	-------------------------------Ray frequency-------------------------------------
	rtEnable <= (NOT screenDone) AND enable;
	--Controls ray generation frequency
	rayFreq:			ENTITY WORK.clockFrequency 	GENERIC MAP(maxPrm,comparationTime)
																PORT MAP	  (clock,rst,rtEnable,prmSize,addPixel,rayCount);
	-------------------------------Screen iterator-----------------------------------
	--Iterates the screen
	screenItr:		ENTITY WORK.screenIterator		GENERIC MAP(xResolution,yResolution,conversionDelay)
																PORT MAP	  (rtEnable,clock,addPixel,rst,I,J,screenDone);
	-------------------------------Block enable--------------------------------------
	--Enables the blocks PrimaryRay, TestIntersection and Shading
	blockEna:		ENTITY WORK.blockEnable			GENERIC MAP(conversionDelay,RGDelay,TIDelay)
																PORT MAP	  (clock,rst,rtEnable,rayGen,rayInt,minDst);
																				
	--RAY GENERATION	
	rayGenEnable <= rayGen;
	------------------------------Primary ray----------------------------------------
	--Generates a ray from the origin to a given screen pixel
	rayGeneration: ENTITY WORK.primaryRay			GENERIC MAP(xResolution,yResolution,RGDelay,adderDelay,
																				dotPointDelay,invsqrtDelay)
																PORT MAP	  (rayGenEnable,clock,rst,scan,origin,pixelWidth,
																				pixelHeight,I,J,Rdir,rayDone);																
	--TEST INTERSECTION
	rayIntEnable <= rayDone AND rayInt;
	-----------------------------Primitive iteration---------------------------------
	prmItr:			ENTITY WORK.clockFrequency 	GENERIC MAP(maxPrm,comparationTime)
																PORT MAP	  (clock,rst,rayIntEnable,prmSize,maxTickIdTI,idTI);	
	------------------------------Test intersection----------------------------------
	--Finds the ray's distance				
	rayInts: 		ENTITY WORK.testIntersection 	GENERIC MAP(TIDelay,sqrtDelay,multiplierDelay,adderDelay,
																				divisionDelay,dotPointDelay)
																PORT MAP	  (rayIntEnable,clock,rst,prmTypeTI,centerTI,origin,
																				Rdir,rTI,vTI,mMaxTI,distance,m,p,distDone);
	
	--MINIMUM DISTANCE
	minDstEnable <= distDone AND minDst;
	-----------------------------Primitive iteration---------------------------------
	prmItr1:			ENTITY WORK.clockFrequency 	GENERIC MAP(maxPrm,comparationTime)
																PORT MAP	  (clock,rst,minDstEnable,prmSize,maxTickPrimID,idPrm);
	--------------------------------Minimum distance----------------------------------
	--Seeks the closest object hit by the ray
	minDist:			ENTITY WORK.minimumDistance 	GENERIC MAP(maxPrm,comparationTime,100)
																PORT MAP	  (clock,rst,minDstEnable,prmSize,idPrm,p,m,distance,
																				minP,minM,idSH,shade);
	--SHADING
	shadeEnable <=  distDone;				
	diffuse: 		ENTITY WORK.shading 				GENERIC MAP(SHDelay,sqrtDelay,multiplierDelay,adderDelay,
																				invsqrtDelay,dotPointDelay,conversionDelay)
																PORT MAP   (clock,rst,shade,shadeEnable,prmTypeSH,minP,minM,vSH,
																			   light,centerSH,color,colorDone,takeData);
	
	
END raytracing_arch;
