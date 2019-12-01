---------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
--------------------------------------------------------------------------
ENTITY txSerial IS
	GENERIC ( xResolution	: INTEGER := 15;
				 yResolution	: INTEGER := 11;
				 colorBits		: INTEGER := 8;
				 serialBits		: INTEGER := 8);
	PORT	  ( clock	      : IN 	STD_LOGIC;
				 rst		      : IN 	STD_LOGIC;
				 enable			: IN  STD_LOGIC;
				 dataIn			: IN  STD_LOGIC_VECTOR(colorBits-1 DOWNTO 0);
				 unity    		: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
				 ten     		: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);				 
				 hundredth		: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
				 mills			: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
				 row  		 	: OUT INTEGER RANGE 0 TO (yResolution-1):= 0;
				 column  		: OUT INTEGER RANGE 0 TO (xResolution-1):= 0;
				 dataOut			: OUT STD_LOGIC;
				 txDone			: OUT STD_LOGIC;
				 LEDS				: OUT STD_LOGIC);
END ENTITY;


---------------------------------------------------------------------------
ARCHITECTURE rtl OF txSerial IS
	--PLL Clock
	SIGNAL serialClock	: STD_LOGIC;
	--Iteration count
	SIGNAL ICount   		: INTEGER RANGE 0 TO (yResolution-1):= 0;
	SIGNAL JCount  		: INTEGER RANGE 0 TO (xResolution-1):= 0;
	SIGNAL pixelEnable	: STD_LOGIC;
	SIGNAL pixelDone		: STD_LOGIC;
	--Bit count
	SIGNAL bitCount  		: INTEGER RANGE 0 TO (9):= 0;
	SIGNAL bitDone			: STD_LOGIC;
	SIGNAL bitReset		: STD_LOGIC;
	SIGNAL bitEnable		: STD_LOGIC;
	--Bit count
	SIGNAL timeCount  	: INTEGER RANGE 0 TO (4):= 0;
	SIGNAL timeDone		: STD_LOGIC;
	SIGNAL timeEnable		: STD_LOGIC;
	--Aux
	SIGNAL data				: STD_LOGIC_VECTOR(10 DOWNTO 0);
	
BEGIN
	--Iteration count
	cI: 				ENTITY WORK.iteratorCount	GENERIC MAP(xResolution,yResolution)
															PORT MAP   (clock,rst,pixelEnable,pixelDone,column,row);
	--PLL Clock
	txSerialX: 		ENTITY WORK.My_PLL_serial	PORT MAP	  (clock,serialClock);
	--Primitive counter
	bitCnt:			ENTITY WORK.counterCount 	GENERIC MAP(11)
															PORT	MAP  (serialClock,bitReset,bitEnable,bitDone,bitCount);
	--Time counter
	timeCnt:			ENTITY WORK.counterCount 	GENERIC MAP(5)
															PORT	MAP  (clock,rst,timeEnable,timeDone,timeCount);
	--Tx control

				
	txControl:		ENTITY WORK.txControl 		PORT MAP	  (clock,rst,enable,pixelDone,bitDone,timeDone,
																			pixelEnable,bitEnable,bitReset,timeEnable);
	--Aux
	sequential: PROCESS(clock)
	BEGIN
		IF (RISING_EDGE(clock)) THEN
			IF(timeDone = '1') THEN
				data <= "1"&dataIn&"01";
			ELSIF(timeCount = 0) THEN
				data <= "1"&mills&"01" ;
			ELSIF(timeCount = 1) THEN
				data <= "1"&hundredth&"01";
			ELSIF(timeCount = 2) THEN
				data <= "1"&ten&"01";
			ELSIF(timeCount = 3) THEN
				data <= "1"&unity&"01";
			END IF;
		END IF;
	END PROCESS;
	--Output
	txDone <= pixelDone;
	dataOut <= data(bitCount);	
	LEDS <= timeDone;
END ARCHITECTURE rtl;