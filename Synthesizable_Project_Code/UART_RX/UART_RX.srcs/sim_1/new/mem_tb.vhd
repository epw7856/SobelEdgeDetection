----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2018 02:26:34 PM
-- Design Name: 
-- Module Name: mem_tb - Behavioral
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
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mem_tb is
--  Port ( );
end mem_tb;

architecture Behavioral of mem_tb is

component MEM is
    generic( mem_depth:integer := 3);
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_wr_en : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           i_r_adr : in STD_LOGIC_VECTOR (15 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           r_w_done : inout STD_LOGIC
           );
end  component;

signal i_clk :  STD_LOGIC :='0';                       
signal i_wr_en :  STD_LOGIC:='0';                     
signal i_data :  STD_LOGIC_VECTOR (7 downto 0);  
signal i_r_adr : STD_LOGIC_VECTOR (15 downto 0);             
signal o_data :  STD_LOGIC_VECTOR (7 downto 0);  
signal i_rst :   STD_LOGIC:='0';
signal r_w_done :   STD_LOGIC:='0';

begin

uut: MEM port map (i_clk=>i_clk,i_wr_en=>i_wr_en,i_rst=>i_rst,i_data=>i_data, i_r_adr=>i_r_adr, o_data=>o_data, r_w_done=>r_w_done);
i_clk <= not i_clk after 5 ns;

process
begin
    i_r_adr <= "0000000000000000";
    wait for 5 ns;
    i_data<= "00000001";
    wait for 10 ns;
    i_wr_en <='1';
    wait for 10 ns;
    i_wr_en <='0';
    wait for 10 ns;
    i_data<= i_data+'1';
    wait for 10 ns;
    i_wr_en <='1';
    wait for 10 ns;
    i_wr_en <='0'; 
    wait for 10 ns;
    i_data<= i_data+'1';
    wait for 10 ns;
    i_wr_en <='1';
    wait for 10 ns;
        i_wr_en <='0'; 
    wait for 10 ns;    
    i_data<= i_data+'1';
    wait for 10 ns;
    i_wr_en <='1';
    wait for 10 ns;
        i_wr_en <='0'; 
    wait for 10 ns;
    i_data<= i_data+'1';
    wait for 10 ns;
    i_wr_en <='1';
    wait for 10 ns;
        i_wr_en <='0'; 
    wait for 10 ns;
    i_r_adr <= "0000000000000001";
    wait for 10 ns;
    i_r_adr <= "0000000000000010";
    wait for 10 ns;   
    wait;
end process;

end Behavioral;
