---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;

----------------------------------------------------------
ENTITY calcSphere IS
	GENERIC(	delay				: INTEGER := 7;
				adderDelay		: INTEGER := 7);
	PORT	 (	clock   			: IN  STD_LOGIC; 
				rst   			: IN  STD_LOGIC; 
				VOCs	 			: IN  VECTOR;
				Rdir				: IN  VECTOR;
				cAux				: IN  FLOAT;
				a					: OUT FLOAT;
				b					: OUT FLOAT;
				c					: OUT FLOAT);
END calcSphere;

ARCHITECTURE calcSphere_arch OF calcSphere IS
	TYPE data  IS ARRAY (delay DOWNTO 0) OF FLOAT;
	--Signals
	SIGNAL bAux 		: FLOAT;
	--SIGNAL cAux 		: FLOAT;
	SIGNAL bAuxDelay	: data;
	SIGNAL cAuxDelay	: data;

BEGIN
	------------------------------------------First step--------------------------------------------------------
	--RdirdotVOC
	RdotVOC	  : ENTITY WORK.dotPointDelay GENERIC MAP (adderDelay) 			
														PORT MAP		(clock,Rdir,VOCs,bAux);	
	a <= X"3f800000";
	------------------------------------------Pipeline delay-----------------------------------------------------
	--bAux delay
	bAuxDelay(0) <= bAux;
	delays0: FOR i IN 1 TO delay
		GENERATE		
			dly0 : ENTITY WORK.dataRegister 	GENERIC MAP(32)													
														PORT MAP(clock,'0','1',bAuxDelay(i-1),bAuxDelay(i));
		END GENERATE;
	--cAux delay
	cAuxDelay(0) <= cAux;
	delays1: FOR i IN 1 TO delay
		GENERATE		
			dly1 : ENTITY WORK.dataRegister 	GENERIC MAP(32)													
														PORT MAP(clock,'0','1',cAuxDelay(i-1),cAuxDelay(i));
		END GENERATE;
	------------------------------------------------Output-------------------------------------------------------
	b <= bAuxDelay(delay);
	c <= cAuxDelay(delay);
						
END calcSphere_arch;