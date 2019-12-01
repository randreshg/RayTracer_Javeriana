LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;

ENTITY getFloat IS
	GENERIC (bits					: INTEGER :=8);
	PORT	  ( clk,rst				: IN  STD_LOGIC;			 		
				 enable				: IN  STD_LOGIC;								
				 dataIn				: IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
				 dataOut				: OUT FLOAT;
				 done					: OUT STD_LOGIC);		
END ENTITY getFloat;

ARCHITECTURE my_arch OF getFloat IS
	TYPE dataArray IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(7 DOWNTO 0); 
	SIGNAL dataRegister:	dataArray;
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
	done <= '1' WHEN count = 4 ELSE '0';
	dataOut(7  DOWNTO 0)  <= dataRegister(0);
	dataOut(15 DOWNTO 8)  <= dataRegister(1);
	dataOut(23 DOWNTO 16) <= dataRegister(2);
	dataOut(31 DOWNTO 24) <= dataRegister(3);
END ARCHITECTURE my_arch;