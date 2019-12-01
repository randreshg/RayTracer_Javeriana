------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
------------------------------------------------------

ENTITY intRegister IS
   GENERIC ( N 	  			: INTEGER := 21);
	PORT	  ( clk,rst			: IN  STD_LOGIC;	
				 enable			: IN  STD_LOGIC;
				 dataIn			: IN  INTEGER RANGE 0 TO (N-1);		
				 dataOut			: OUT INTEGER RANGE 0 TO (N-1));		
END intRegister;

ARCHITECTURE my_arch OF intRegister IS
	SIGNAL data : INTEGER RANGE 0 TO (N-1):=0;
BEGIN
	--Out
	dataOut <= data;
	
	PROCESS(clk,rst)
	BEGIN
		IF (rst = '1') THEN
			data	 <= 0;					
		ELSIF (RISING_EDGE(clk)) THEN	
			IF(enable = '1') THEN
				data <= dataIn;
			END IF;
		END IF;
	END PROCESS;
	
END ARCHITECTURE my_arch;