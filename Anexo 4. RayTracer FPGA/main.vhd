---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------
ENTITY main IS
	GENERIC(	-- Screen
				maxPrm			: INTEGER := 20;
				colorBits		: INTEGER := 8;
				H_SyncPulse 	: INTEGER := 96;    
				H_BackPorch		: INTEGER := 48;		
				xResolution		: INTEGER := 640;
				H_FrontPorch	: INTEGER := 16;		
				V_SyncPulse 	: INTEGER := 2;	
				V_BackPorch		: INTEGER := 33;		
				yResolution		: INTEGER := 480;
				V_FrontPorch	: INTEGER := 10);
	PORT	 (	clock   			: IN  STD_LOGIC;
				rst				: IN  STD_LOGIC;
				dataIn         : IN  STD_LOGIC;
				--Output
			   H_Sync		   : OUT STD_LOGIC;
				V_Sync			: OUT STD_LOGIC;
				VGAClk			: OUT STD_LOGIC;
				Blank 			: OUT STD_LOGIC;
				Sync				: OUT STD_LOGIC;
				R	       		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
				G  	     		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
				B	       		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
				serialOut		: OUT STD_LOGIC;
				LEDS				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
				--SS
				milliDisp	: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
				decimalsDisp: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
				unitsDisp	: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
				tensDisp		: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0));
END main;

ARCHITECTURE main_arch OF main IS	
	--Scene
	SIGNAL prmTI				: PRIMITIVE;
	SIGNAL prmTypeTI			: STD_LOGIC;
	SIGNAL prmSH				: PRIMITIVE;
	SIGNAL prmTypeSH			: STD_LOGIC;
	SIGNAL prmSize				: INTEGER RANGE 0 TO (maxPrm-1);
	SIGNAL idTI					: INTEGER RANGE 0 TO (maxPrm-1);
	SIGNAL idSH					: INTEGER RANGE 0 TO (maxPrm-1);
	SIGNAL light				: VECTOR;
	SIGNAL origin				: VECTOR;
	SIGNAL pixelWidth	 		: VECTOR;
	SIGNAL pixelHeight	 	: VECTOR;
	SIGNAL scan			 		: VECTOR;
	--Raytracing
	SIGNAL colorDone			: STD_LOGIC := '0';
	SIGNAL color				: STD_LOGIC_VECTOR (colorBits-1 DOWNTO 0);
	--Memory
	SIGNAL colorInfo			: STD_LOGIC_VECTOR(colorBits-1 DOWNTO 0);
	SIGNAL memoryOut			: STD_LOGIC_VECTOR(colorBits-1 DOWNTO 0);
	SIGNAL memoryOut2			: STD_LOGIC_VECTOR(colorBits-1 DOWNTO 0);
	SIGNAL memoryWrite		: STD_LOGIC;
	SIGNAL row  	 			: INTEGER RANGE 0 TO (yResolution-1):= 0;
	SIGNAL column  			: INTEGER RANGE 0 TO (xResolution-1):= 0;
	--Iteration counter
	SIGNAL JCount				: INTEGER RANGE 0 TO (xResolution-1) := 0;
	SIGNAL ICount				: INTEGER RANGE 0 TO (yResolution-1) := 0;
	SIGNAL RTdone				: STD_LOGIC := '0';
	--VGA
	SIGNAL videoOn				: STD_LOGIC:='0';
	SIGNAL clkPLL				: STD_LOGIC;
	SIGNAL rowV  	 			: INTEGER RANGE 0 TO (yResolution-1):= 0;
	SIGNAL columnV  			: INTEGER RANGE 0 TO (xResolution-1):= 0;
	SIGNAL takeData			: STD_LOGIC;
	--Control
	SIGNAL traceReset			: STD_LOGIC;
	SIGNAL traceEnable		: STD_LOGIC;
	SIGNAL serialEnable		: STD_LOGIC;
	SIGNAL systemEnable		: STD_LOGIC;
	--Serial Transmision
	SIGNAL txEnable			: STD_LOGIC;
	SIGNAL txDone				: STD_LOGIC;
	SIGNAL rowT  	 			: INTEGER RANGE 0 TO (yResolution-1):= 0;
	SIGNAL columnT  			: INTEGER RANGE 0 TO (xResolution-1):= 0;
	--StopwatchCounter
	SIGNAL unity    			: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ten     			: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL hundredth			: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL mills				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	
