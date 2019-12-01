---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------
ENTITY mainControl IS
	PORT	 (	clock   			: IN  STD_LOGIC;
				rst				: IN  STD_LOGIC;
				enable         : IN  STD_LOGIC;
				traceDone      : IN  STD_LOGIC;
				txDone			: IN  STD_LOGIC;
			   traceEnable	  	: OUT STD_LOGIC;
				traceReset		: OUT STD_LOGIC;
				serialEnable	: OUT STD_LOGIC;
				txEnable			: OUT STD_LOGIC);
				--LEDS				: OUT STD_LOGIC_VECTOR (4 DOWNTO 0));
END mainControl;

ARCHITECTURE mainControl_arch OF mainControl IS	
	TYPE state IS (waiting,tracer,reset,tx);
	SIGNAL pr_state:	state;
	
BEGIN
	--Output
--	LEDS(0)  <= '1' 	  WHEN pr_state = waiting  ELSE '0';
--	LEDS(1)  <= '1' 	  WHEN pr_state = tracer   ELSE '0';
--	LEDS(2)  <= enable;
--	LEDS(3)  <= traceDone;
--	LEDS(4)  <= txDone;
	
	traceEnable  <= '1' WHEN pr_state = tracer   ELSE '0';
	traceReset 	 <= '1' WHEN pr_state = reset OR rst = '1'	ELSE '0';
	serialEnable <= '1' WHEN pr_state = waiting  ELSE '0';
	txEnable		 <= '1' WHEN pr_state = tx			ELSE '0';
	--FSM
	sequential: PROCESS(rst, clock)
	BEGIN
		IF (rst = '1') THEN
			pr_state	<=	waiting;
		ELSIF (RISING_EDGE(clock)) THEN
			CASE pr_state IS
				WHEN waiting	=>
					IF (enable = '1') THEN
						pr_state <= reset;
					ELSE
						pr_state <= waiting;
					END IF;
				WHEN reset	=>
					pr_state <= tracer;
				WHEN tracer	=>
					IF (traceDone = '1') THEN
						pr_state <= tx;
					ELSE
						pr_state <= tracer;
					END IF;
				WHEN tx	=>
					IF (txDone = '1') THEN
						pr_state <= waiting;
					ELSE
						pr_state <= tx;
					END IF;
			END CASE;
		END IF;
	END PROCESS sequential;
END mainControl_arch;
