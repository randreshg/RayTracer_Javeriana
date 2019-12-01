LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;

ENTITY getVector IS
	GENERIC (bits					: INTEGER :=8);
	PORT	  ( clk,rst				: IN  STD_LOGIC;			 		
				 enable				: IN  STD_LOGIC;								
				 dataIn				: IN  FLOAT;
				 dataOut				: OUT VECTOR;
				 done					: OUT STD_LOGIC);		
END ENTITY getVector;

ARCHITECTURE my_arch OF getVector IS
	SIGNAL dataRegister:	VECTOR;
	SIGNAL count : INTEGER RANGE 0 TO 4;

BEGIN
	PROCESS(clk,rst)
	BEGIN
		IF (rst = '1') THEN
			count <= 0;
		ELSIF (RISING_EDGE(clk)) THEN
			IF(enable = '1') THEN
				dataRegister(count) <= dataIn;
				count <= count + 1;
			END IF;
		END IF;
	END PROCESS;
	
	--Output
	done <= '1' WHEN count = 3 ELSE '0';
	dataOut <= dataRegister;
END ARCHITECTURE my_arch;