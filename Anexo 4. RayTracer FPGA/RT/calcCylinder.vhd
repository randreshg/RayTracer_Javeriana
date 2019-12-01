---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;

----------------------------------------------------------
ENTITY calcCylinder IS
	GENERIC(	multiplierDelay 	: INTEGER := 5;
				adderDelay			: INTEGER := 7);
	PORT	 (	clock   				: IN  STD_LOGIC; 
				rst   				: IN  STD_LOGIC; 
				VOCc	 				: IN  VECTOR;
				Rdir					: IN  VECTOR;
				v						: IN  VECTOR;
				result4				: IN  FLOAT;
				a						: OUT FLOAT;
				b						: OUT FLOAT;
				c						: OUT FLOAT);
END calcCylinder;

ARCHITECTURE calcCylinder_arch OF calcCylinder IS
	--Auxiliar data type
	TYPE data IS ARRAY (multiplierDelay DOWNTO 0) OF FLOAT;
	--Signals
	SIGNAL result1			: FLOAT;
	SIGNAL result2			: FLOAT;
	SIGNAL result3			: FLOAT;
	--SIGNAL result4			: FLOAT;
	SIGNAL aAux,bAux,cAux: FLOAT;
	SIGNAL result3Delay  : data;
	SIGNAL result4Delay  : data;
  
BEGIN
	------------------------------------------First step--------------------------------------------------------
	--RdirdotV
	RdirdotV: 		ENTITY WORK.dotPointDelay 	GENERIC MAP(adderDelay)
															PORT MAP	  (clock,Rdir,v,result1); 
	--VOCcdotV
	VOCcdotV: 		ENTITY WORK.dotPointDelay 	GENERIC MAP(adderDelay)
															PORT MAP	  (clock,VOCc,v,result2); 
	--VOCcdotRdir
	RdirdotVOCc: 	ENTITY WORK.dotPointDelay	GENERIC MAP(adderDelay)
															PORT MAP	  (clock,Rdir,VOCc,result3); 
	-----------------------------------------Second step--------------------------------------------------------															
	--(RdirdotV)^2
	multiply1: 		ENTITY WORK.multiplier		PORT MAP   (clock,result1,result1,aAux);	
	--RdirdotV * VOCcdotV
	multiply2: 		ENTITY WORK.multiplier 		PORT MAP	  (clock,result1,result2,bAux);  
	--(VOCcdotV)^2
	multiply3: 		ENTITY WORK.multiplier		PORT MAP	  (clock,result2,result2,cAux);	
	
	------------------------------------------Third step--------------------------------------------------------
	aCalc: 			ENTITY WORK.addSub			PORT MAP	  ('0',clock,X"3f800000",aAux,a);
	bCalc: 			ENTITY WORK.addSub			PORT MAP	  ('0',clock,result3Delay(multiplierDelay),bAux,b);
	cCalc: 			ENTITY WORK.addSub			PORT MAP	  ('0',clock,result4Delay(multiplierDelay),cAux,c);
	--------------------------------------------Delays----------------------------------------------------------
	--Result 3 delay
	result3Delay(0) <= result3;
	delay0: FOR i IN 1 TO multiplierDelay
		GENERATE		
			dly0: 	ENTITY WORK.dataRegister 	GENERIC MAP(32)													
															PORT MAP(clock,'0','1',result3Delay(i-1),result3Delay(i));
		END GENERATE;
	--Result4 delay
	result4Delay(0) <= result4;
	delay1: FOR i IN 1 TO multiplierDelay
		GENERATE		
			dly1: 	ENTITY WORK.dataRegister 	GENERIC MAP(32)													
															PORT MAP(clock,'0','1',result4Delay(i-1),result4Delay(i));
		END GENERATE;
END calcCylinder_arch;
