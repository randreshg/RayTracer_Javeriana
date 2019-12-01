---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.ALL;

----------------------------------------------------------
ENTITY dotPointDelay IS
	GENERIC(	adderDelay			: INTEGER := 7);
	PORT	 (	clock   				: IN  STD_LOGIC; 
				dataA 				: IN  VECTOR;
				dataB					: IN  VECTOR;
				result    			: OUT FLOAT);
END dotPointDelay;

ARCHITECTURE dotPointDelay_arch OF dotPointDelay IS

	SIGNAL sumx    	: FLOAT;
	SIGNAL sumy    	: FLOAT;
	SIGNAL sumz    	: FLOAT;
	SIGNAL sumxy,aux 	: FLOAT;
	SIGNAL nan			: STD_LOGIC;
	--Delay signals
   TYPE data IS ARRAY (adderDelay DOWNTO 0) OF FLOAT;
	SIGNAL info 		: data;
BEGIN
	--Block instantiation
	mult1_x:  ENTITY WORK.multiplier PORT MAP(clock,dataA(0),dataB(0),sumx);
	mult1_y:  ENTITY WORK.multiplier PORT MAP(clock,dataA(1),dataB(1),sumy);   
	mult1_z:  ENTITY WORK.multiplier PORT MAP(clock,dataA(2),dataB(2),sumz);  
   add1_xy:  ENTITY WORK.addSub 		PORT MAP('1',clock,sumx,sumy,sumxy);	
	add1_xyz: ENTITY WORK.addSubNaN	PORT MAP('1',clock,sumxy,info(adderDelay),nan,aux);
	result	<= zeros	WHEN nan = '1' ELSE aux;
	--Delay
	info(0) <= sumz;
	delays: FOR i IN 1 TO adderDelay 
		GENERATE		
			dly: ENTITY WORK.dataRegister GENERIC MAP(32)
													PORT MAP(clock,'0','1',info(i-1),info(i));
		END GENERATE;
END dotPointDelay_arch;
