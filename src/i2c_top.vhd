LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY top_module_i2c IS
	PORT (
		clk : IN STD_LOGIC; --system clock
		reset_n : IN std_logic; -- reset addr_asm and address gen
		start : IN STD_LOGIC;
		-- write data to BRAM pin
		data_rd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		addr_wr_data : OUT STD_LOGIC_VECTOR(12 DOWNTO 0); -- address gen to BRAM
		wea : OUT STD_LOGIC; -- tell that 1 data is done, use to tick wea in BRAM
		frame_complete : OUT std_logic;
		pga : IN std_logic_vector(2 DOWNTO 0);
		dr : IN std_logic_vector(2 DOWNTO 0);
		--i2c_clk : out std_logic;
		sda : INOUT STD_LOGIC; --serial data output of i2c bus
	scl : INOUT STD_LOGIC); --serial clock output of i2c bus
END top_module_i2c;

ARCHITECTURE Behavioral OF top_module_i2c IS

	COMPONENT i2c_master IS
		GENERIC (
			input_clk : INTEGER := 100000000; --input clock speed from user logic in Hz
		bus_clk : INTEGER := 400000); 
		PORT (
			clk : IN STD_LOGIC; --system clock
			reset_n : IN STD_LOGIC; --active low reset
			ena : IN STD_LOGIC; --latch in command
			addr : IN STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave -- change to (7 downto 0) : tm
			rw : IN STD_LOGIC; --'0' is write, '1' is read
			data_wr : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
			busy : OUT STD_LOGIC; --indicates transaction in progress
			finish : OUT std_logic;
			data_rd : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); --data read from slave -- change to 16 for receive 2 package
			ack_error : BUFFER STD_LOGIC; --flag if improper acknowledge from slave
			sda : INOUT STD_LOGIC; --serial data output of i2c bus
		scl : INOUT STD_LOGIC); --serial clock output of i2c bus
	END COMPONENT;

	COMPONENT addr_asm IS
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
	END COMPONENT;

	SIGNAL clk_50 : STD_LOGIC;
	SIGNAL ena : STD_LOGIC;
	SIGNAL addr : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL rw : STD_LOGIC;
	SIGNAL data_wr : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL busy, send : STD_LOGIC;
	SIGNAL data_rd_signal : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL data_rd_i2c : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL ack_error : STD_LOGIC;
	SIGNAL count : INTEGER RANGE 0 TO 8191 := 0;
	SIGNAL addr_rd_cnt : INTEGER RANGE 0 TO 8192 := 0;
	SIGNAL finish : std_logic;
 
 
	-- signal frame_complete : std_logic; -- tell that all the design data is going to BRAM completely
	TYPE rd_state IS (idle, send_addr);
	SIGNAL state_rd : rd_state;
 
	SIGNAL d_ready_sig, frame_complete_delay, wea_sig, start_one_clk, change_state_d : std_logic;
	SIGNAL globalCounter : std_logic_vector(12 - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN
	data_rd <= x"0000" & data_rd_signal;
	--d_ready <= d_ready_sig;
	i2c : i2c_master
		GENERIC MAP(
		input_clk => 100000000, --input clock speed from user logic in Hz
		bus_clk => 400000)
		PORT MAP(
			clk => clk, 
			reset_n => '1', 
			ena => ena, 
			addr => addr, 
			rw => rw, 
			data_wr => data_wr, 
			busy => busy, 
			data_rd => data_rd_i2c, 
			ack_error => ack_error, 
			sda => sda, 
			scl => scl, 
			finish => finish
		);

			address_gen : addr_asm
			PORT MAP(
				clk => clk, 
				reset_n => '1', 
				start => start, 
				cmd_done => finish, 
				addr_out => addr, 
				data_wr => data_wr, 
				ena => ena, 
				rw => rw, 
				send => send, 
				pga => pga, 
				dr => dr, 
				data_raw_in => data_rd_i2c, 
				data_rd => data_rd_signal
	);
	start_one_clk <= start AND (NOT change_state_d);

	PROCESS (clk)
	BEGIN
		IF (clk'EVENT AND clk = '1') THEN
			change_state_d <= start;
		END IF;
	END PROCESS;

	PROCESS (clk) BEGIN
	IF rising_edge(clk) THEN
		CASE state_rd IS
			WHEN idle => 
				-- wait for start
				count <= 0;
				wea_sig <= '0';
				IF start_one_clk = '1' THEN
					state_rd <= send_addr;
				ELSE
					state_rd <= idle;
				END IF;
 
			WHEN send_addr => 
				IF count < 2048 THEN
					IF send = '1' THEN
						wea_sig <= '1';
						count <= count + 1;
						state_rd <= send_addr;
					ELSE
						wea_sig <= '0';
						state_rd <= send_addr;
					END IF;
				ELSE
					count <= 0;
					wea_sig <= '0';
					state_rd <= idle;
				END IF;
		END CASE;
	END IF;
	END PROCESS;

	wea <= send WHEN state_rd = send_addr ELSE '0';

	addr_wr_data <= std_logic_vector(to_unsigned(count, addr_wr_data'length));
	--addr_rd_count <= std_logic_vector(to_unsigned(addr_rd_cnt, addr_rd_count'length));
	--wea <= send; -- tell that 1 data is done, use to tick wea in BRAM
	frame_complete <= '1' WHEN count = 2048 ELSE '0';

END Behavioral;