-- STOPWATCH COUNTER
---------------------------------------------------------------------------
LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
---------------------------------------------------------------------------
ENTITY stopwatchCounter IS
	GENERIC( Second	  	: INTEGER := 10;
	         Milli	     	: INTEGER := 1000;
	         Micro       : INTEGER := 1000);
	PORT	 ( clk		   : IN 	STD_LOGIC;
				rst	      : IN 	STD_LOGIC;
				enable		: IN	STD_LOGIC;
				--TX SERIAL
				unity    	: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
				ten     		: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
				hundredth	: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
				mills			: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
				--SS
				milliDisp	: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
				decimalsDisp: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
				unitsDisp	: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
				tensDisp		: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);
				point			: OUT STD_LOGIC);
END ENTITY;
---------------------------------------------------------------------------
ARCHITECTURE rtl OF stopwatchCounter IS
   -- Stopwatch
   SIGNAL microFlag  	:  STD_LOGIC;
   SIGNAL milliFlag  	:  STD_LOGIC;
   SIGNAL secondFlag  	:  STD_LOGIC;
   --Milesimas
   SIGNAL milliCount    :	INTEGER RANGE 0 TO 9;
   SIGNAL hundredthFlag	:  STD_LOGIC;
   --Hundredths
   SIGNAL hundredthCount:	INTEGER RANGE 0 TO 9;
   SIGNAL decimalFlag	:  STD_LOGIC;
   --Decimals
   SIGNAL decimalCount	:	INTEGER RANGE 0 TO 9;
   SIGNAL unityFlag		:  STD_LOGIC;
   --Units
   SIGNAL unityCount		:	INTEGER RANGE 0 TO 9;
   SIGNAL tenFlag			:  STD_LOGIC;  
	
	
BEGIN 
	--Block definition			  
	stopwatch: 		ENTITY WORK.stopwatch 	 GENERIC MAP(Second,Milli,Micro)
														 PORT MAP   (clk,rst,enable,microFlag,milliFlag,secondFlag);
	-- Units
	unitys: 		ENTITY WORK.counterTime		 GENERIC MAP (10)
														 PORT MAP 	(clk,rst,unityFlag,tenFlag,unityCount);
	--Decimals
	decimals: 		ENTITY WORK.counterTime	 GENERIC MAP (10)
														 PORT MAP    (clk,rst,decimalFlag,unityFlag,decimalCount);					
	--Hundredths	
	hundredths: 	ENTITY WORK.counterTime	 GENERIC MAP (10)
														 PORT MAP    (clk,rst,hundredthFlag,decimalFlag,hundredthCount);
	--Milesimas	
	tenMiliCounter: ENTITY WORK.counterTime GENERIC MAP (10)
														 PORT MAP    (clk,rst,milliFlag,hundredthFlag,milliCount);
	--Signals			
	unity    	<= STD_LOGIC_VECTOR(TO_UNSIGNED(unityCount,8));
	ten     		<= STD_LOGIC_VECTOR(TO_UNSIGNED(decimalCount,8));
	hundredth   <= STD_LOGIC_VECTOR(TO_UNSIGNED(hundredthCount,8));
	mills			<= STD_LOGIC_VECTOR(TO_UNSIGNED(milliCount,8));
	
	--MilliDisp
	dispMills	 : ENTITY WORK.Integer_to_sseg	PORT MAP (milliCount,milliDisp);
	--DecimalsDisp
	dispDecimals : ENTITY WORK.Integer_to_sseg	PORT MAP (hundredthCount,decimalsDisp);
	--DispUnits
	dispUnits	 : ENTITY WORK.Integer_to_sseg	PORT MAP (decimalCount,unitsDisp);
	--DispTens
	dispTens		 : ENTITY WORK.Integer_to_sseg	PORT MAP (unityCount,tensDisp);
	-- Output
	point		<= '0';
END ARCHITECTURE;
