----------------------------------------------------------------------------------
-- This is the ECE2120 Final Project - Image Processing Edge Detection Testbench 
-- Simlation for Eric Walker, Tyler Garrett, and Vince DeMaio. This defines the 
-- input stimuli for the top level image processing module. The simulation must be
-- set for 20ms to process all image data.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity top_level_test_tb is
--  Port ( );
end top_level_test_tb;

architecture Behavioral of top_level_test_tb is

    -- Define the top level component
    COMPONENT top_level_test
        generic( HEIGHT: integer := 512; WIDTH: integer := 768 );
        Port ( 
                i_clk : in STD_LOGIC;
                row : inout integer range 0 to HEIGHT := (HEIGHT-1);
                row_last : inout integer range 0 to HEIGHT := (HEIGHT-1);
                col : inout integer range 0 to WIDTH := 0;
                col_last : inout integer range 0 to WIDTH := 0;
                pixel : inout integer range 0 to 2 := 0;
                pixel_last : inout integer range 0 to 2 := 0;
                data_count : inout integer range 0 to (WIDTH*HEIGHT*3);
                o_data : inout std_logic_vector (7 downto 0);
                index_0_0 : inout integer range 0 to (WIDTH*HEIGHT*3) := 0;
                index_0_1 : inout integer := 0;
                index_0_2 : inout integer := 0;
                index_1_0 : inout integer := 0;
                index_1_2 : inout integer := 0;
                index_2_0 : inout integer := 0;
                index_2_1 : inout integer := 0;
                index_2_2 : inout integer := 0
             );
    END COMPONENT;
    
-- Define image size constants
constant WIDTH : integer := 768;
constant HEIGHT : integer := 512;
constant sizeOfLengthReal : integer := 1179648; -- WIDTH * HEIGHT * 3

-- Define intermediate signals
signal i_clk : std_logic := '0';
signal r_w_done : std_logic := '1';
signal o_data : STD_LOGIC_VECTOR(7 downto 0);
signal row : integer range 0 to HEIGHT;
signal col : integer range 0 to WIDTH;
signal row_last : integer range 0 to HEIGHT;
signal col_last : integer range 0 to WIDTH;
signal pixel : integer range 0 to 2;
signal pixel_last : integer range 0 to 2;
signal data_count : integer range 0 to (WIDTH*HEIGHT*3);
signal index_0_0 : integer range 0 to 255;
signal index_0_1 : integer range 0 to 255;
signal index_0_2 : integer range 0 to 255;
signal index_1_0 : integer range 0 to 255;
signal index_1_2 : integer range 0 to 255;
signal index_2_0 : integer range 0 to 255;
signal index_2_1 : integer range 0 to 255;
signal index_2_2 : integer range 0 to 255;

begin

-- Define Unit Under Test for the top level module
uut1: top_level_test PORT MAP (
          i_clk => i_clk,
          row => row,
          row_last => row_last,
          col => col,
          col_last => col_last,
          pixel => pixel,
          pixel_last => pixel_last,
          data_count => data_count,
          o_data => o_data,
          index_0_0 => index_0_0,
          index_0_1 => index_0_1,
          index_0_2 => index_0_2,
          index_1_0 => index_1_0,
          index_1_2 => index_1_2,
          index_2_0 => index_2_0,
          index_2_1 => index_2_1,
          index_2_2 => index_2_2
        );
        
        -- Set the clock to change every 5ns
        process(i_clk)	
        begin
            i_clk <=  NOT i_clk AFTER 5 ns;     
        end process;

end Behavioral;
