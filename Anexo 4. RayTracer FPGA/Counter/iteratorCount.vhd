---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------
ENTITY iteratorCount IS
	GENERIC(	xResolution		: INTEGER := 640;	
				yResolution		: INTEGER := 480);
	PORT	 (	clock   			: IN  STD_LOGIC;
				rst				: IN  STD_LOGIC;
				enable         : IN  STD_LOGIC;
				done				: OUT STD_LOGIC;
				JCount			: OUT INTEGER RANGE 0 TO (xResolution-1);
				ICount			: OUT INTEGER RANGE 0 TO (yResolution-1));
END iteratorCount;

ARCHITECTURE iteratorCount_arch OF iteratorCount IS	
	--Iteration counter
	SIGNAL max_tickJ			: STD_LOGIC;
	SIGNAL max_tickI			: STD_LOGIC;
	SIGNAL iEnable,enableI	: STD_LOGIC;
	SIGNAL jEnable,enableJ	: STD_LOGIC;
	
BEGIN
	---------------------------------------------Iteration counter-----------------------------------------------
	CounterJ: ENTITY WORK.counterCount		GENERIC MAP(xResolution)
														PORT MAP	  (clock,rst,jEnable,max_tickJ,JCount);											
	CounterI: ENTITY WORK.counterCount		GENERIC MAP(yResolution)
														PORT MAP	  (clock,rst,iEnable,max_tickI,ICount);
	--Controls iteration counter
	iEnable <= enableI AND enable;
	jEnable <= enableJ AND enable;
	--Aux
	enableI <= max_tickJ AND enableJ;
	enableJ <= (NOT max_tickI) OR (max_tickI AND (NOT max_tickJ));
	done    <= (NOT enableJ) AND (NOT enableI) AND (max_tickJ) AND (max_tickI);
	
END iteratorCount_arch;
