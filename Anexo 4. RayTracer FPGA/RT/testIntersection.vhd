LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.ALL;

----------------------------------------------------------
ENTITY testIntersection IS
	GENERIC(	delay					: INTEGER := 10;
				sqrtDelay			: INTEGER := 16;
				multiplierDelay 	: INTEGER := 5;
				adderDelay			: INTEGER := 7;
				divisionDelay		: INTEGER := 6;
				dotPointDelay		: INTEGER := 4);
	PORT	 (	enable				: IN   STD_LOGIC;
				clock   				: IN   STD_LOGIC; 
				rst   				: IN   STD_LOGIC;
				primitive			: IN   STD_LOGIC;
				center	 			: IN   VECTOR;
				observer				: IN   VECTOR;
				Rdir					: IN   VECTOR;
				r						: IN   FLOAT;
				v						: IN   VECTOR; 
				mMax              : IN   FLOAT;
				distance				: OUT  FLOAT;
				m						: OUT  FLOAT;
				p						: OUT  VECTOR;
				done					: OUT  STD_LOGIC);
END testIntersection;

ARCHITECTURE testIntersection_arch OF testIntersection IS
	--Block delay
	CONSTANT delaycalSphere  	: INTEGER:= dotPointDelay;
	CONSTANT delaycalCylinder	: INTEGER:= dotPointDelay + multiplierDelay + adderDelay;
	CONSTANT parametersPipeline: INTEGER:= delaycalCylinder - delaycalSphere;
	CONSTANT delayParameters 	: INTEGER:= delaycalCylinder; 
	CONSTANT delayQuadratic  	: INTEGER:= multiplierDelay + adderDelay + sqrtDelay +
														adderDelay + divisionDelay + 1;
	CONSTANT delayHitBody	 	: INTEGER:= multiplierDelay + adderDelay + adderDelay + 
														dotPointDelay + 1;
	--Accumulated delay
	CONSTANT delayFirstStep	 	: INTEGER:= adderDelay;
	CONSTANT delaySecondStep 	: INTEGER:= delayParameters + delayFirstStep;											
	CONSTANT delayThirdStep	 	: INTEGER:= delayQuadratic + delaySecondStep;
	CONSTANT delayCenter		 	: INTEGER:= delayFirstStep + delayParameters + delayQuadratic;
	--Final delay
	CONSTANT finalDelay			: INTEGER:= delayThirdStep + delayHitBody;
	
	--DELAY SIGNALS
	TYPE data1   IS ARRAY (delayFirstStep DOWNTO 0) OF FLOAT;
	TYPE data2   IS ARRAY (delayThirdStep DOWNTO 0) OF VECTOR;
	TYPE data2_1 IS ARRAY (delayThirdStep DOWNTO 0) OF STD_LOGIC;
	TYPE data2_2 IS ARRAY (delayThirdStep DOWNTO 0) OF FLOAT;
	TYPE data2_3 IS ARRAY (delay DOWNTO 0) OF VECTOR;	
	TYPE data3   IS ARRAY (delayCenter DOWNTO 0) OF VECTOR;
	SIGNAL rDelay		: data1;
	SIGNAL vDelay		: data2;
	SIGNAL prmDelay	: data2_1;
	SIGNAL mMaxDelay	: data2_2;
	SIGNAL RdirDelay	: data2_3;
	SIGNAL centerDelay: data3;
	--Signals
	SIGNAL VOC			: VECTOR;
	SIGNAL a,b,c		: FLOAT;
	SIGNAL as,bs,cs	: FLOAT;
	SIGNAL ac,bc,cc	: FLOAT;
	SIGNAL d,d1       : FLOAT;
	SIGNAL result		: FLOAT;
	SIGNAL result1		: FLOAT;
	--PIPELINE COUNTER
	SIGNAL maxTickPP	: STD_LOGIC;
	SIGNAL ppEna		: STD_LOGIC;	
	