BEGIN
	--------------------------------------------------Control----------------------------------------------------
	control:		ENTITY WORK.mainControl 	PORT MAP	  (clock,rst,systemEnable,RTdone,txDone,traceEnable,traceReset,
																		serialEnable,txEnable);
	-------------------------------------------------Raytracing--------------------------------------------------
	rt: 			ENTITY WORK.raytracing 		GENERIC MAP(maxPrm,colorBits,xResolution,yResolution)
														PORT MAP	  (traceEnable,clock,traceReset,prmTI,prmTypeTI,prmSH,prmTypeSH,
																		prmSize,light,origin,pixelWidth,pixelHeight,scan,idTI,
																		idSH,color,colorDone,takeData);
	--Stopwatch counter
	sc: 		ENTITY WORK.stopwatchCounter  PORT MAP   (clock,traceReset,traceEnable,unity,ten,hundredth,mills,milliDisp,
																		decimalsDisp,unitsDisp,tensDisp);
	--------------------------------------------------Scene------------------------------------------------------
	sceneInfo: 	ENTITY WORK.scene				GENERIC MAP(maxPrm)
														PORT MAP	  (clock,traceReset,dataIn,serialEnable,idTI,idSH,prmTI,prmTypeTI,
																		prmSH,prmTypeSH,prmSize,origin,pixelWidth,pixelHeight,scan,light,
																		systemEnable,LEDS(6 DOWNTO 0));
	---------------------------------------------------VGA-------------------------------------------------------
	--PLL Clock				
	MYPLL: 		ENTITY WORK.MyPLL				PORT MAP	  (clock,clkPLL);
	--VGA
	VGA: 			ENTITY WORK.VGAController	GENERIC MAP(H_SyncPulse,H_BackPorch,xResolution,H_FrontPorch,
																		V_SyncPulse,V_BackPorch,yResolution,V_FrontPorch)
														PORT MAP   (clkPLL,rst,H_Sync,V_Sync,videoOn,rowV,columnV,Blank,Sync);
	VGAClk 		<= clkPLL;
	---------------------------------------------Iteration counter-----------------------------------------------
	cI: 			ENTITY WORK.iteratorCount	GENERIC MAP(xResolution,yResolution)
														PORT MAP   (clock,traceReset,memoryWrite,RTdone,JCount,ICount);
	------------------------------------------------Memory-------------------------------------------------------
   memoryWrite <= colorDone AND takeData;
	row 		<= rowT 		WHEN txEnable = '1' ELSE rowV;
	column 	<= columnT 	WHEN txEnable = '1' ELSE columnV;
	
	memory  : ENTITY WORK.RAM					GENERIC MAP(colorBits,xResolution,yResolution)	
														PORT MAP	  (clock,color,row,column,ICount,JCount,memoryWrite,memoryOut);
	-------------------------------------------Serial Transmision------------------------------------------------
	txSerial : ENTITY WORK.txSerial			GENERIC MAP(xResolution,yResolution,colorBits)			
														PORT MAP   (clock,traceReset,txEnable,memoryOut,unity,ten,hundredth,
																		mills,rowT,columnT,serialOut,txDone,LEDS(7));
	------------------------------------------------Output-------------------------------------------------------
	colorInfo <= (memoryOut) WHEN (videoOn = '1' AND colorDone = '1' AND txDone = '1') ELSE (OTHERS=>'0');
	R 	 <= colorInfo;
	G 	 <= colorInfo;
	B 	 <= colorInfo;
END main_arch;
