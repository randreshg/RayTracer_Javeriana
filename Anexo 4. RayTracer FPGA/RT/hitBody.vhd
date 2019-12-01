LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.ALL;

----------------------------------------------------------
ENTITY hitBody IS
	GENERIC(	delay					: INTEGER := 100;
				dotPointDelay		: INTEGER := 10;
				multiplierDelay 	: INTEGER := 5;
				adderDelay			: INTEGER := 7);
	PORT	 (	clock   				: IN   STD_LOGIC;
				observer				: IN   VECTOR;
				primitive			: IN   STD_LOGIC;
				d						: IN   FLOAT;
				Rdir					: IN   VECTOR;
				v						: IN   VECTOR; 
				center            : IN   VECTOR;
				mMax					: IN   FLOAT;
				distance				: OUT  FLOAT;
				mOut					: OUT  FLOAT;
				p						: OUT  VECTOR);
END hitBody;

ARCHITECTURE hitBody_arch OF hitBody IS
	--DELAY SIGNALS
	--Center delay
	CONSTANT delayCenter : INTEGER := multiplierDelay + adderDelay;
	TYPE data1 IS ARRAY (delayCenter DOWNTO 0) OF VECTOR;
	SIGNAL centerDelay  	: data1;
	--v delay
	CONSTANT delayV		: INTEGER := multiplierDelay + adderDelay + adderDelay;
	TYPE data2 IS ARRAY (delayV DOWNTO 0) OF VECTOR;
	SIGNAL vDelay  		: data2;
	--Distance delay
	TYPE data3 IS ARRAY (delay DOWNTO 0) OF FLOAT;
	SIGNAL dDelay     	: data3;
	--Distance delay
	TYPE data4 IS ARRAY (delay DOWNTO 0) OF STD_LOGIC;
	SIGNAL primitiveDelay: data4;
	--P delay
	CONSTANT delayP		: INTEGER := adderDelay + dotPointDelay + 1;
	TYPE data5 IS ARRAY (delayP DOWNTO 0) OF VECTOR;
	SIGNAL pDelay: data5;
	--mMax delay
	CONSTANT delaymMax	: INTEGER := multiplierDelay + adderDelay +
												 adderDelay + dotPointDelay;
	TYPE data6 IS ARRAY (delaymMax DOWNTO 0) OF FLOAT;
	SIGNAL mMaxDelay: data6;
	
	SIGNAL mDelay  		: FLOAT;
	
	--AUXILIAR SIGNALS
	SIGNAL intPoint		: VECTOR;
	SIGNAL result			: VECTOR;
	SIGNAL m,mAux			: FLOAT;
	SIGNAL dRdir      	: VECTOR;
	SIGNAL agb				: STD_LOGIC;
	SIGNAL alb        	: STD_LOGIC;

BEGIN
	--Calculate if the ray hits the cylinder body
	--d*Rdir
	product1: 		ENTITY WORK.scalarProduct 	PORT MAP   (clock,d,Rdir,dRdir);
	--d*Rdir+observer	
	pCalc: 			ENTITY WORK.vectorSum     	PORT MAP   ('1',clock,dRdir,observer,intPoint);	
	--d*Rdir+observer-center
	r: 				ENTITY WORK.vectorSum     	PORT MAP   ('0',clock,intPoint,centerDelay(delayCenter),result);
	--(result)dot(V)
	dotPoint: 		ENTITY WORK.dotPointDelay 	GENERIC MAP(adderDelay)
															PORT MAP	  (clock,result,vDelay(delayV),m);
	--Compare if m is between 0 and mMax
	greaterThan: 	ENTITY WORK.greaterThan  	PORT MAP   (clock,m,zeros,agb);
	lessThan: 		ENTITY WORK.lessThan  		PORT MAP   (clock,m,mMaxDelay(delaymMax),alb);
	mdly: 			ENTITY WORK.dataRegister 	GENERIC MAP(32)													
															PORT MAP   (clock,'0','1',m,mOut);
	-----------------------------------------------Output--------------------------------------------------
	--Select the distance
	distance <= dDelay(delay) WHEN primitiveDelay(delay)='0' ELSE
					dDelay(delay) WHEN primitiveDelay(delay)='1' AND agb='1' AND alb = '1' ELSE inf;
	p 			<= pDelay(delayP) WHEN primitiveDelay(delay)='0' ELSE
					pDelay(delayP) WHEN primitiveDelay(delay)='1' AND agb='1' AND alb = '1' ELSE (OTHERS=>inf);
	-----------------------------------------------Delays--------------------------------------------------		
	--Center delay
	centerDelay(0) <= center;
	delays1: FOR i IN 1 TO delayCenter
		GENERATE		
			dly1 : ENTITY WORK.vectorRegister	PORT MAP(clock,'0','1',centerDelay(i-1),centerDelay(i));
		END GENERATE;
	--v delay
	vDelay(0) <= v;
	delays2: FOR i IN 1 TO delayV
		GENERATE		
			dly2 : ENTITY WORK.vectorRegister	PORT MAP(clock,'0','1',vDelay(i-1),vDelay(i));
		END GENERATE;
	--Distance delay
	dDelay(0) <= d;
	delays3: FOR i IN 1 TO delay
		GENERATE		
			dly3 : ENTITY WORK.dataRegister 		GENERIC MAP(32)													
															PORT MAP(clock,'0','1',dDelay(i-1),dDelay(i));
		END GENERATE;
	--Primitive delay
	primitiveDelay(0) <= primitive;
	delays4: FOR i IN 1 TO delay
		GENERATE		
			dly4 : ENTITY WORK.bitRegister		PORT MAP(clock,'0','1',primitiveDelay(i-1),primitiveDelay(i));
		END GENERATE;
	--P delay
	pDelay(0) <= intPoint;
	delays5: FOR i IN 1 TO delayP
		GENERATE		
			dly5 : ENTITY WORK.vectorRegister	PORT MAP(clock,'0','1',pDelay(i-1),pDelay(i)); 
		END GENERATE;
	--mMax delay
	mMaxDelay(0) <= mMax;
	delays6: FOR i IN 1 TO delaymMax 
		GENERATE		
			dly6 : ENTITY WORK.dataRegister 		GENERIC MAP(32)													
															PORT MAP   (clock,'0','1',mMaxDelay(i-1),mMaxDelay(i));
		END GENERATE;
	
	

END hitBody_arch;

