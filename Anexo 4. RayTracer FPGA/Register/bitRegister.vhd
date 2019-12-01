------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
------------------------------------------------------

ENTITY bitRegister IS
	PORT	  ( clk,rst			: IN  STD_LOGIC;	
				 enable			: IN  STD_LOGIC;
				 dataIn			: IN  STD_LOGIC;		
				 dataOut			: OUT STD_LOGIC);		
END bitRegister;

ARCHITECTURE my_arch OF bitRegister IS
	SIGNAL data : STD_LOGIC := '0';
BEGIN
	--Out
	dataOut <= data;
	
	PROCESS(clk,rst)
	BEGIN
		IF (rst = '1') THEN
			data	 <= '0';					
		ELSIF (RISING_EDGE(clk)) THEN	
			IF(enable = '1') THEN
				data <= dataIn;
			END IF;
		END IF;
	END PROCESS;
	
END ARCHITECTURE my_arch;