BEGIN
	--Pipeline counter
	ppCounter: 	ENTITY WORK.counterTick			GENERIC MAP(delay)
															PORT MAP	  (clock,rst,ppEna,maxTickPP);
	--Enables pipeline counter
	ppEna  <= enable AND (NOT maxTickPP);	
	--------------------------------------------First step-------------------------------------------------
	VOC_calc: 	ENTITY WORK.vectorSum 			PORT MAP   ('0',clock,observer,center,VOC);
	--------------------------------------------Second step------------------------------------------------
	--Calculate a, b and c for the primitive
	VOC2_r2: 	ENTITY WORK.dotPointSub 		PORT MAP	  (clock,VOC,VOC,rDelay(delayFirstStep),result); 
	Sphere: 		ENTITY WORK.calcSphere 			GENERIC MAP(parametersPipeline,adderDelay)
															PORT MAP	  (clock,rst,VOC,RdirDelay(delayFirstStep),
																			result,as,bs,cs);	
	Cylinder: 	ENTITY WORK.calcCylinder 		GENERIC MAP(multiplierDelay,adderDelay)
															PORT MAP	  (clock,rst,VOC,RdirDelay(delayFirstStep),
																			vDelay(delayFirstStep),result,ac,bc,cc);
	--Select the result	
	a <= ac WHEN prmDelay(delaySecondStep)='1' ELSE as;
	b <= bc WHEN prmDelay(delaySecondStep)='1' ELSE bs;
	c <= cc WHEN prmDelay(delaySecondStep)='1' ELSE cs;
	--------------------------------------------Third step-------------------------------------------------
	QSolution: 	ENTITY WORK.quadraticSolution GENERIC MAP(sqrtDelay,multiplierDelay,adderDelay,divisionDelay) 
															PORT MAP	  (clock,rst,a,b,c,d);		
	-------------------------------------------Fourth step-------------------------------------------------
	HitBody: 	ENTITY WORK.hitBody				GENERIC MAP(delayHitBody,dotPointDelay,multiplierDelay,adderDelay)
															PORT MAP   (clock,observer,prmDelay(delayThirdStep),d,
																			RdirDelay(delayThirdStep),vDelay(delayThirdStep),
																			centerDelay(delayCenter),mMaxDelay(delayThirdStep),d1,m,p);
	-----------------------------------------------Output--------------------------------------------------
	distance <= d1 WHEN maxTickPP = '1' ELSE inf;
	done 		<= maxTickPP;
	-----------------------------------------------Delays--------------------------------------------------
	--Primitive delay
	prmDelay(0) <= primitive;
	delays0: FOR i IN 1 TO delayThirdStep
		GENERATE		
			dly0 : ENTITY WORK.bitRegister   	PORT MAP   (clock,'0','1',prmDelay(i-1),prmDelay(i));
		END GENERATE;
	
	--Rdir delay
	RdirDelay(0) <= Rdir;
	delays1: FOR i IN 1 TO delayThirdStep
		GENERATE		
			dly1 : ENTITY WORK.vectorRegister 	PORT MAP   (clock,'0','1',RdirDelay(i-1),RdirDelay(i));
		END GENERATE;
	
	--V delay
	vDelay(0) <= v;
	delays2: FOR i IN 1 TO delayThirdStep
		GENERATE		
			dly2 : ENTITY WORK.vectorRegister 	PORT MAP   (clock,'0','1',vDelay(i-1),vDelay(i));
		END GENERATE;
		
	--VOC delay
	centerDelay(0) <= center;
	delays3: FOR i IN 1 TO delayCenter
		GENERATE		
			dly3 : ENTITY WORK.vectorRegister 	PORT MAP   (clock,'0','1',centerDelay(i-1),centerDelay(i));
		END GENERATE;	
	
	--mMax delay
	mMaxDelay(0) <= mMax;
	delays4: FOR i IN 1 TO delayThirdStep 
		GENERATE		
			dly4 : ENTITY WORK.dataRegister 		GENERIC MAP(32)													
															PORT MAP   (clock,'0','1',mMaxDelay(i-1),mMaxDelay(i));
		END GENERATE;
		
	--Radius delay
	rDelay(0) <= r;
	delays5: FOR i IN 1 TO delayFirstStep
		GENERATE		
			dly5 : ENTITY WORK.dataRegister 		GENERIC MAP(32)													
															PORT MAP   (clock,'0','1',rDelay(i-1),rDelay(i));
		END GENERATE;
		
END testIntersection_arch;

