---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------
ENTITY vectorSum  IS 
	PORT	 (	op				: IN  STD_LOGIC;
				clock   		: IN  STD_LOGIC; 
				dataA 		: IN  VECTOR;
				dataB			: IN  VECTOR;
				result    	: OUT VECTOR);
END vectorSum;

ARCHITECTURE vectorSum_arch OF vectorSum IS

	SIGNAL sumx    	: FLOAT;
	SIGNAL sumy    	: FLOAT;
	SIGNAL sumz    	: FLOAT;

BEGIN
	--Block instantiation
	sum_x:  ENTITY WORK.addSub PORT MAP(op,clock,dataA(0),dataB(0),sumx);
	sum_y:  ENTITY WORK.addSub PORT MAP(op,clock,dataA(1),dataB(1),sumy);   
	sum_z:  ENTITY WORK.addSub PORT MAP(op,clock,dataA(2),dataB(2),sumz);  
	
	result(0) <= sumx;
	result(1) <= sumy;
	result(2) <= sumz;

END vectorSum_arch;
