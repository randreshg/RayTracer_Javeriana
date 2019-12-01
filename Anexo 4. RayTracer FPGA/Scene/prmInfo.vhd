
---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------
ENTITY prmInfo IS
	GENERIC( N						: INTEGER := 2);
	PORT	 (	clock   				: IN  STD_LOGIC;
				rst					: IN  STD_LOGIC;
				--Primitive iterator
				idTI					: IN  INTEGER RANGE 0 TO (N-1);
				idSH					: IN  INTEGER RANGE 0 TO (N-1);				
				--Primitive output
				primitivesTI		: OUT PRIMITIVE;
				primitivesSH		: OUT PRIMITIVE;
				primitiveTypeTI	: OUT STD_LOGIC;
				primitiveTypeSH	: OUT STD_LOGIC);
END prmInfo;

ARCHITECTURE prmInfo_arch OF prmInfo IS
	TYPE 	 data IS ARRAY (0 TO N-1) OF PRIMITIVE;
	SIGNAL primitiveList			: data;
	TYPE 	 data2 IS ARRAY (0 TO N-1) OF STD_LOGIC;
	SIGNAL primitiveTypeList 	: data2;

BEGIN
	primitivesTI	  <= primitiveList(idTI);
	primitivesSH	  <= primitiveList(idSH);
	primitiveTypeTI  <= primitiveTypeList(idTI);
	primitiveTypeSH  <= primitiveTypeList(idSH);
 	--PRIMITIVE MEMORY
	--Cilindro[[0,0,0],0.5,[0,0,1],1]	
	primitiveList(0) <= (X"00000000",X"00000000",X"00000000",X"3f000000",X"00000000",X"00000000",X"3f800000",X"3f800000");
	primitiveTypeList(0) <= '1';
	--Esfera[[0,0.5,0],0.5,[0,0,0],0]
	primitiveList(1) <= (X"00000000",X"3f000000",X"00000000",X"3f000000",X"00000000",X"00000000",X"00000000",X"00000000");
	primitiveTypeList(1) <= '0';
	--Esfera[[0,0,1],0.5,[0,0,0],0]
	primitiveList(2) <= (X"00000000",X"00000000",X"3f800000",X"3f000000",X"00000000",X"00000000",X"00000000",X"00000000");
	primitiveTypeList(2) <= '0';
	--Esfera[[0,-0.5,0],0.5,[0,0,0],0]
	primitiveList(3) <= (X"00000000",X"bf000000",X"00000000",X"3f000000",X"00000000",X"00000000",X"00000000",X"00000000");
	primitiveTypeList(3) <= '0';
END prmInfo_arch;

