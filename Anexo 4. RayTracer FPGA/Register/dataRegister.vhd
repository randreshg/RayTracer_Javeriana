
------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
------------------------------------------------------

ENTITY dataRegister IS
   GENERIC ( bits  			: INTEGER := 21);
	PORT	  ( clk,rst			: IN  STD_LOGIC;
				 enable			: IN	STD_LOGIC;
				 dataIn			: IN  STD_LOGIC_VECTOR(bits-1 DOWNTO 0);		
				 dataOut			: OUT STD_LOGIC_VECTOR(bits-1 DOWNTO 0));		
END dataRegister;

ARCHITECTURE my_arch OF dataRegister IS
	SIGNAL data : STD_LOGIC_VECTOR(bits-1 DOWNTO 0):= (OTHERS => '0');
BEGIN
	--Out
	dataOut <= data;
	
	PROCESS(clk,rst)
	BEGIN
		IF (rst = '1') THEN
			data	 <=	(OTHERS => '0');					
		ELSIF (RISING_EDGE(clk)) THEN	
			IF(enable = '1') THEN
				data <= dataIn;
			END IF;
		END IF;
	END PROCESS;
	
END ARCHITECTURE my_arch;
