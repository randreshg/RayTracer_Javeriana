-- COUNTER
---------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE WORK.my_package.ALL;
---------------------------------------------------------------------------
ENTITY counterTick IS
	GENERIC ( N			 	 : INTEGER );
	PORT	  ( clock		 : IN 	STD_LOGIC;
				 rst		 	 : IN 	STD_LOGIC;
				 ena		 	 : IN		STD_LOGIC;
				 max_tick 	 : OUT	STD_LOGIC);
END ENTITY;
---------------------------------------------------------------------------
ARCHITECTURE rtl OF counterTick IS
	SIGNAL count_s	:	INTEGER RANGE 0 TO (N-1) := 0;
	SIGNAL output  :  STD_LOGIC;
BEGIN
	PROCESS (clock, rst,ena)
	BEGIN
		IF (rst = '1') THEN
			count_s  <= 0;
		ELSIF (RISING_EDGE(clock)) THEN
			IF(ena = '1')	THEN
			   -- Increases counter
			   IF(output = '1') THEN
			      count_s <= 0;
			   ELSE
				   count_s <= count_s + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	-- Output
	output 	<= '1' WHEN (count_s = N-1) ELSE '0';
	max_tick	<= output;
	
END ARCHITECTURE;