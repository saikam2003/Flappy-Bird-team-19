
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;



	PORT(background_on, clk_input, jump_input, start_input, reset_input, text_on, colour_pipe: IN STD_LOGIC;
		horizontal_sync, vertical_sync: IN STD_LOGIC;
		pixel_row_input, pixel_column_input: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		red_output, green_output, blue_output: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		led1, led2: OUT STD_LOGIC);

END ENTITY MAIN;


ARCHITECTURE behvaiour OF MAIN IS
	
	SIGNAL t_collision_reset, t_collision_reset_2: STD_LOGIC:= '0';
	SIGNAL bird_red, bird_green, bird_blue: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL t_bird_position: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL text_red, text_blue, text_green: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL pipe_red, pipe_green, pipe_blue,pipe_red_2, pipe_green_2, pipe_blue_2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL t_pipe_reset, t_pipe_on, t_pipe_halfway, t_collision_chance, t_collision_detected, t_bird_on, t_random_flag, t_random_enable: STD_LOGIC;
	SIGNAL t_pipe_reset_2, t_pipe_on_2, t_pipe_halfway_2, t_collision_chance_2, t_collision_detected_2, t_text_on, t_background_on, t_random_flag_2, t_random_enable_2: STD_LOGIC;
	SIGNAL t_pipe_position, t_pipe_position_2: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL t_pipe_x, t_pipe_x_2: STD_LOGIC_VECTOR(10 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(679, 11);
	SIGNAL t_pipe_y, t_pipe_y_2: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL t_pipe_enable_2: STD_LOGIC:= '0';
	SIGNAL t_pipe_enable: STD_LOGIC:= '0';
	SIGNAL background_red, background_green, background_blue: STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	COMPONENT BIRD IS
		PORT(clk, vert_sync, mouse_clicked, colour_input: IN STD_LOGIC;
			pixel_row, pixel_column: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			red, green, blue : OUT STD_LOGIC_VECTOR(3 downto 0);
			bird_on: OUT STD_LOGIC;
			bird_y_position: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT PIPE IS
		PORT(pipe_reset, enable, vert_sync, colour_input: IN STD_LOGIC;
			pipe_x: IN STD_LOGIC_VECTOR(10 DOWNTO 0);
			pipe_y: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			random_flag: IN STD_LOGIC;
			pixel_row, pixel_column: IN STD_LOGIC_VECTOR(9 downto 0);
			red, green, blue : OUT STD_LOGIC_VECTOR(3 downto 0);
			pipe_on, random_enable: OUT STD_LOGIC;
			pipe_halfway, collision_chance: OUT STD_LOGIC;
			pipe_position: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT BACKGROUND IS
		PORT
		( clk, vert_sync, horz_sync	: IN std_logic;
		  pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue : OUT STD_LOGIC_VECTOR(3 downto 0);
		  background_on 			: OUT std_logic);		
	END COMPONENT;
	
	COMPONENT COLLISION IS
		PORT(reset, clk, pipe_on, pipe_collision_chance: IN STD_LOGIC;
			pipe_y_position, bird_y_position: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			collision_detected: OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT TEXT_DISPLAY IS
		PORT(Clk, enable: IN STD_LOGIC;
			pixel_row, pixel_column: IN STD_LOGIC_VECTOR(9 downto 0);
			red, blue, green : OUT STD_LOGIC_VECTOR(3 downto 0);
			text_on: OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT LFSR IS
		PORT(clk, enable: IN STD_LOGIC;
			rnd: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			flag: OUT STD_LOGIC);
	END COMPONENT;
BEGIN 
	
	bird_component: BIRD
						PORT MAP(
							clk => clk_input,
							vert_sync => vertical_sync,
							mouse_clicked => jump_input,
							colour_input => '0',
							pixel_row => pixel_row_input,
							pixel_column => pixel_column_input,
							red => bird_red,
							green => bird_green,
							blue => bird_blue,
							bird_on => t_bird_on,
							bird_y_position => t_bird_position
						);
	
	pipe_component: PIPE
						PORT MAP(
							pipe_reset => t_pipe_reset,
							enable => t_pipe_enable,
							vert_sync => vertical_sync,
							colour_input => colour_pipe,
							pipe_x => t_pipe_x,
							pipe_y => t_pipe_y,
							random_flag => t_random_flag,
							pixel_row => pixel_row_input,
							pixel_column => pixel_column_input,
							red => pipe_red,
							green => pipe_green,
							blue => pipe_blue,
							pipe_on => t_pipe_on,
							random_enable => t_random_enable,
							pipe_halfway => t_pipe_halfway,
							collision_chance => t_collision_chance,
							pipe_position => t_pipe_position
						);
						
	collision_detection_pipe: COLLISION 
						PORT MAP(
							reset => t_collision_reset,
							clk => clk_input,
							pipe_on => t_pipe_on,
							pipe_collision_chance => t_collision_chance,
							pipe_y_position => t_pipe_position,
							bird_y_position => t_bird_position,
							collision_detected => t_collision_detected
						);
	collision_detection_pipe_2: COLLISION 
						PORT MAP(
							reset => t_collision_reset_2,
							clk => clk_input,
							pipe_on => t_pipe_on_2,
							pipe_collision_chance => t_collision_chance_2,
							pipe_y_position => t_pipe_position_2,
							bird_y_position => t_bird_position,
							collision_detected => t_collision_detected_2
						);
	pipe_component_2: PIPE
						PORT MAP(
							pipe_reset => t_pipe_reset_2,
							enable => t_pipe_enable_2,
							vert_sync => vertical_sync,
							colour_input => colour_pipe,
							pipe_x => t_pipe_x_2,
							pipe_y => t_pipe_y_2,
							random_flag => t_random_flag_2,
							pixel_row => pixel_row_input,
							pixel_column => pixel_column_input,
							red => pipe_red_2,
							green => pipe_green_2,
							blue => pipe_blue_2,
							pipe_on => t_pipe_on_2,
							random_enable => t_random_enable_2,
							pipe_halfway => t_pipe_halfway_2,
							collision_chance => t_collision_chance_2,
							pipe_position => t_pipe_position_2
						);
	
	background_component: BACKGROUND
								PORT MAP(
									clk => clk_input,
									vert_sync => vertical_sync,
									horz_sync => horizontal_sync,
									pixel_row => pixel_row_input,
									pixel_column => pixel_column_input,
									red => background_red,
									green => background_green,
									blue => background_blue,
									background_on => t_background_on
								);
								
	text_component: TEXT_DISPLAY
						PORT MAP(Clk => clk_input,
							enable => '1',
							pixel_row => pixel_row_input, 
							pixel_column => pixel_column_input,
							red => text_red, 
							blue => text_blue, 
							green => text_green, 
							text_on => t_text_on);
	
	prng: LFSR
			PORT MAP(
				clk => clk_input,
				enable => t_random_enable,
				rnd => t_pipe_y,
				flag => t_random_flag
			);
			
	prng_2: LFSR
			PORT MAP(
				clk => clk_input,
				enable => t_random_enable_2,
				rnd => t_pipe_y_2,
				flag => t_random_flag_2
			);

	screen_display: PROCESS(clk_input)
	BEGIN
		IF (RISING_EDGE(clk_input)) THEN

			IF (t_text_on = '1' and text_on = '1') THEN
				red_output <= text_red;
				green_output <= text_green;
				blue_output <= text_blue;
			ELSIF (t_bird_on = '1') THEN
				red_output <= bird_red;
				green_output <= bird_green;
				blue_output <= bird_blue;
			ELSIF (t_pipe_on = '1') THEN
				red_output <= pipe_red;
				green_output <= pipe_green;
				blue_output <= pipe_blue;
			ELSIF (t_pipe_on_2 = '1') THEN
				red_output <= pipe_red_2;
				green_output <= pipe_green_2;
				blue_output <= pipe_blue_2;
			ELSIF (t_background_on = '1') THEN
				red_output <= background_red;
				green_output <= background_green;
				blue_output <= background_blue;
			ELSE
				red_output <= "0000";
				green_output <= "1010";
				blue_output <= "1011";
			END IF;
		END IF;
	END PROCESS screen_display;

	pipe_logic: PROCESS(clk_input)
	BEGIN
		IF (RISING_EDGE(clk_input)) THEN
			IF ((t_collision_detected = '1' OR t_collision_detected_2 = '1')) then
				t_pipe_enable <= '0';
				t_pipe_enable_2 <= '0';
			ELSE
				t_collision_reset <= '0';
				t_collision_reset_2 <= '0';
				t_pipe_reset <= '0';
				t_pipe_reset_2 <= '0';
			END IF;
			
			IF((t_pipe_enable = '0') AND start_input = '0') THEN
				t_pipe_reset <= '1';
				t_pipe_reset_2 <= '1';
				t_collision_reset <= '1';
				t_collision_reset_2 <= '1';
				t_pipe_enable <= '1';
			END IF;	
			
			IF (t_pipe_halfway = '1' and t_collision_detected = '0' and t_collision_detected_2 = '0') THEN
					t_pipe_enable_2 <= '1';
			END IF;
		END IF;
	END PROCESS pipe_logic;

END ARCHITECTURE;
	
	