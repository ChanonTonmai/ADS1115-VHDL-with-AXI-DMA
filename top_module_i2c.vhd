----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:57:38 02/03/2019 
-- Design Name: 
-- Module Name:    top_module_i2c - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_module_i2c is
PORT(
    clk       : IN     STD_LOGIC;                    --system clock
	 start     : IN     STD_LOGIC; 
	 --data_rd   : OUT    STD_LOGIC_VECTOR(15 DOWNTO 0); 
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : OUT  STD_LOGIC);                   --serial clock output of i2c bus
end top_module_i2c;

architecture Behavioral of top_module_i2c is

component i2c_master IS

  PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave -- change to (7 downto 0) : tm
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
	 bit_count : OUT    STD_LOGIC_VECTOR(4 DOWNTO 0);
    data_rd   : OUT    STD_LOGIC_VECTOR(16 DOWNTO 0); --data read from slave -- change to 16 for receive 2 package 
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : OUT  STD_LOGIC);                   --serial clock output of i2c bus
end component;

component addr_asm is
    Port ( clk, reset : in STD_LOGIC;
           start, cmd_done : in STD_LOGIC;
			  bit_count   : in STD_LOGIC_VECTOR(4 DOWNTO 0);
           addr_out : out STD_LOGIC_VECTOR (6 downto 0);
           data_wr : out STD_LOGIC_VECTOR (7 downto 0);
           ena, rw, send : out std_logic;
           data_raw_in : in STD_LOGIC_VECTOR (16 downto 0);
           data_rd : out STD_LOGIC_VECTOR (15 downto 0));      
end component;

component clock_gen IS
	  Port ( clk_in1 : in STD_LOGIC;
	         clk_out1 : out STD_LOGIC);
end component;
				
signal clk_50 : STD_LOGIC;
signal ena     : STD_LOGIC;                 
signal addr      : STD_LOGIC_VECTOR(6 DOWNTO 0); 
signal rw        : STD_LOGIC;                    
signal data_wr   : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal busy      : STD_LOGIC;  
signal send      : STD_LOGIC;                 
signal data_rd_signal, data_rd : STD_LOGIC_VECTOR(15 DOWNTO 0); 
signal data_rd_i2c : STD_LOGIC_VECTOR(16 DOWNTO 0); 
signal ack_error : STD_LOGIC;                    
signal bit_count_signal : STD_LOGIC_VECTOR(4 DOWNTO 0);
			
begin

	data_rd <= data_rd_signal;
	
--	clock : clock_gen port map(
--	 clk_in1 => clk,
--	 clk_out1 => clk_50
--   );	
	
	i2c : i2c_master port map(
    clk       => clk,
    reset_n   => '1',
    ena       => ena,
    addr      => addr,
    rw        => rw,
    data_wr   => data_wr,
    busy      => busy,
    data_rd   => data_rd_i2c,
    ack_error => ack_error,
    sda       => sda,
    scl       => scl,
    bit_count => bit_count_signal
   );	
	
	address_gen : addr_asm port map(
    clk       => clk,
	 reset     => '0',
    start     => start,
	 cmd_done  => busy,
    addr_out  => addr,
    data_wr   => data_wr,
    ena       => ena,
	 rw        => rw,
	 send      => send ,
    data_raw_in  => data_rd_i2c,
    data_rd   => data_rd_signal,
	 bit_count => bit_count_signal
   );	
	

end Behavioral;

