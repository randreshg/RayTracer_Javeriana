---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------

ENTITY screenIterator IS
	GENERIC(	xResolution			: INTEGER := 15;
				yResolution			: INTEGER := 10;
				delay					: INTEGER := 6);
	PORT	 (	enable				: IN  STD_LOGIC;
				clock   				: IN  STD_LOGIC;
				addPixel				: IN 	STD_LOGIC;
				rst					: IN  STD_LOGIC;
				I						: OUT FLOAT;
				J						: OUT FLOAT;
				screenDone			: OUT STD_LOGIC);
END screenIterator;

ARCHITECTURE screenIterator_arch OF screenIterator IS
	--SCREEN ITERATION
	--Iteration count
	SIGNAL counterEnable  : STD_LOGIC;
	SIGNAL counterDone	 : STD_LOGIC;
	SIGNAL JCount			 : INTEGER RANGE 0 TO (Xresolution-1) := 0;
	SIGNAL ICount			 : INTEGER RANGE 0 TO (Yresolution-1) := 0;
	--Done delay
   TYPE data IS ARRAY  (delay DOWNTO 0) OF STD_LOGIC;
	SIGNAL doneDelay 		: data;
BEGIN
	counterEnable <= addPixel AND enable;
	------------------------Iteration count-----------------------------------
	cI				: ENTITY WORK.iteratorCount		GENERIC MAP(xResolution,yResolution)
																PORT MAP   (clock,rst,counterEnable,counterDone,JCount,ICount);
	----------------------------Conversion--------------------------------------
	--Converts from integer to floating point
	Jconverter 	: ENTITY WORK.conversion			GENERIC MAP(xResolution)
																PORT MAP	  (clock,JCount,J);
	Iconverter  : ENTITY WORK.conversion	 		GENERIC MAP(yResolution)
																PORT MAP	  (clock,ICount,I);
	---------------------------Done delay--------------------------------------
	--Done delay
	doneDelay(0) <= counterDone;
	delays: FOR i IN 1 TO delay 
		GENERATE		
			dly  : ENTITY WORK.bitRegister 	PORT MAP(clock,rst,'1',doneDelay(i-1),doneDelay(i));
		END GENERATE;
	------------------------------Output---------------------------------------
	screenDone <= doneDelay(delay);		
END screenIterator_arch;
