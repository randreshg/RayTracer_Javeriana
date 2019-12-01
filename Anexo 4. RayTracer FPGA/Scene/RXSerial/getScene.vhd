---------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
---------------------------------------------------------------------------
ENTITY getScene IS
	GENERIC ( maxPrm				: INTEGER :=15);
	PORT	  ( clock		      : IN 	STD_LOGIC;
				 enable 				: IN  STD_LOGIC;
				 rst	     		   : IN 	STD_LOGIC;
				 dataIn				: IN 	STD_LOGIC;
				 observerData		: OUT OBSERVER;	 
				 memoryEnable		: OUT STD_LOGIC;
				 memorySize			: OUT INTEGER RANGE 0 TO maxPrm-1;
				 memoryIterator	: OUT INTEGER RANGE 0 TO maxPrm-1;
				 memoryData			: OUT PRIMITIVE;
				 memoryType			: OUT STD_LOGIC;
				 lightData			: OUT VECTOR;
				 systemEnable		: OUT STD_LOGIC;
				 LEDS				: OUT STD_LOGIC_VECTOR (6 DOWNTO 0));
END ENTITY;
---------------------------------------------------------------------------
ARCHITECTURE rtl OF getScene IS
	--SerialRegister
	SIGNAL serialDone		: STD_LOGIC;
	SIGNAL serialOut		: STD_LOGIC_VECTOR(7 DOWNTO 0);
	--GetFloat
	SIGNAL floatEnable	: STD_LOGIC;
	SIGNAL floatReset		: STD_LOGIC;
	SIGNAL floatOut		: FLOAT;
	SIGNAL floatDone		: STD_LOGIC;
	--GetVector
	SIGNAL vectorEnable	: STD_LOGIC;
	SIGNAL vectorReset	: STD_LOGIC;
	SIGNAL vectorOut		: VECTOR;
	SIGNAL vectorDone		: STD_LOGIC;
	--PrmCounter
	SIGNAL prmEnable		: STD_LOGIC;
	SIGNAL prmDone			: STD_LOGIC;
	SIGNAL prmSize			: INTEGER RANGE 0 TO maxPrm-1 := 0;
	
BEGIN
	--Output
	memorySize <= prmSize;
	--Serial				 
	ser:	ENTITY WORK.serial    			PORT	MAP  (clock,rst,enable,dataIn,serialOut,serialDone);
	--Get datatype info															
	getF: ENTITY WORK.getFloat    		PORT MAP   (clock,floatReset,floatEnable,serialOut,floatOut,floatDone);
	
	getV: ENTITY WORK.getVector   		PORT MAP   (clock,vectorReset,vectorEnable,floatOut,vectorOut,vectorDone);
	
	--Primitive counter
	prm:	ENTITY WORK.maxCounterCount 	GENERIC MAP(8)
													PORT	MAP  (clock,rst,prmEnable,prmSize,prmDone,memoryIterator);
													
	info: ENTITY WORK.dataParse  			GENERIC MAP(maxPrm)
													PORT MAP   (clock,rst,serialOut,serialDone,floatOut,floatDone,vectorOut,vectorDone,
																	prmDone,vectorEnable,vectorReset,floatEnable,floatReset,prmEnable,memoryEnable,
																	prmSize,memoryData,memoryType,observerData,lightData,systemEnable,LEDS); 
END ARCHITECTURE rtl;