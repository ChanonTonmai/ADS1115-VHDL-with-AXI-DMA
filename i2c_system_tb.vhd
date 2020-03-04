----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/29/2019 03:31:15 AM
-- Design Name: 
-- Module Name: i2c_system_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity i2c_system_tb is
--  Port ( );
end i2c_system_tb;

architecture Behavioral of i2c_system_tb is
    signal clk, rst_n, reset, ena, rw, busy, ack_error, sda, scl : std_logic;
    signal start, send, in_progress, tx_done, rx_data_rdy : std_logic;
    signal addr : std_logic_vector(6 downto 0);
	 signal data_wr, rx_byte : std_logic_vector(7 downto 0);
    signal data_rd, tx_byte : std_logic_vector(16 downto 0);
    signal data_now : std_logic_vector(15 downto 0);
    
    constant clk_period : time := 25ns;
    
begin
    
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process; 
    
    i2c_uut : entity work.i2c_master(logic)
        port map(clk=>clk, reset_n=>rst_n, ena=>ena, addr=>addr, rw=>rw, data_wr=>data_wr, busy=>busy, data_rd=>data_rd,
                    ack_error=>ack_error, sda=>sda, scl=>scl);
    addr_uut : entity work.addr_asm(Behavioral)
        port map(clk=>clk, reset=>reset, start=>start, cmd_done=>busy, addr_out=>addr, data_wr=>data_wr, ena=>ena, rw=>rw, send=>send, 
                    data_raw_in=>data_rd, data_rd=>data_now);
    
	 i2c_slave_uut : entity work.i2c_slave(Behavioral)
	 port map(
     scl             => '0',
     sda             => '0', 
     in_progress     => in_progress,
     tx_done         => tx_done,
     tx_byte         => tx_byte,
     rx_byte         => rx_byte,
     rx_data_rdy     => rx_data_rdy,
     clk             => clk
	  );
	 
	  
    rst_n <= not reset;
    stim : process
    begin
        reset <= '1';
        wait for 100ns;
		  tx_byte <= "00001111011110000";
        reset <= '0';
        start <= '1';

         wait;
    end process;

end Behavioral;
