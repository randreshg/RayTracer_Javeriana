---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------

ENTITY minimumDistance IS
	GENERIC(	maxPrm				: INTEGER := 10;
				comparationTime	: INTEGER := 3;
				maxCount				: INTEGER := 100);
	PORT	 (	clock,rst			: IN  STD_LOGIC;	
				enable				: IN  STD_LOGIC;
				prmSize				: IN  INTEGER RANGE 0 TO (maxPrm-1);
				prmID					: IN  INTEGER RANGE 0 TO (maxPrm-1);
				p						: IN  VECTOR;
				m						: IN  FLOAT;
				distance				: IN  FLOAT;	
				minP					: OUT VECTOR;
				minM					: OUT FLOAT;
				minprmID				: OUT INTEGER RANGE 0 TO (maxPrm-1);
				takeData				: OUT STD_LOGIC);
END minimumDistance;

ARCHITECTURE minimumDistance_arch OF minimumDistance IS
	--FSM
	TYPE state IS (waiting,take);
	SIGNAL pr_state:	state;
	--Take data count
	SIGNAL takeMaxTick		:	STD_LOGIC;
	SIGNAL takeCount			:	INTEGER RANGE 0 TO maxCount-1;
	--Take data count
	SIGNAL cmpMaxTick			:	STD_LOGIC;
	SIGNAL cmpCount			:	INTEGER RANGE 0 TO (comparationTime-1);
	--MINIMUN DISTANCE
	--Min primitive info
	SIGNAL minDistanceEnable: 	STD_LOGIC;
	SIGNAL dmin					: 	FLOAT;
	SIGNAL IDprmmin			:  INTEGER RANGE 0 TO maxPrm-1;
	SIGNAL pmin					:  VECTOR;
	SIGNAL mmin					:  FLOAT;
	--Comparator
	SIGNAL alb					:  STD_LOGIC;
	--Aux
	SIGNAL aux					:  STD_LOGIC;
	SIGNAL d						:  INTEGER RANGE 0 TO maxCount-1;

BEGIN
	--FSM
	sequential: PROCESS(rst, clock)
	BEGIN
		IF (rst = '1') THEN
			pr_state	<=	waiting;
		ELSIF (RISING_EDGE(clock)) THEN
			CASE pr_state IS
				WHEN waiting	=>
					IF (takeCount = 1) THEN
						pr_state <= take;
					ELSE
						pr_state <= waiting;
					END IF;
				WHEN take	=>
					IF (enable = '1') THEN
						pr_state <= take;
					ELSE
						pr_state <= waiting;
					END IF;					
			END CASE;
		END IF;
	END PROCESS sequential;
	
	--TAKE DATA COUNTER
	---------------------------Take data count-------------------------------
	d <= prmSize * comparationTime;
	--Takes the time to get the distance
	takeCounter: ENTITY WORK.maxcounterCount  	GENERIC MAP(maxCount)
																PORT MAP	  (clock,rst,enable,d,takeMaxTick,takeCount);
	aux <= '1' WHEN takeCount = 0 AND enable = '1' ELSE '0';
	takeData <= aux WHEN pr_state = take ELSE '0' ;	
	---------------------------Take data count-------------------------------
	--Takes the compare time
	cmpCounter: ENTITY WORK.counterCount  			GENERIC MAP(comparationTime)
																PORT MAP	  (clock,rst,enable,cmpMaxTick,cmpCount);
																
	--MINIMUM DISTANCE
	-----------------------------Min distance--------------------------------
	--Saves the min distance
	minDist: 	ENTITY WORK.dataRegister 	 		GENERIC MAP(32)													
																PORT MAP(clock,rst,minDistanceEnable,distance,dmin);
	--Saves the ID of the closest primitive
	idtprmMin: 	ENTITY WORK.intRegister 	 		GENERIC MAP(maxPrm)													
																PORT MAP(clock,rst,minDistanceEnable,prmID,IDprmmin);
	--Saves the intersection point of the closest primitive
	pPrmMin: 	ENTITY WORK.vectorRegister	 		PORT MAP(clock,rst,minDistanceEnable,p,pmin);
	--Saves the m of the closest primitive
	mPrmMin: 	ENTITY WORK.dataRegister 	 		GENERIC MAP(32)			
																PORT MAP(clock,rst,minDistanceEnable,m,mmin);
	--Enables  the registers
	minDistanceEnable <= '1' WHEN aux = '1'     AND enable = '1'			 		ELSE
								'1' WHEN cmpCount = 1  AND enable = '1' AND alb = '1' ELSE '0';
	-----------------------------Comparator-----------------------------------
	--Compares dmin and distance
	comparator : ENTITY WORK.lessThan  				PORT MAP(clock,distance,dmin,alb);
	
	--OUTPUT	
	minprmID    <= IDprmmin WHEN enable = '1' ELSE 0;
	minP		   <= pmin		WHEN enable = '1' ELSE zero;
	minM		   <= mmin		WHEN enable = '1' ELSE zeros;
END minimumDistance_arch;
