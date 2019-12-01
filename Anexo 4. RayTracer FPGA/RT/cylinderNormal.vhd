	---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.ALL;

----------------------------------------------------------
ENTITY cylinderNormal IS
	GENERIC(	adderDelay 			: INTEGER := 5;
				multiplierDelay 	: INTEGER := 5);
	PORT	 (	clock   				: IN  STD_LOGIC;
				p						: IN  VECTOR;
				m						: IN  FLOAT;
				v						: IN  VECTOR;
				center				: IN  VECTOR;
				N						: OUT VECTOR);
				
END cylinderNormal;

ARCHITECTURE cylinderNormal_arch OF cylinderNormal IS
	--Center delay
	TYPE data IS ARRAY (multiplierDelay DOWNTO 0) OF VECTOR;
	SIGNAL centerDelay	: data;
	--p delay
	CONSTANT delayP: INTEGER := multiplierDelay + adderDelay;
	TYPE data1 IS ARRAY (delayP DOWNTO 0) OF VECTOR;
	SIGNAL pDelay	: data1;
	--Aux signals
	SIGNAL aux					: VECTOR;
	SIGNAL aux2 				: VECTOR;
BEGIN														
	-- m*v
	calc1:   ENTITY WORK.scalarProduct PORT MAP(clock,m,v,aux); 
	-- center + m*v
	calc2:	ENTITY WORK.vectorSum	  PORT MAP('1',clock,aux,centerDelay(multiplierDelay),aux2); 
	-- p - (center + m*v)
	NVector: ENTITY WORK.vectorSum	  PORT MAP('0',clock,pDelay(delayP),aux2,N); 
	
	-----------------------------------------------Delays-------------------------------------------------------
	--Center delay
	centerDelay(0) <= center;
	delays1: FOR i IN 1 TO multiplierDelay
		GENERATE		
			dly1 : ENTITY WORK.vectorRegister 	PORT MAP(clock,'0','1',centerDelay(i-1),centerDelay(i));
		END GENERATE;
	--Center delay
	pDelay(0) <= p;
	delays2: FOR i IN 1 TO delayP
		GENERATE		
			dly2 : ENTITY WORK.vectorRegister 	PORT MAP(clock,'0','1',pDelay(i-1),pDelay(i));
		END GENERATE;
	END cylinderNormal_arch;