-- BCD TO SEVEN SEGMENT CODE CONVERTER
-- *It is assumed that the 7-segment module is active low and it can 
-- reproduce hexadecimal digits.
---------------------------------------------------------------------------
LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
---------------------------------------------------------------------------
ENTITY Integer_to_sseg IS
	PORT( bin		: IN 	INTEGER;
			sseg	   : OUT	STD_LOGIC_VECTOR(6 DOWNTO 0));
END ENTITY;
---------------------------------------------------------------------------
ARCHITECTURE rtl OF Integer_to_sseg IS
BEGIN
   WITH bin SELECT
      sseg<=  	"1000000" WHEN 0,
					"1111001" WHEN 1,
					"0100100" WHEN 2,
					"0110000" WHEN 3,
					"0011001" WHEN 4,
					"0010010" WHEN 5,
					"0000010" WHEN 6,
					"1111000" WHEN 7,
					"0000000" WHEN 8,
					"0010000" WHEN 9,
					"0001110" WHEN OTHERS;
END ARCHITECTURE;
			
