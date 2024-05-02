LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY background IS
	PORT
		( clk, vert_sync, horz_sync	: IN std_logic;
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue 			: OUT std_logic);		
END background;

architecture behavior of background is

BEGIN           

-- Colours for pixel data on video signal
-- Changing the background and ball colour by pushbuttons
Red <=  '0';
Green <= '1';
Blue <=  '1';
END behavior;

