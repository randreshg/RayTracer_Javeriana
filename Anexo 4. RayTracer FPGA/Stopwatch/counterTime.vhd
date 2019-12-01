-- FREE RUN CONVERTER
---------------------------------------------------------------------------
LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
---------------------------------------------------------------------------
ENTITY counterTime IS
	GENERIC ( N			: INTEGER := 10);
	PORT	( clk		: IN   STD_LOGIC;
			  rst		: IN   STD_LOGIC;
			  ena		: IN   STD_LOGIC;
			  max_tick 	: OUT  STD_LOGIC;
			  count    	: OUT  INTEGER RANGE 0 TO (N-1));
END ENTITY;
---------------------------------------------------------------------------
ARCHITECTURE rtl OF counterTime IS
	SIGNAL count_s	: INTEGER RANGE 0 TO N-1 ;
	SIGNAL output  	: STD_LOGIC := '0';
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF (rst = '1') THEN
			count_s <= 0;
		ELSIF (RISING_EDGE(clk)) THEN
			IF(ena='1')	THEN
			   -- Increases counter
			   IF(count_s = N-1) THEN
			      count_s <= 0;
			      -- Output
			       output <= '1';
			   ELSE
			      output <= '0';
				   count_s <= count_s + 1;
				END IF;
			ELSE
				output <= '0';
			END IF;
		END IF;		
	END PROCESS;
	-- Output
	max_tick <= output;
	count<= count_s;
END ARCHITECTURE;
