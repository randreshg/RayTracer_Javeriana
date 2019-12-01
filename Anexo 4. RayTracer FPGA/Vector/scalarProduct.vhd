---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.ALL;

----------------------------------------------------------
ENTITY scalarProduct IS
	PORT	 (	clock   				: IN  STD_LOGIC; 
				dataA 				: IN  FLOAT;
				dataB					: IN  VECTOR;
				result    			: OUT VECTOR);
END scalarProduct;

ARCHITECTURE scalarProduct_arch OF scalarProduct IS
	SIGNAL multx    	: FLOAT;
	SIGNAL multy    	: FLOAT;
	SIGNAL multz    	: FLOAT;

BEGIN
	--Block instantiation
	mult1_x:  ENTITY WORK.multiplier PORT MAP(clock,dataA,dataB(0),multx);
	mult1_y:  ENTITY WORK.multiplier PORT MAP(clock,dataA,dataB(1),multy);   
	mult1_z:  ENTITY WORK.multiplier PORT MAP(clock,dataA,dataB(2),multz);  
	
	result(0) <= multx;
	result(1) <= multy;
	result(2) <= multz;

END scalarProduct_arch;
