---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;

----------------------------------------------------------
ENTITY quadraticSolution IS
	GENERIC(	sqrtDelay			: INTEGER := 16;
				multiplierDelay 	: INTEGER := 5;
				adderDelay			: INTEGER := 7;
				divisionDelay		: INTEGER := 6);
	PORT	 (	clock   				: IN  STD_LOGIC; 
				rst   				: IN  STD_LOGIC;
				a						: IN  FLOAT;
				b						: IN  FLOAT;
				c						: IN  FLOAT;
				distance				: OUT FLOAT);
END quadraticSolution;

ARCHITECTURE quadraticSolution_arch OF quadraticSolution IS
	--Signals
	SIGNAL result1   	: FLOAT;	--b^2 - ac
	SIGNAL result2  	: FLOAT;	--sqrt(b^2 - ac)
	SIGNAL result3  	: FLOAT;	--sol1/a
	SIGNAL result4  	: FLOAT; --sol2/a
	SIGNAL b2       	: FLOAT; --b^2
	SIGNAL ac    		: FLOAT; --a*c
	SIGNAL sol2,sol1 	: FLOAT;  
	SIGNAL res1,res2  : FLOAT;
   SIGNAL solution1	: FLOAT;
	SIGNAL solution2  : FLOAT;
	SIGNAL nan1,nan2  : STD_LOGIC;
	SIGNAL alb,agb		: STD_LOGIC;
	--Delay by block
	CONSTANT firstStepDelay  : INTEGER:= multiplierDelay;
	CONSTANT secondStepDelay : INTEGER:= adderDelay;
	CONSTANT thirdStepDelay  : INTEGER:= sqrtDelay;
	CONSTANT fourthStepDelay : INTEGER:= adderDelay;
	CONSTANT fifthStepDelay  : INTEGER:= divisionDelay;
	CONSTANT sixthStepDelay  : INTEGER:= 1;
	--Delay signals
	CONSTANT delay1   : INTEGER:= firstStepDelay + secondStepDelay + 
											thirdStepDelay + fourthStepDelay;
	CONSTANT delay2   : INTEGER:= firstStepDelay + secondStepDelay + thirdStepDelay;
	
   TYPE data1 IS ARRAY (delay2 DOWNTO 0) OF FLOAT;
	SIGNAL bDelay 		: data1;
	TYPE data2 IS ARRAY (delay1 DOWNTO 0) OF FLOAT;
	SIGNAL aDelay		: data2;
BEGIN	
	---------------------------------------------First step-----------------------------------------------------
	--b^2
	mult1 	  : ENTITY WORK.multiplier  			PORT MAP(clock,b,b,b2);
	--a*c
	mult2		  : ENTITY WORK.multiplier  			PORT MAP(clock,a,c,ac);
	--------------------------------------------Second step-----------------------------------------------------
	--b^2 - a*c
	Calc		  : ENTITY WORK.addSub		 			PORT MAP('0',clock,b2,ac,result1);
	---------------------------------------------Third step-----------------------------------------------------
	--Sqrt
	sqrt		  : ENTITY WORK.rootSquare 			PORT MAP(clock,result1,result2);
	---------------------------------------------Fourth step----------------------------------------------------
	--Find solutions
	solu1		  : ENTITY WORK.addSubNan	 			PORT MAP('0',clock,bDelay(delay2),result2,nan1,sol1);
	solu2		  : ENTITY WORK.addSubNan	 			PORT MAP('1',clock,bDelay(delay2),result2,nan2,sol2);
	res1 		  <= inf 			WHEN nan1 = '1' 	ELSE sol1;
	res2 		  <= inf 			WHEN nan2 = '1'	ELSE sol2;
	---------------------------------------------Fifth step-----------------------------------------------------
	---Solution/a
	Div1		  : ENTITY WORK.division	 			PORT MAP(clock,res1,aDelay(delay1),result3); 
	Div2		  : ENTITY WORK.division				PORT MAP(clock,res2,aDelay(delay1),result4);
	---------------------------------------------Sixth step-----------------------------------------------------
	--Find the distance
	greaterThan: ENTITY WORK.greaterThan  			PORT MAP(clock,result3,zeros,agb);
	lessThan	  : ENTITY WORK.lessThan  				PORT MAP(clock,result4,zeros,alb);
	s1			  : ENTITY WORK.dataRegister 			GENERIC MAP(32)													
																PORT MAP(clock,'0','1',result3,solution1);
   s2			  : ENTITY WORK.dataRegister 	 		GENERIC MAP(32)													
																PORT MAP(clock,'0','1',result4,solution2);
	-----------------------------------------------Output-------------------------------------------------------
	distance   <= inf 			WHEN alb = '1' 	ELSE
					  solution1		WHEN agb = '1' 	ELSE solution2;
	-----------------------------------------------Delays-------------------------------------------------------
	--(-b) delay
	bDelay(0) <= (NOT b(31))&b(30 DOWNTO 0);
	delays0: FOR i IN 1 TO delay2
		GENERATE		
			dly0 : ENTITY WORK.dataRegister 			GENERIC MAP(32)													
																PORT MAP(clock,'0','1',bDelay(i-1),bDelay(i));
		END GENERATE;		
	--a delay
	aDelay(0) <= a;
	delays1: FOR i IN 1 to delay1
		GENERATE 
			dly1 : ENTITY WORK.dataRegister			GENERIC MAP(32)
																PORT MAP(clock,'0','1',aDelay(i-1),aDelay(i));
		END GENERATE;
	
END quadraticSolution_arch;
