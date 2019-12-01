LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY RAM IS
	GENERIC( colorBits		 : INTEGER := 8;
				xResolution		 : INTEGER := 640;
				yResolution		 : INTEGER := 480);
	PORT 	 (	clk		  		 : IN  STD_LOGIC;
				data_in  		 : IN  STD_LOGIC_VECTOR (colorBits-1 DOWNTO 0);
				--Reading variables
				row_rd_addr  	 : IN  INTEGER RANGE 0 TO (yResolution-1);
				column_rd_addr  : IN  INTEGER RANGE 0 TO (xResolution-1);
				--Writing variables
				row_wr_addr  	 : IN  INTEGER RANGE 0 TO (yResolution-1);
				column_wr_addr  : IN  INTEGER RANGE 0 TO (xResolution-1);
				wr 	   		 : IN  STD_LOGIC;
				data_out 		 : OUT STD_LOGIC_VECTOR(colorBits-1 DOWNTO 0)); 
END RAM;

ARCHITECTURE behavioral OF RAM IS
	--Signals	
	TYPE 	 data 	 IS ARRAY (0 TO xResolution-1) OF STD_LOGIC_VECTOR (colorBits-1 DOWNTO 0);
	TYPE   mem_type IS ARRAY (0 TO yResolution-1) OF data;
	SIGNAL mem : mem_type;

BEGIN
	memory: PROCESS(clk)
	BEGIN
		IF(RISING_EDGE(clk)) THEN
			IF(wr = '1') THEN
				mem(row_wr_addr)(column_wr_addr) <= data_in;			
			END IF;
			data_out <= mem(row_rd_addr)(column_rd_addr); -- read
		END IF;
	END PROCESS;
	
end behavioral;
