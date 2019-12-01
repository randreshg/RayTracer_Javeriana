LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
---------------------------------------------------------------------------
ENTITY dataParse IS																
	GENERIC ( maxPrm				: INTEGER :=15);
	PORT	  ( clk		      	: IN 	STD_LOGIC;
				 rst	     		   : IN 	STD_LOGIC;
				 serialIn			: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
				 serialDone			: IN  STD_LOGIC;
				 floatIn          : IN  FLOAT;
				 floatDone			: IN  STD_LOGIC;
				 vectorIn         : IN  VECTOR;
				 vectorDone			: IN  STD_LOGIC;
				 prmDone				: IN  STD_LOGIC;
				 vectorEnable		: OUT STD_LOGIC;
				 vectorReset		: OUT STD_LOGIC;
				 floatEnable		: OUT STD_LOGIC;
				 floatReset			: OUT STD_LOGIC;
				 prmEnable			: OUT STD_LOGIC;
				 memoryEnable		: OUT STD_LOGIC;
				 prmSize				: OUT INTEGER RANGE 0 TO maxPrm-1;
				 prmData				: OUT PRIMITIVE;
				 prmType				: OUT STD_LOGIC;
				 observerData		: OUT OBSERVER;				 
				 lightData			: OUT VECTOR;		
				 systemEnable		: OUT STD_LOGIC;
				 LEDS					: OUT STD_LOGIC_VECTOR (6 DOWNTO 0));
END ENTITY;
---------------------------------------------------------------------------
ARCHITECTURE dataParse_arch OF dataParse IS
	--STATES
	TYPE state IS (obs, light, prm, prmGetType, prmGetData, addP, addF,
						addV, saveP, waiting, enableVectorI, enableVectorO, ending);
	SIGNAL pr_state:	state:= waiting;
	--CONSTANT
	CONSTANT maxF			: INTEGER := 8;
	CONSTANT maxV			: INTEGER := 4;
	--SIGNALS
	--Observer
	SIGNAL getObserver	: OBSERVER;  --[[scan],[pixelWidth],[pixelHeight],[position]]
	--Primitive
	SIGNAL getPrm			: PRIMITIVE; --[[Center],Radio,[V],maxm]
	SIGNAL getPrmType		: STD_LOGIC;
	--Light
	SIGNAL getLight		: VECTOR;	 --[Center]
	--Aux
	SIGNAL countMax		: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL number 			: STD_LOGIC_VECTOR(0 TO 7);
	
	
	
