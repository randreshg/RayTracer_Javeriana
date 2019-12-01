---------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
---------------------------------------------------------------------------
ENTITY serial IS
	PORT	  ( clock		      : IN 	STD_LOGIC;				 
				 rst	     		   : IN 	STD_LOGIC;
				 enable 				: IN  STD_LOGIC;
				 dataIn				: IN 	STD_LOGIC;
				 serialOut			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				 serialDone			: OUT STD_LOGIC);
END ENTITY;
---------------------------------------------------------------------------
ARCHITECTURE rtl OF Serial IS
  
	--BitCounter
	SIGNAL bitCounterEnable			: STD_LOGIC;
	SIGNAL bitCounterReset			: STD_LOGIC;
	SIGNAL bitCounterMaxtick		: STD_LOGIC;
	SIGNAL bitCounter					: INTEGER RANGE 0 TO 7 := 0;
	--TimeCounter
	SIGNAL timeCounterEnable	   : STD_LOGIC;
	SIGNAL timeCounterReset			: STD_LOGIC;
	SIGNAL timeCounterMaxtick		: STD_LOGIC;
	--SerialRegister
	SIGNAL serialEnable				: STD_LOGIC;
	
BEGIN 
	--Output
	serialDone <= bitCounterReset;
	--Block definition
	counterTime:	ENTITY WORK.counterTick    GENERIC MAP(900)
														   PORT	MAP  (clock,timeCounterReset,timeCounterEnable,timeCounterMaxtick);
	
	counterBits: 	ENTITY WORK.counterCount   GENERIC MAP(8)
														   PORT	MAP  (clock,bitCounterReset,bitCounterEnable,bitCounterMaxtick,bitCounter);
	
	control: 	  	ENTITY WORK.serialControl 	PORT MAP   (clock,rst,enable,timeCounterMaxtick,bitCounterMaxtick,dataIn,serialEnable,
																			timeCounterEnable,timeCounterReset,bitCounterEnable,bitCounterReset);
					
	serialReg: 		ENTITY WORK.serialRegister GENERIC MAP(8)
															PORT	MAP  (clock,bitCounter,serialEnable,dataIn,serialOut);
END ARCHITECTURE rtl;