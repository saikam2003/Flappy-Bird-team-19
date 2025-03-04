LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY BIRD IS 

	PORT(clk, enable, reset, vert_sync, mouse_clicked, colour_input: IN STD_LOGIC;
			pixel_row, pixel_column: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			red, green, blue : OUT STD_LOGIC_VECTOR(3 downto 0);
			bird_on: OUT STD_LOGIC;
			bird_y_position: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));

END ENTITY BIRD;

ARCHITECTURE behaviour OF BIRD IS
	
	SIGNAL ball_on: STD_LOGIC;
	SIGNAL size: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL ball_x_pos: STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL ball_y_pos: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL ball_y_motion: STD_LOGIC_VECTOR(9 DOWNTO 0);
	
	SIGNAL t_bird_alpha	: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL t_bird_red	: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL t_bird_green : STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL t_bird_blue	: STD_LOGIC_VECTOR(3 downto 0);
	
	
	-- importing the sprite rom for the bird
	COMPONENT bird_rom IS
		PORT(
			font_row, font_col	:	IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			clock, mouse_input	: 	IN STD_LOGIC ;
			bird_data_alpha		:	OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			bird_data_red		:	OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			bird_data_green		:	OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			bird_data_blue		:	OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
			);
	END COMPONENT;
			

BEGIN

	bird_sprite_up: bird_rom PORT MAP(
		font_row => pixel_row(3 downto 0) - (ball_y_pos(3 downto 0) + size(3 downto 0)) ,
		font_col => pixel_column(3 downto 0),
		clock => clk,
		mouse_input => mouse_clicked,
		bird_data_alpha	=>	t_bird_alpha,
		bird_data_red	=>	red,
		bird_data_green	=>	green,
		bird_data_blue	=>	blue
	);
	
	

	-- Setting the size of the bird and converting it into a 10 bit std_logic_vector
	size <= CONV_STD_LOGIC_VECTOR(7, 10);
	
	-- Setting the x position of the ball and converting it into a 10 bit std_logic_vector
	ball_x_pos <= CONV_STD_LOGIC_VECTOR(313, 11);
	
	-- Logic to determine if we are inside the ball (haven't reached the end of the ball according to the size)
	-- to decide whether or not we want to display the ball
	bird_on <= '1' WHEN ( ('0' & ball_x_pos <= '0' & pixel_column + size) AND ('0' & pixel_column <= '0' & ball_x_pos + size + CONV_STD_LOGIC_VECTOR(1,10)) 	-- x_pos - size <= pixel_column <= x_pos + size
					AND ('0' & ball_y_pos <= pixel_row + size + CONV_STD_LOGIC_VECTOR(1,10)) AND ('0' & pixel_row <= ball_y_pos + size) AND (t_bird_alpha = "0001") )  ELSE	-- y_pos - size <= pixel_row <= y_pos + size
			'0';
	
	-- This process handles the vertical movement of the bird 
	Move_Bird: PROCESS (vert_sync)
	VARIABLE mouse_prev, jumping: STD_LOGIC;
	VARIABLE counter: INTEGER RANGE 0 to 15:= 0;
	BEGIN
	
	--Logic for the bird to move uop and down with gravity logic
		IF (RISING_EDGE(vert_sync)) THEN
			IF(enable = '1') THEN
				--if the mouse was not clicked previously but is now clicked, and the bird is not currently jumping
				IF(mouse_prev = '0' and mouse_clicked = '1' and jumping = '0') THEN
					jumping := '1'; -- the brd will now jump
				END IF;
				--now, the previous state of the mouse is updated to the current mouse state
				mouse_prev := mouse_clicked;
				
				--Now, if the bird is jumping
				IF (jumping = '1') THEN
					-- if the counter is equal to 15 (then the bird has jumped 15 times upwards by 5 pixel distance and now should not be jumping)
					IF (counter = 15) THEN
						jumping := '0'; --bird is not jumping
						counter := 0; -- reset the counter
					ELSE
						-- otherwise keep making the bird jump by 4 pixels for 15 times
						ball_y_pos<= ball_y_pos - CONV_STD_LOGIC_VECTOR(4, 10);
						counter:= counter + 1;
					END IF;
				ELSE
					IF (ball_y_pos >= (CONV_STD_LOGIC_VECTOR(479, 10) - size)) THEN
						--if the ball reaches less than or equal to the bottom of the screen set motion to 0
						ball_y_motion <= CONV_STD_LOGIC_VECTOR(0, 10);
					ELSE
						--otherwise keep increasing the motion eeent by 2 pixels
						ball_y_motion <= CONV_STD_LOGIC_VECTOR(2, 10);
					END IF;
					-- Compute next bird Y position
					ball_y_pos <= ball_y_pos + ball_y_motion;
				END IF;
			END IF;
			IF(reset = '1') THEN
				ball_y_pos <= CONV_STD_LOGIC_VECTOR(240, 10);
			ELSIF(ball_y_pos < CONV_STD_LOGIC_VECTOR(0, 10)) THEN
				ball_y_pos <= size;
			END IF;
			bird_y_position <= ball_y_pos;
		END IF;
	END PROCESS Move_Bird;
	
END behaviour;
