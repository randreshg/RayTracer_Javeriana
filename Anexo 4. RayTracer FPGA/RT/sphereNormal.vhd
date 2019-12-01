---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.ALL;

----------------------------------------------------------
ENTITY sphereNormal IS
	GENERIC( delay		: INTEGER);
	PORT	 (	clock   	: IN  STD_LOGIC;
				p 			: IN  VECTOR; 
				center	: IN  VECTOR;
				N			: OUT VECTOR);
END sphereNormal;

ARCHITECTURE sphereNormal_arch OF sphereNormal IS
	--Ns delay
	TYPE   data1 IS ARRAY (delay DOWNTO 0) OF VECTOR;
	SIGNAL NsDelay : data1;
	--Aux signals
	SIGNAL Ns 		: VECTOR;
BEGIN
	NVector: 	 ENTITY WORK.vectorSum	 	 PORT MAP('0',clock,p,center,Ns);
	--Delay
	NsDelay(0) <= Ns;
	delays1: FOR i IN 1 TO delay
		GENERATE		
			dly1 : ENTITY WORK.vectorRegister PORT MAP(clock,'0','1',NsDelay(i-1),NsDelay(i));
		END GENERATE;
	--Output
	N <= NsDelay(delay);
END sphereNormal_arch;