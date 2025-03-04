LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY COLLISION IS

	PORT(reset, clk, pipe_on_1, pipe_on_2, bird_on, pipe_1_collision_chance, pipe_2_collision_chance, pipe_1_halfway, pipe_2_halfway, power_up_on: IN STD_LOGIC;
			game_over: OUT STD_LOGIC;
			collision_count: OUT INTEGER RANGE 3 downto 0;
			score_count: OUT INTEGER RANGE 999 downto 0);
			
END ENTITY COLLISION;


ARCHITECTURE behaviour OF COLLISION IS
	CONSTANT gap_size_x: STD_LOGIC_VECTOR(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(20, 10);
	CONSTANT gap_size_y: STD_LOGIC_VECTOR(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(56, 10);
	CONSTANT bird_x_position: STD_LOGIC_VECTOR(10 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(313, 11);
	CONSTANT bird_size: STD_LOGIC_VECTOR(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(7, 10);
	SIGNAL collision_detected, t_collision_flag, pipe_tracker, score_pipe_tracker, power_up_flag, power_up_pipe_tracker: STD_LOGIC := '0';
	SIGNAL t_collision_count: INTEGER RANGE 3 downto 0 := 0;
	SIGNAL curr_score: INTEGER RANGE 999 downto 0 := 0;
	SIGNAL increment_life: STD_LOGIC;
	
BEGIN

	score_count <= curr_score;
	collision_count <= t_collision_count;
	
--	PROCESS (power_up_flag)
--		variable prev_flag: STD_LOGIC:= '0';
--	BEGIN
--		IF (prev_flag = '0' and power_up_flag = '1') THEN
--			increment_life <= '1';
--			prev_flag := '1';
--		ELSE
--			increment_life <= '0';
--			prev_flag := '0';
--		END IF;
--	END PROCESS;
	
	
	PROCESS(clk,reset)
	BEGIN
		IF (reset = '1') THEN
			game_over <= '0';
			t_collision_count <= 0;
			t_collision_flag <= '0';
			score_pipe_tracker <= '0';
			curr_score <= 0;
--		ELSIF (increment_score = '1' AND t_collision_count /= 0) THEN
--			t_collision_count <= t_collision_count - 1;
		ELSIF RISING_EDGE(clk) THEN
			-- collision tracker
			IF(t_collision_flag = '0' and bird_on = '1' and (pipe_on_1 = '1' or pipe_on_2 = '1'))THEN
				t_collision_count <= t_collision_count + 1;
				IF(t_collision_count = 2) THEN
					game_over <= '1';
				END IF;
				
				t_collision_flag <= '1';
				if(pipe_on_1 = '1') THEN
					pipe_tracker <= '0';
				else
					pipe_tracker <= '1';
				end if;
			ELSIF(t_collision_flag = '1')THEN
				if(pipe_tracker = '1' and pipe_1_collision_chance = '1')then
					t_collision_flag <= '0';
				elsif(pipe_tracker = '0' and pipe_2_collision_chance = '1') then 
					t_collision_flag <= '0';
				end if;
			END IF;
			-- power up tracker
			IF (power_up_flag = '0' and power_up_on = '1' and bird_on = '1') THEN
--				increment_life <= '1';
				power_up_flag <= '1';
				
				if(pipe_1_halfway = '1') then
					power_up_pipe_tracker <= '0';
				else
					power_up_pipe_tracker <= '1';
				end if;
				
				if(t_collision_count > 0) then
					t_collision_count <= t_collision_count - 1;
				end if;
			ELSIF(power_up_flag = '1' and ((pipe_1_halfway = '1' and power_up_pipe_tracker = '1')or (pipe_2_halfway = '1' and power_up_pipe_tracker = '0'))) THEN
				power_up_flag <= '0';
			END IF;
			-- score tracker
			IF(score_pipe_tracker = '0' and pipe_1_halfway = '1') THEN
				score_pipe_tracker <= '1';
				curr_score <= curr_score + 1;
			ELSIF(score_pipe_tracker = '1' and pipe_2_halfway = '1') THEN
				score_pipe_tracker <= '0';
				curr_score <= curr_score + 1;
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE behaviour;