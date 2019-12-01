LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE WORK.my_package.ALL;
----------------------------------

ENTITY primitiveMemory IS
	GENERIC( N	 : INTEGER :=15);
	PORT 	 (	clk		  		 : IN  STD_LOGIC;
				data_in  		 : IN  PRIMITIVE;
				data_type  		 : IN  STD_LOGIC;
				--Reading variables
				idTI_rd			 : IN  INTEGER RANGE 0 TO (N-1);
				idSH_rd			 : IN  INTEGER RANGE 0 TO (N-1);
				--Writing variables
				id_wr  	 	 	 : IN  INTEGER RANGE 0 TO (N-1);
				wr 	   		 : IN  STD_LOGIC;
				data_outTI 		 : OUT PRIMITIVE;
				type_outTI 		 : OUT STD_LOGIC;
				data_outSH		 : OUT PRIMITIVE;
				type_outSH 		 : OUT STD_LOGIC);
END primitiveMemory;

ARCHITECTURE behavioral OF primitiveMemory IS
	--Signals
	TYPE 	 data 	 IS ARRAY (0 TO N-1) OF STD_LOGIC;
	TYPE 	 data1	 IS ARRAY (0 TO N-1) OF PRIMITIVE;	
	SIGNAL primitiveData : data1;
	SIGNAL primitiveType : data;

BEGIN
	memory: PROCESS(clk)
	BEGIN
		IF(RISING_EDGE(clk)) THEN
			IF(wr = '1') THEN
				primitiveData(id_wr) <= data_in;
				primitiveType(id_wr) <= data_type;
			END IF;	
--		--PRIMITIVE MEMORY
--		--Cilindro[[0,0,0],0.5,[0,0,1],1]	
--		primitiveData(0) <= (X"00000000",X"00000000",X"00000000",X"3f000000",X"00000000",X"00000000",X"3f800000",X"3f800000");
--		primitiveType(0) <= '1';
--		--Esfera[[0,0.5,0],0.5,[0,0,0],0]
--		primitiveData(1) <= (X"00000000",X"3f000000",X"00000000",X"3f000000",X"00000000",X"00000000",X"00000000",X"00000000");
--		primitiveType(1) <= '0';
--		--Esfera[[0,0,1],0.5,[0,0,0],0]
--		primitiveData(2) <= (X"00000000",X"00000000",X"3f800000",X"3f000000",X"00000000",X"00000000",X"00000000",X"00000000");
--		primitiveType(2) <= '0';
--		--Esfera[[0,-0.5,0],0.5,[0,0,0],0]
--		primitiveData(3) <= (X"00000000",X"bf000000",X"00000000",X"3f000000",X"00000000",X"00000000",X"00000000",X"00000000");
--		primitiveType(3) <= '0';	
		END IF;
	END PROCESS;
	--Object for test intersection
	data_outTI <= primitiveData(idTI_rd);
	type_outTI <= primitiveType(idTI_rd);
	--Object for shading
	data_outSH <= primitiveData(idSH_rd);
	type_outSH <= primitiveType(idSH_rd);
	
	
end behavioral;