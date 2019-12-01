---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------
ENTITY normalVector IS
	GENERIC(	adderDelay        : INTEGER := 1;
				dotPointDelay		: INTEGER := 1;
				invsqrtDelay		: INTEGER := 7);
	PORT	 (	clock   				: IN  STD_LOGIC; 
				vIn					: IN  VECTOR;
				vOut					: OUT VECTOR);
END normalVector;

ARCHITECTURE normalVector_arch OF normalVector IS
	--Signals
	SIGNAL result1		  	: FLOAT; 	--vIn*vIn
	SIGNAL result2			: FLOAT;    --1/(vIn*vIn)
	SIGNAL result3			: VECTOR;   --vIn/(vIn*vIn)
	
	CONSTANT delayV   : INTEGER := dotPointDelay+invsqrtDelay;
	TYPE data IS ARRAY (delayV DOWNTO 0) OF VECTOR;
	SIGNAL vDelay 		: data;
	
BEGIN
	--Rdir2
	Rdir2		 : ENTITY WORK.dotPointDelay 	GENERIC MAP (adderDelay)
														PORT MAP(clock,vIn,vIn,result1);
	--1/(SQRT(Rdir2))										
	invSqrt:  	ENTITY WORK.inv_sqrt 		PORT MAP(clock,result1,result2); 
	--Rdir/(SQRT(Rdir2))	
	unitVector: ENTITY work.scalarProduct 	PORT MAP(clock,result2,vDelay(delayV),vOut);
	-----------------------------------------------Delays-------------------------------------------------------
	vDelay(0) <= vIn;
	delays1: FOR i IN 1 TO delayV
	GENERATE		
		dly1		 : ENTITY WORK.vectorRegister PORT MAP(clock,'0','1',vDelay(i-1),vDelay(i));
	END GENERATE;
END normalVector_arch;

