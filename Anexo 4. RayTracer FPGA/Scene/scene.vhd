---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------
ENTITY scene IS
	GENERIC( maxPrm				: INTEGER :=15);
	PORT	 (	clock   				: IN  STD_LOGIC;
				rst					: IN  STD_LOGIC;
				data_in				: IN  STD_LOGIC;
				enable				: IN  STD_LOGIC;
				idTI					: IN  INTEGER RANGE 0 TO (maxPrm-1);
				idSH					: IN  INTEGER RANGE 0 TO (maxPrm-1);
				prmTI					: OUT	PRIMITIVE;
				prmTypeTI			: OUT	STD_LOGIC;
				prmSH					: OUT	PRIMITIVE;
				prmTypeSH			: OUT	STD_LOGIC;
				prmSize				: OUT INTEGER RANGE 0 TO (maxPrm-1);
				origin				: OUT	VECTOR;
				pixelWidth	 		: OUT	VECTOR;
				pixelHeight	 		: OUT	VECTOR;
				scan			 		: OUT	VECTOR;
				--Ilumination info
				light					: OUT VECTOR;
				systemEnable		: OUT STD_LOGIC;
				LEDS				: OUT STD_LOGIC_VECTOR (6 DOWNTO 0));
END scene;

ARCHITECTURE scene_arch OF scene IS
	SIGNAL observerData			: OBSERVER;
	SIGNAL memoryEnable			: STD_LOGIC;
	SIGNAL memoryIterator		: INTEGER RANGE 0 TO maxPrm-1;
	SIGNAL memoryData		   	: PRIMITIVE;
	SIGNAL memoryType			   : STD_LOGIC;
	SIGNAL lightA					: VECTOR;
BEGIN
	origin		<= observerData(0);
	scan			<= observerData(1);
	pixelWidth	<= observerData(2);
	pixelHeight <= observerData(3);
	
	--Primitives memory
	rxSerial		: ENTITY WORK.getScene			GENERIC MAP(maxPrm)
															PORT MAP   (clock,enable,rst,data_in,observerData,memoryEnable,
																			prmSize,memoryIterator,memoryData,memoryType,light,systemEnable,LEDS);
	prmMemory	: ENTITY WORK.primitiveMemory	GENERIC MAP(maxPrm)
														   PORT MAP   (clock,memoryData,memoryType,idTI,idSH,memoryIterator,memoryEnable,
																			prmTI,prmTypeTI,prmSH,prmTypeSH);

	
END scene_arch;