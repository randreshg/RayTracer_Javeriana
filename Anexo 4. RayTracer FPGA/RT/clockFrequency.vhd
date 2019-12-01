---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------

ENTITY clockFrequency IS
	GENERIC( maxPrm				: INTEGER := 5;
				comparationTime	: INTEGER := 3);
	PORT	 (	clock					: IN  STD_LOGIC;	
				rst					: IN  STD_LOGIC;	
				enable				: IN  STD_LOGIC;
				prmSize				: IN  INTEGER RANGE 0 TO (maxPrm-1);			
				addPixel				: OUT STD_LOGIC;
				prmCount				: OUT INTEGER RANGE 0 TO (maxPrm-1));
END clockFrequency;

ARCHITECTURE clockFrequency_arch OF clockFrequency IS
	--Cmp clock
	SIGNAL cmpEnable				: STD_LOGIC;
	SIGNAL cmpMaxTick				: STD_LOGIC;
	--Prm Freq
	SIGNAL prmEnable				: STD_LOGIC;
	SIGNAL prmMaxTick				: STD_LOGIC;
BEGIN
	--------------------------------Prm count----------------------------------
	--Change the primitive every comparation time
	prmFreq: 		ENTITY WORK.maxcounterCount 	GENERIC MAP(maxPrm)
																PORT MAP	  (clock,rst,prmEnable,prmSize,prmMaxTick,prmCount);
	prmEnable 	   <= cmpMaxTick AND enable;
	addPixel 	   <= prmMaxTick AND prmEnable;
	
	--------------------------------Cmp clock---------------------------------------
	--dly0 : ENTITY WORK.bitRegister   	PORT MAP   (clock,rst,'1',enable,cmpEnable);
	--Keeps a the clock the needed time to compare distances
	compClock:		ENTITY WORK.counterTick 		GENERIC MAP(comparationTime)
																PORT MAP	  (clock,rst,enable,cmpMaxTick);
END clockFrequency_arch;