BEGIN
	--LEDS
	LEDS(0) <= '1' WHEN pr_state = waiting ELSE '0';
	LEDS(1) <= '1' WHEN pr_state = prm	  ELSE '0';
	LEDS(2) <= '1' WHEN pr_state = prmGetType ELSE '0';
	LEDS(3) <= '1' WHEN pr_state = prmGetData ELSE '0';
	LEDS(4) <= '1' WHEN pr_state = light ELSE '0';
	LEDS(5) <= '1' WHEN pr_state = obs ELSE '0';
	LEDS(6) <= prmDone;
	--Output
	memoryEnable	<= '1' WHEN (pr_state = saveP)			ELSE '0';
	floatReset 		<= '1' WHEN (pr_state = addF				OR
										 pr_state = waiting			OR
										 pr_state = enableVectorI	OR
										 pr_state = enableVectorO)	ELSE '0';
	floatEnable  	<= '1' WHEN (pr_state = prmGetData 		OR 
										 pr_state = obs				OR
										 pr_state = light)	AND serialDone = '1' ELSE '0';
	vectorEnable 	<= '1' WHEN (pr_state = enableVectorI 	OR 											 
										 pr_state = enableVectorO)	ELSE '0';
	vectorReset		<= '1' WHEN (pr_state = waiting			OR
										 pr_state = addV)				ELSE '0';
	systemEnable   <= '1' WHEN  pr_state = ending 			ELSE '0';
	prmEnable		<= '1' WHEN  pr_state = addP	 			ELSE '0';
	
	
	number 			<= countMax;
	prmSize 			<= TO_INTEGER(UNSIGNED(number));
	prmData			<= getPrm;
	prmType 			<= getPrmType;	
	observerData 	<= getObserver;
	lightData 		<= getLight;

	--PROCESS
	sequential: PROCESS(rst, clk)
		--Variable signals
		VARIABLE countf			: INTEGER RANGE 0 TO 8 := 0;
		VARIABLE countv			: INTEGER RANGE 0 TO 4 := 0;
	BEGIN
		IF (rst = '1') THEN
			pr_state	<=	waiting;
		ELSIF (RISING_EDGE(clk)) THEN			
			CASE pr_state IS
				--Waiting for the letter identification
				WHEN waiting	=>
					countf := 0;
					countv := 0;
					IF (serialDone = '1') 				THEN
						IF (serialIn = "01010000") 	THEN --Primitive
							pr_state <= prm;
						ELSIF	(serialIn = "01001100") THEN --Light
							pr_state <= light;
						ELSIF	(serialIn = "01001111") THEN --Observer
							pr_state <= obs;
						ELSIF	(serialIn = "01000101") THEN --End
							pr_state <= ending;
						ELSE
							pr_state <= waiting;
						END IF;
					ELSE
						pr_state <= waiting;
					END IF;			
				--Parsing info							
				WHEN prm	=>
					--Save number of primitives
					IF (serialDone = '1') THEN	
						countMax <= serialIn;
						pr_state <= prmGetType;
					ELSE
						pr_state <= prm;
					END IF;
					
				WHEN prmGetType	=>
					--Save primitive type
					IF (serialDone = '1') THEN
						IF (serialIn = "01010011") THEN
							getPrmType <= '0';
						ELSIF (serialIn = "01000011") THEN
							getPrmType <= '1';
						END IF;
						pr_state <= prmGetData;
					ELSE
						pr_state <= prmGetType;
					END IF;
				
				WHEN prmGetData	=>
					--Waiting for primitive info
					IF (floatDone = '1') THEN
						pr_state <= addF;
					ELSE
						pr_state <= prmGetData;
					END IF;
				
				WHEN light	=>
					--Waiting for vector info
					IF (vectorDone = '1') THEN
						getLight <= vectorIn;
						pr_state <= waiting;			
					ELSIF (floatDone = '1') THEN
						pr_state <= enableVectorI;
					ELSE
						pr_state <= light;
					END IF;
				
				WHEN enableVectorI =>
					pr_state <= light;
					
				WHEN obs	=>
					--Waiting for vector info
					IF (vectorDone = '1') THEN
						pr_state <= addV;			
					ELSIF (floatDone = '1') THEN
						pr_state <= enableVectorO;
					ELSE
						pr_state <= obs;					
					END IF;
					
				WHEN enableVectorO =>
					pr_state <= obs;						
					
				WHEN ending =>
					pr_state <= ending;
				
				WHEN saveP =>
					pr_state <= addP;	
				
				--Add counters
				WHEN addV =>
					getObserver(countv) <= vectorIn;
					countv := countv + 1;					
					IF (countv = maxV) THEN
						pr_state <= waiting;
					ELSE
						pr_state <= obs;
					END IF;
					
				WHEN addP =>
					countf := 0;					
					IF (prmDone = '1') THEN					
						pr_state <= waiting;
					ELSE					   
						pr_state <= prmGetType;
					END IF;
					
				WHEN addF =>
					getPrm(countf) <= floatIn;
					countf := countf + 1;					
					IF (countf = maxF) THEN
						pr_state <= saveP;
					ELSE
						pr_state <= prmGetData;
					END IF;			
									
			END CASE;
		END IF;
	END PROCESS sequential;
END ARCHITECTURE dataParse_arch;