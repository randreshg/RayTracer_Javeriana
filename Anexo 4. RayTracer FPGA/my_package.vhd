--------------------------- Package: my_package.vhd-----------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
--------------------------------------------------------------------------
PACKAGE my_package IS
	--Auxiliar data types
	--TYPE FLOAT IS STD_LOGIC_VECTOR(31 DOWNTO 0);
	SUBTYPE FLOAT IS STD_LOGIC_VECTOR (31 DOWNTO 0);
	TYPE VECTOR IS ARRAY (0 TO 2) OF FLOAT;
	TYPE PRIMITIVE IS ARRAY (0 TO 7) OF FLOAT;
	CONSTANT ones : PRIMITIVE:= (OTHERS=>(OTHERS=>'1'));
	TYPE OBSERVER IS ARRAY (0 TO 3) OF VECTOR;
	CONSTANT inf 		  : FLOAT := "01111111100000000000000000000000";	--Guarda el numero INFINITO
	CONSTANT zeros		  : FLOAT := (OTHERS=>'0');								--Guarda el numero 0
	CONSTANT zero		  : VECTOR:= (OTHERS=>zeros);							   --Vector de 0
	CONSTANT background : STD_LOGIC_VECTOR(7 DOWNTO 0):= "11111111";
	---------------------------------------------------------------------------------------------
   FUNCTION int (vector: STD_LOGIC_VECTOR) RETURN INTEGER;
	FUNCTION "+" (a,b: STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR;
	--FUNCTION "*" (a,b: STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR;
	FUNCTION positive_edge(SIGNAL a: STD_LOGIC) RETURN BOOLEAN;
	-- Others functions
END PACKAGE my_package;

PACKAGE BODY my_package IS

	-- Return true when a has rising edge
	FUNCTION positive_edge(SIGNAL a: STD_LOGIC) RETURN BOOLEAN IS
	BEGIN
		RETURN (a'EVENT AND a= '1');
	END positive_edge;
	
   -- Convert from STD_LOGIC_VECTOR to INTEGER
   FUNCTION int (vector: STD_LOGIC_VECTOR) RETURN INTEGER IS
      VARIABLE result: INTEGER RANGE 0 TO 2**vector'LENGTH -1;
   BEGIN
      IF(vector(vector'HIGH)='1') THEN result:=1;
      ELSE result := 0; END IF;
      FOR i IN (vector'HIGH-1) DOWNTO (vector'LOW) LOOP
         result := result * 2;
         IF(vector(i) = '1') THEN result := result + 1; END IF;
      END LOOP;
      RETURN result;
   END int;
	
-- Multiplies two STD_LOGIC_VECTOR
--   FUNCTION "*" (a,b: STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
--      CONSTANT max : INTEGER := a'LENGTH + b'LENGTH - 1;
--		VARIABLE aa	 : STD_LOGIC_VECTOR (max DOWNTO 0) := (max DOWNTO a'LENGTH => '0') & a ;
--		VARIABLE xx  : STD_LOGIC_VECTOR (max DOWNTO 0) := (OTHERS => '0');
--		BEGIN
--			FOR i IN 0 TO a'LENGTH -1 LOOP
--				IF (b(i) = '1') THEN xx := xx + aa; END IF;
--				aa := aa (max-1 DOWNTO 0) & '0';
--			END LOOP;
--		RETURN xx;
--   END "*";
	
	-- Adss two STD_LOGIC_VECTOR
   FUNCTION "+" (a,b: STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
      VARIABLE result: STD_LOGIC_VECTOR (a'RANGE);
		VARIABLE carry : STD_LOGIC;
   BEGIN
		carry := '0';
      FOR i IN a'REVERSE_RANGE LOOP
         result(i) := a(i) XOR b(i) XOR carry;
			carry := (a(i) AND b(i)) OR (a(i) AND carry) OR (b(i) AND carry);
      END LOOP;
      RETURN result;
   END "+";
END my_package;
         
