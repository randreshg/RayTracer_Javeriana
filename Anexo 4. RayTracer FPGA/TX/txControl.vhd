----------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------------
ENTITY txControl IS
	PORT	(	clk						:	IN		STD_LOGIC;
				rst						:	IN		STD_LOGIC;
				enable					:  IN    STD_LOGIC;
				pixelDone				:  IN	   STD_LOGIC;
				bitDone					:  IN	   STD_LOGIC;
				timeDone					: 	IN		STD_LOGIC;
				pixelEnable				:  OUT   STD_LOGIC;
				bitEnable				:  OUT   STD_LOGIC;
				bitReset					:  OUT   STD_LOGIC;
				timeEnable				: 	OUT	STD_LOGIC);
END ENTITY txControl;
----------------------------------------------------------------
ARCHITECTURE fsm OF txControl IS
	TYPE state IS (waiting,addBit,addPixel,addTime,addBitTime);
	SIGNAL pr_state:	state:= waiting;
BEGIN
	--OUTPUT 
	timeEnable  <= '1'  WHEN pr_state = addTime 		AND 
									 timeDone = '0'	ELSE '0';
	bitReset		<= '1'  WHEN pr_state = addPixel		OR
									 pr_state = addTime		ELSE '0';
	bitEnable	<= '1'  WHEN pr_state = addBit 		OR
									 pr_state = addBitTime 	ELSE '0';
	pixelEnable	<= '1'  WHEN pr_state = addPixel	ELSE '0';

	sequential: PROCESS(rst, clk)
		VARIABLE timeCount : INTEGER RANGE 0 to 3 := 0;
	BEGIN
		IF (rst = '1') THEN
			pr_state	<=	waiting;
		ELSIF (RISING_EDGE(clk)) THEN
			CASE pr_state IS
				WHEN waiting	=>
					IF (enable = '1') THEN
						pr_state <= addBitTime;
					ELSE
						pr_state <= waiting;
					END IF;
				--SEND TIME
				WHEN addBitTime	=>
					IF (bitDone = '1') THEN
						pr_state <= addTime;
					ELSE
						pr_state <= addBitTime;
					END IF;
				WHEN addTime	=>
					IF (timeDone = '1') THEN
						pr_state <= addBit;
					ELSE
						pr_state <= addBitTime;
					END IF;
				--SEND PIXEL INFO
				WHEN addBit	=>
					IF (bitDone = '1') THEN
						pr_state <= addPixel;
					ELSE
						pr_state <= addBit;
					END IF;
				WHEN addPixel	=>
					IF (pixelDone = '1') THEN
						pr_state <= waiting;
					ELSE
						pr_state <= addBit;
					END IF;
			END CASE;
		END IF;
	END PROCESS sequential;
END ARCHITECTURE fsm;