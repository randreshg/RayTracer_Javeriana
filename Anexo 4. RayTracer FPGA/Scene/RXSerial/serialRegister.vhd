LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;

ENTITY serialRegister IS
	GENERIC (bits					: INTEGER);
	PORT	  ( clk					: IN  STD_LOGIC;
				 counter 			: IN  INTEGER RANGE 0 TO bits;
				 enable				: IN  STD_LOGIC;								
				 dataIn				: IN  STD_LOGIC;
				 dataOut				: OUT STD_LOGIC_VECTOR(bits-1 DOWNTO 0));		
END ENTITY serialRegister;

ARCHITECTURE my_arch OF serialRegister IS
SIGNAL memory  :  STD_LOGIC_VECTOR(bits-1 DOWNTO 0);
BEGIN
	PROCESS(clk)
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF(enable = '1') THEN
				memory(counter) <= dataIn;
			END IF;
		END IF;
	END PROCESS;
	--Output
	dataOut <= memory;
END ARCHITECTURE my_arch;