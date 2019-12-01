-- CONVERSION FROM INTEGER TO FLOAT
---------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
---------------------------------------------------------------------------
ENTITY conversion IS
	GENERIC ( N			 	 : INTEGER );
	PORT	  ( clock		 : IN 	STD_LOGIC;
				 number   	 : IN 	INTEGER RANGE 0 TO (N-1);
				 result    	 : OUT	FLOAT);
END ENTITY;
---------------------------------------------------------------------------
ARCHITECTURE rtl OF conversion IS
	SIGNAL aux		:	STD_LOGIC_VECTOR(31 DOWNTO 0) ;
	
BEGIN	
	aux <= STD_LOGIC_VECTOR(TO_UNSIGNED(number, aux'LENGTH));
	conv: ENTITY WORK.convert PORT MAP(clock,aux,result);
	
END ARCHITECTURE;