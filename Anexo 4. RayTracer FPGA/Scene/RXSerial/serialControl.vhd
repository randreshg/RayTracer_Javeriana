----------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------------
ENTITY serialControl IS
	PORT	(	clk						:	IN		STD_LOGIC;
				rst						:	IN		STD_LOGIC;
				enable					:  IN    STD_LOGIC;
				max_tickTime			:	IN		STD_LOGIC;
				max_tickBits			:	IN		STD_LOGIC;
				data_in					:	IN	   STD_LOGIC;
				serialRegister_enable:  OUT   STD_LOGIC;
				timeCounter_enable	:	OUT	STD_LOGIC;
				timeCounter_rst   	:	OUT	STD_LOGIC;
				bitCounter_enable		:	OUT	STD_LOGIC;
				bitCounter_rst   		:	OUT	STD_LOGIC);
END ENTITY serialControl;
----------------------------------------------------------------
ARCHITECTURE fsm OF serialControl IS
	TYPE state IS (waiting, count,rstBitCounter,inc_bits,stop,serialEnd);
	SIGNAL pr_state:	state:= waiting;
BEGIN
	--OUTPUT
	serialRegister_enable	<= '1'  WHEN pr_state = inc_bits  		ELSE '0';  
	timeCounter_enable		<= '1'  WHEN pr_state = count  OR 
													 pr_state = stop    			ELSE '0';
	timeCounter_rst			<= '1'  WHEN pr_state = inc_bits  		ELSE '0';
	bitCounter_enable			<= '1'  WHEN pr_state = inc_bits  		ELSE	'0';
	bitCounter_rst				<= '1'  WHEN pr_state = rstBitCounter  ELSE '0';

	sequential: PROCESS(rst, clk)
	BEGIN
		IF (rst = '1') THEN
			pr_state	<=	waiting;
		ELSIF (RISING_EDGE(clk)) THEN
			CASE pr_state IS
				WHEN waiting	=>
					IF (data_in = '0' AND enable = '1') THEN
						pr_state <= count;
					ELSE
						pr_state <= waiting;
					END IF;
				WHEN count	=>
					IF (max_tickTime = '0') THEN
						pr_state <= count;
					ELSE
						pr_state <= inc_bits;
					END IF;
				WHEN inc_bits	=>
					IF (max_tickBits = '0') THEN
						pr_state <= count;
					ELSE
						pr_state <= rstBitCounter;
					END IF;
				WHEN rstBitCounter =>
					pr_state <= stop;
				WHEN stop	=>
					IF (max_tickTime = '0') THEN
						pr_state <= stop;
					ELSE
						pr_state <= waiting;
					END IF;
				WHEN serialEnd	=>
					IF (max_tickTime = '0') THEN
						pr_state <= stop;
					ELSE
						pr_state <= waiting;
					END IF;
			END CASE;
		END IF;
	END PROCESS sequential;
END ARCHITECTURE fsm;