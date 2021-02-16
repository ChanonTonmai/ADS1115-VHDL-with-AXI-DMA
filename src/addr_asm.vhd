LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- send told that the signal is finish transmission
-- cmd_done is for finish port

ENTITY addr_asm IS
	PORT (
		clk, reset_n : IN STD_LOGIC;
		start, cmd_done : IN STD_LOGIC;
		addr_out : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		data_wr : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		ena, rw, send : OUT std_logic;
		pga : IN std_logic_vector(2 DOWNTO 0);
		dr : IN std_logic_vector(2 DOWNTO 0);
		data_raw_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		data_rd : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END addr_asm;

ARCHITECTURE Behavioral OF addr_asm IS
	TYPE ads1115_state IS (idle, w1, w2, w3, w4, rd1, rd2, command_wr, command_wr2, command_rd1, command_rd2, hold0, hold, hold2); -- ADS1115 design for 1 channel
	SIGNAL state_reg, state_next : ads1115_state;
	SIGNAL reset, change_state, change_state_d, cmd_done_one_clk : std_logic;
	SIGNAL delay_count : INTEGER;

BEGIN
	reset <= reset_n;

	cmd_done_one_clk <= cmd_done AND (NOT change_state_d);

	PROCESS (clk)
	BEGIN
		IF (clk'EVENT AND clk = '1') THEN
			change_state_d <= cmd_done;
		END IF;
	END PROCESS;
	-- next state logic/ output and data path routing
	PROCESS (clk)
		BEGIN
			IF (clk'EVENT AND clk = '1') THEN
				-- state_next <= state_reg;
				CASE state_next IS
					WHEN idle => 
						delay_count <= 0;
						ena <= '0';
						rw <= '0';
						send <= '0';
						IF reset = '1' THEN -- reset unactive
							IF start = '1' THEN
								state_next <= hold0;
							ELSE
								state_next <= idle;
							END IF;
						ELSE
							state_next <= idle;
						END IF;
 
					WHEN hold0 => 
						ena <= '0';
						IF delay_count < 1000 THEN
							delay_count <= delay_count + 1;
							state_next <= hold0;
						ELSE
							delay_count <= 0;
							state_next <= command_wr;
						END IF;
 
					WHEN command_wr => 
						addr_out <= "1001000";
						data_wr <= x"01";
						rw <= '0';
						ena <= '1';
						send <= '0';
						IF cmd_done_one_clk = '1' THEN
							state_next <= w2;
						ELSE
							state_next <= command_wr;
						END IF;

					WHEN w2 => 
						addr_out <= "1001000";
						data_wr <= x"C" & pga & '1';
						rw <= '0';
						ena <= '1';
						send <= '0';
						IF cmd_done_one_clk = '1' THEN
							state_next <= w3;
						ELSE
							state_next <= w2;
						END IF;

					WHEN w3 => 
						addr_out <= "1001000";
						data_wr <= dr & '0' & x"3";
						rw <= '0';
						send <= '0';

						IF cmd_done_one_clk = '1' THEN
							state_next <= hold;
						ELSE
							state_next <= w3;
						END IF;
 
					WHEN hold => 
						ena <= '0';
						IF delay_count < 1000 THEN
							delay_count <= delay_count + 1;
							state_next <= hold;
						ELSE
							delay_count <= 0;
							state_next <= command_wr2;
						END IF;
 
					WHEN command_wr2 => 
						addr_out <= "1001000";
						data_wr <= x"00";
						rw <= '0';
						ena <= '1';
						send <= '0';
						delay_count <= 0;
						IF cmd_done_one_clk = '1' THEN
							state_next <= command_rd1;
						ELSE
							state_next <= command_wr2;
						END IF;
 
					WHEN command_rd1 => 
						ena <= '1';
						addr_out <= "1001000";
						data_wr <= x"00";
						rw <= '1'; -- read
						send <= '0';

						IF cmd_done_one_clk = '1' THEN
							state_next <= hold2;
						ELSE
							state_next <= command_rd1;
						END IF;
						data_rd <= data_raw_in;

					WHEN hold2 => 
						ena <= '0';
						-- send <= '1';
						IF delay_count < 1000 THEN
							delay_count <= delay_count + 1;
							state_next <= hold2;
						ELSE
							delay_count <= 0;
							state_next <= rd2;
						END IF;

					WHEN rd2 => 
						ena <= '0';
						send <= '1';
						state_next <= idle;


					WHEN OTHERS => 
						state_next <= idle;
				END CASE;
			END IF;
		END PROCESS;
END Behavioral;