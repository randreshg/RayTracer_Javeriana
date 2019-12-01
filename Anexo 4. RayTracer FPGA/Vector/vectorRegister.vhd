
------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
------------------------------------------------------

ENTITY vectorRegister IS
	PORT	  ( clk,rst			: IN  STD_LOGIC;
				 enable			: IN  STD_LOGIC;
				 dataIn			: IN  VECTOR;		
				 dataOut			: OUT VECTOR);		
END vectorRegister;

ARCHITECTURE my_arch OF vectorRegister IS
	SIGNAL data : VECTOR;
BEGIN
	--Out
	dataOut <= data;
	
	PROCESS(clk,rst)
	BEGIN
		IF (rst = '1') THEN
			--data	 <=	(OTHERS => '0');					
		ELSIF (RISING_EDGE(clk)) THEN
			IF(enable = '1') THEN
				data <= dataIn;
			END IF;
		END IF;
	END PROCESS;
	
END ARCHITECTURE my_arch;
