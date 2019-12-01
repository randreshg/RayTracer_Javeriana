-- VGA CONTROLLER
-- Tomado y modificado de: 
-- VGA Controller (VHDL) https://www.digikey.com/eewiki/pages/viewpage.action?pageId=15925278
---------------------------------------------------------------------------
LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
---------------------------------------------------------------------------

ENTITY VGAController IS
	GENERIC(	H_syncPulse 	:	INTEGER := 96; 
				H_BackPorch	 	:	INTEGER := 48;	
				H_ActiveVideo	:	INTEGER := 640;
				H_FrontPorch	:	INTEGER := 16;	
				V_syncPulse 	:	INTEGER := 2;	
				V_BackPorch	 	:	INTEGER := 33;	
				V_ActiveVideo	:	INTEGER := 480;	
				V_FrontPorch	:	INTEGER := 10);		
	PORT(		clk				:	IN	 STD_LOGIC;
				rst				:	IN	 STD_LOGIC;	
				H_sync			:	OUT STD_LOGIC;
				V_sync			:	OUT STD_LOGIC;
				videoOn			:	OUT STD_LOGIC;		
				row				:	OUT INTEGER RANGE 0 TO V_ActiveVideo;
				column			:	OUT INTEGER RANGE 0 TO H_ActiveVideo;
				Blank 			: 	OUT STD_LOGIC;
				Sync				: 	OUT STD_LOGIC);	
END VGAController;		

ARCHITECTURE behavior OF VGAController IS
	--Horizontal 
	CONSTANT H_period	:	INTEGER := H_syncPulse + H_BackPorch + H_ActiveVideo + H_FrontPorch - 1;  
	--Vertical 
	CONSTANT V_period	:	INTEGER := V_syncPulse + V_BackPorch + V_ActiveVideo + V_FrontPorch - 1; 
	
BEGIN
	--Output
	Blank  <= '1';
	Sync	 <= '0';
	--VGA Controller
	PROCESS(clk, rst)			
	   --Horizontal counter (counts the columns)
		VARIABLE H_count	:	INTEGER RANGE 0 TO H_period := 0;  
		--Vertical counter (counts the rows)
		VARIABLE V_count	:	INTEGER RANGE 0 TO V_period := 0;  
	BEGIN
	
		IF(rst = '1') THEN		
			H_count 	:=  0;				
			V_count 	:=  0;				
			H_sync 	<= '1';			
			V_sync 	<= '0';			
			videoOn  <= '0';			
			column 	<=  0;				
			row 		<=  0;				
			
		ELSIF(RISING_EDGE(clk)) THEN
			-- Vertical and horizontal counters
			IF(H_count < H_period) THEN		
				H_count := H_count + 1;
			ELSE
				H_count := 0;
				IF(V_count < V_period) THEN	
					V_count := V_count + 1;
				ELSE
					V_count := 0;
				END IF;
			END IF;

			--Horizontal sync signal
			IF((H_count < H_ActiveVideo + H_FrontPorch) OR (H_count >= H_ActiveVideo + H_FrontPorch + H_syncPulse)) THEN
				H_sync <= '1';		
			ELSE
				H_sync <= '0';			
			END IF;
			
			--Vertical sync signal
			IF((V_count < V_ActiveVideo + V_FrontPorch) OR (V_count >= V_ActiveVideo + V_FrontPorch + V_syncPulse)) THEN
				V_sync <= '0';		
			ELSE
				V_sync <= '1';			
			END IF;
			
			
			--Set pixel coordinates
			IF(H_count  < H_ActiveVideo) THEN 
				column <= H_count;										
			END IF;
			IF(V_count  < V_ActiveVideo) THEN 
				row <= V_count;											
			END IF;

			--Set video on output
			IF((H_count  < H_ActiveVideo) AND (V_count  < V_ActiveVideo))  THEN 
				videoOn <= '1';											 		
			ELSE																			
				videoOn <= '0';														
			END IF;

		END IF;
	END PROCESS;

END behavior;
