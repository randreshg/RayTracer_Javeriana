---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------
ENTITY lightSource IS
	GENERIC( N						: INTEGER :=2);
	PORT	 (	clock   				: IN  STD_LOGIC;
				rst					: IN  STD_LOGIC;
				id						: IN  INTEGER RANGE 0 TO (N-1);
				Ambiente				: OUT VECTOR;
				light					: OUT VECTOR);
				
END lightSource;

ARCHITECTURE lightSource_arch OF lightSource IS
	TYPE 	 data 	 IS ARRAY (0 TO N-1) OF VECTOR;
	SIGNAL lightList			: data;

BEGIN
	light <= lightList(id);
	--Ambiente [0.5,0.5,0.5]
	Ambiente <= (X"3F000000",X"3F000000",X"3F000000");
	----------------------LightSource memory---------------------------
	lightList(0) <= (X"40800000",X"40400000",X"40000000"); --[4,3,2]
	lightList(1) <= (X"3F800000",X"C0800000",X"40800000"); --[1,-4,4]
	lightList(2) <= (X"C0400000",X"3F800000",X"40A00000"); --[-3,1,5]
	lightList(3) <= (X"C0000000",X"40A00000",X"40600000"); --[-2,5,3.5]
	lightList(4) <= (X"BFCCCCCD",X"40800000",X"40400000"); --[-1.6,4,3]
	lightList(5) <= (X"400CCCCD",X"C06CCCCD",X"41000000"); --[2.2,-3.7,8]
	lightList(2) <= (X"C0400000",X"3F800000",X"40600000"); --[-3,1,5]
END lightSource_arch;

