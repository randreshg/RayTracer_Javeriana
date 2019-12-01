---------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.my_package.ALL;
----------------------------------------------------------

ENTITY blockEnable IS
	GENERIC( SIDelay				: INTEGER := 6;
				RGDelay				: INTEGER := 5;
				TIDelay				: INTEGER := 10);
	PORT	 (	clock					: IN  STD_LOGIC;	
				rst					: IN  STD_LOGIC;	
				rtEnable				: IN  STD_LOGIC;	
				rayGen				: OUT STD_LOGIC;				
				rayInt				: OUT STD_LOGIC;
				minDst				: OUT STD_LOGIC);
END blockEnable;

ARCHITECTURE blockEnable_arch OF blockEnable IS
	--rayInt
   TYPE data0 IS ARRAY (SIDelay DOWNTO 0) OF STD_LOGIC;
	SIGNAL rayGenEnable 		: data0;
	--rayIntrayIntEnable
   TYPE data1 IS ARRAY (RGDelay DOWNTO 0) OF STD_LOGIC;
	SIGNAL rayIntEnable 		: data1;
	--minDst
   TYPE data2 IS ARRAY (TIDelay DOWNTO 0) OF STD_LOGIC;
	SIGNAL minDstEnable 		: data2;
--	--Shade
--   TYPE data2 IS ARRAY (RIDelay DOWNTO 0) OF STD_LOGIC;
--	SIGNAL shadeEnable 		: data2;
BEGIN
	----------------------------------------------------BLOCK ENABLE------------------------------------------------------------------------
	--rayGenEnable delay
	rayGenEnable(0) <= rtEnable;
	delays: FOR i IN 1 TO SIDelay 
		GENERATE		
			dly0 : ENTITY WORK.bitRegister 	PORT MAP(clock,rst,'1',rayGenEnable(i-1),rayGenEnable(i));
		END GENERATE;
		
	--rayIntEnable delay
	rayIntEnable(0) <= rayGenEnable(SIDelay-1);
	delays1: FOR i IN 1 TO RGDelay 
		GENERATE		
			dly1 : ENTITY WORK.bitRegister 	PORT MAP(clock,rst,'1',rayIntEnable(i-1),rayIntEnable(i));
		END GENERATE;
	--minDstEnable delay
	minDstEnable(0) <= rayIntEnable(RGDelay);
	delays2: FOR i IN 1 TO TIDelay 
		GENERATE		
			dly2 : ENTITY WORK.bitRegister 	PORT MAP(clock,rst,'1',minDstEnable(i-1),minDstEnable(i));
		END GENERATE;
	--Output								
	rayGen  <= rayGenEnable(SIDelay);
	rayInt  <= rayIntEnable(RGDelay);
	minDst  <= minDstEnable(TIDelay-1);
END blockEnable_arch;
