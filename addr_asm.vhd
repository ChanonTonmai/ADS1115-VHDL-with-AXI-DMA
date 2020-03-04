----------------------------------------------------------------------------------
-- Company: vdesi, KMUTT
-- Engineer: K. Chanon
-- 
-- Create Date: 01/21/2019 09:31:23 PM
-- Design Name: 
-- Module Name: addr_asm - Behavioral
-- Project Name: ADS1115 I2C communication
-- Target Devices: any FPGA device
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- send told that the signal is finish transmission
-- cmd_done is the same as busy port

entity addr_asm is
    Port ( clk, reset : in STD_LOGIC;
           start, cmd_done : in STD_LOGIC;
			  bit_count   : in STD_LOGIC_VECTOR(4 DOWNTO 0); 
           addr_out : out STD_LOGIC_VECTOR (6 downto 0);
           data_wr : out STD_LOGIC_VECTOR (7 downto 0);
           ena, rw, send : out std_logic;
           data_raw_in : in STD_LOGIC_VECTOR (16 downto 0);
           data_rd : out STD_LOGIC_VECTOR (15 downto 0));      
end addr_asm;

architecture Behavioral of addr_asm is
    type ads1115_state is (idle, w1, w2, w3, w4,rd1, rd2, command_wr, command_rd1 , command_rd2); -- ADS1115 design for 1 channel
    signal state_reg, state_next: ads1115_state;
    signal cmd_done_tick, cmd_done_before, change_state, change_state_d, change_state_flag : std_logic; 
    
begin


--    edge_unit : entity work.edge_detect(gate_level_arch)
--        port map (clk=>clk, reset=>'0', level=>cmd_done, tick=>cmd_done_before);

  	 change_state <= '1' when bit_count = "00000" else '0';
    change_state_flag <= change_state and (not change_state_d);
	 
    cmd_done_tick <= not cmd_done and cmd_done_before;
	 
    process(clk)
    begin
        if (clk'event and clk= '1') then 
            cmd_done_before <= cmd_done;
            change_state_d <=  change_state;				
        end if;
    end process;

   
    -- next state logic/ output and data path routing
    process(clk)
    begin
	 if (clk'event and clk= '1') then
    -- state_next <= state_reg;
     case state_next is 
        when idle => 
            ena <= '0';
            rw <= '0';
            send <= '0';
            if reset = '0' then
				 if start = '1' then
              state_next <= command_wr; 
				 else
              state_next <= idle;	
             end if;				  
            else 
             state_next <= idle;
            end if; 
				
		   when command_wr =>  
            addr_out <= "1001000";
            data_wr <= x"01";
            rw <= '0';
            ena <= '1';
            send <= '0';
            if change_state_flag = '1' then 
                state_next <= w1; 
            else 
                state_next <= command_wr;
            end if;
				
        when w1 =>  
            addr_out <= "1001000";
            data_wr <= x"01";
            rw <= '0';
            ena <= '1';
            send <= '0';
            if change_state_flag = '1' then 
                state_next <= w2; 
            else 
                state_next <= w1;
            end if;
        when w2 => 
            addr_out <= "1001000";
            data_wr <= x"C0";
            rw <= '0';
            ena <= '1';
            send <= '0';
            if change_state_flag = '1' then 
                state_next <= w3; 
            else 
                state_next <= w2;
            end if;
				
        when w3 => 
            addr_out <= "1001000";
            data_wr <= x"83";
            rw <= '0';
            send <= '0';

            if change_state_flag = '1' then 
                state_next <= command_rd1; 
            else 
                state_next <= w3;
            end if;
	
		  	when command_rd1 =>  
            addr_out <= "1001000";
            data_wr <= x"00";
            rw <= '0';
            send <= '0';
			
            if change_state_flag = '1' then 
                state_next <= w4; 
            else 
                state_next <= command_rd1;
            end if;
					
				if bit_count = "00111"  then 
				    ena <= '0';    
            else 
				    ena <= '1';
            end if;	
				
        when w4 => 
            addr_out <= "1001000";
            data_wr <= x"00";
            rw <= '0';
            send <= '0';
				
				if change_state_flag = '1' then 	  
                state_next <= command_rd2; 
            else 
                state_next <= w4;
            end if;
            

        when command_rd2 =>  
            addr_out <= "1001000";
            data_wr <= x"00";
            rw <= '1';
            send <= '0';
				
            if change_state_flag = '1' then 
                state_next <= rd1; 
            else 
                state_next <= command_rd2;
            end if;
				
				if bit_count = "00111" then 
				    ena <= '0';    
            else 
				    ena <= '1';
            end if;
				
        when rd1 =>
		  
            addr_out <= "1001000";
            ena <= '1';
            rw <= '1';
            data_wr <= x"00";
            send <= '0';
				
				if change_state_flag = '1' then
				 state_next <= rd2; 
				else
				 state_next <= rd1;
            end if;
				
        when rd2 =>
            data_rd <= data_raw_in(16 downto 9) & data_raw_in(7 downto 0);
            ena <= '0';
         
            if reset = '0' then
				 if start = '1' then
				  ena <= '1';
              state_next <= command_rd1; 
				 else
              state_next <= idle;	
             end if;				  
            else 
             state_next <= idle;
            end if; 
				
			when others	 =>
				 state_next <= idle;
         end case;
		 end if;
     end process;     
                

end Behavioral;
