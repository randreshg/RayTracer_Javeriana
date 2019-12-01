-- FREE RUN CONVERTER
---------------------------------------------------------------------------
LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
---------------------------------------------------------------------------
ENTITY stopwatch IS
	GENERIC ( Second	   : INTEGER := 10;
	          Milli	   : INTEGER := 1000;
	          Micro      : INTEGER := 1000);
	PORT	  ( clk		   : IN  STD_LOGIC;
				 rst		   : IN  STD_LOGIC;
				 enable		: IN  STD_LOGIC;
	          microFlag  : OUT STD_LOGIC;
             milliFlag  : OUT STD_LOGIC;
             secondFlag : OUT STD_LOGIC);
END ENTITY;
---------------------------------------------------------------------------
ARCHITECTURE rtl OF stopwatch IS
	-- Auxiliar signals
	--ClockCounter
	SIGNAL microFlag_aux 	: STD_LOGIC;
	--MicroSeconds
	SIGNAL milliFlag_aux  	: STD_LOGIC;
	--MilliSeconds
	SIGNAL secondFlag_aux  	: STD_LOGIC;
	--Seconds
	SIGNAL max_tick_Aux	   : STD_LOGIC;   
	
BEGIN 
	--Block definition
	seconds: 		ENTITY WORK.counterTime	GENERIC MAP (Second)
														PORT MAP    (clk,rst,secondFlag_aux,max_tick_Aux);
	            
	milliSeconds: 	ENTITY WORK.counterTime GENERIC MAP (Milli)
														PORT MAP    (clk,rst,milliFlag_aux,secondFlag_aux);
	
	microSeconds: 	ENTITY WORK.counterTime	GENERIC MAP (Micro)
														PORT MAP    (clk,rst,microFlag_aux,milliFlag_aux);
					  
	clockCounter: 	ENTITY WORK.counterTime GENERIC MAP (50)
														PORT MAP    (clk,rst,enable,microFlag_aux);
				
	--Outputs
	microFlag	<= microFlag_aux; 	
	milliFlag	<= milliFlag_aux;  
	secondFlag	<= secondFlag_aux; 
	
END ARCHITECTURE;
