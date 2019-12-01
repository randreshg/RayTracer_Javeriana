---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.ALL;

----------------------------------------------------------
ENTITY dotPointSub IS
	PORT	 (	clock   		: IN  STD_LOGIC; 
				dataA 		: IN  VECTOR;
				dataB			: IN  VECTOR;
				r				: IN  FLOAT;
				result 		: OUT FLOAT);
END dotPointSub;

ARCHITECTURE dotPointSub_arch OF dotPointSub IS
	SIGNAL sumx    	: FLOAT;
	SIGNAL sumy    	: FLOAT;
	SIGNAL sumz    	: FLOAT;
	SIGNAL sumxy     	: FLOAT;
	SIGNAL sumzr     	: FLOAT;
	SIGNAL rr	     	: FLOAT;
BEGIN
	--Block instantiation
	mult_x: ENTITY WORK.multiplier  PORT MAP(clock,dataA(0),dataB(0),sumx);
	mult_y: ENTITY WORK.multiplier  PORT MAP(clock,dataA(1),dataB(1),sumy);   
	mult_z: ENTITY WORK.multiplier  PORT MAP(clock,dataA(2),dataB(2),sumz);  
	mult_r: ENTITY WORK.multiplier  PORT MAP(clock,r,r,rr);  
	add_xy: ENTITY WORK.addSub 	  PORT MAP('1',clock,sumx,sumy,sumxy);	
   sub_zr: ENTITY WORK.addSub		  PORT MAP('0',clock,sumz,rr,sumzr);
	total:  ENTITY WORK.addSub		  PORT MAP('1',clock,sumxy,sumzr,result);	
	
END dotPointSub_arch;
