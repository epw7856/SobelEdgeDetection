----------------------------------------------------------------------------------
-- ECE2120 Final Project - Image Processing Edge Detection
--
-- Authors: Eric Walker, Tyler Garrett, and Vince DeMaio. 
--
-- This file is the top level module and is fully synthesizable.
-- This project consists of a top level module, UART Rx submodule, MEM submodule, 
-- and UART Tx submodule. The top level module, top_level_test, instantiates the
-- UART Rx, MEM, and UART Tx modules. The code is currently configured to process
-- a 300x300 sized, 24-bit-per-pixel image.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level_test is
    generic( mem_depth:integer := 270000);  -- Size of the image data (WIDTH * HEIGHT * 3)
    Port ( 
            i_clk : in STD_LOGIC;
            i_rst : in STD_LOGIC;                       
            i_r_adr : in STD_LOGIC_VECTOR (15 downto 0);
            o_data : inout STD_LOGIC_VECTOR (7 downto 0);  
            i_RX_Serial : in  std_logic;   
            o_TX_Serial : out std_logic                             
         );
end top_level_test;

architecture Behavioral of top_level_test is 

constant WIDTH : integer := 300;  -- Image width in pixels
constant HEIGHT : integer := 300;  -- Image height in pixels

-- Declare the MEM component
component MEM is
    generic( mem_depth: integer := 270000 );
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_wr_en : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           i_r_adr : in STD_LOGIC_VECTOR (15 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           r_w_done : inout STD_LOGIC;
           row_cnt : in integer;
           col_cnt : in integer;
           index_0_0 : in integer;
           index_0_1 : in integer;
           index_0_2 : in integer;
           index_1_0 : in integer;
           index_1_2 : in integer;
           index_2_0 : in integer;
           index_2_1 : in integer;
           index_2_2 : in integer
           );
end component;

-- Declare UART Rx component
component UART_RX is
  generic (
    g_CLKS_PER_BIT : integer := 434 -- 50 MHz Clock / 115200 baud UART
    );
  port (
    i_clk       : in  std_logic;
    i_RX_Serial : in  std_logic;
    o_RX_DV     : out std_logic;
    o_RX_Byte   : out std_logic_vector(7 downto 0)
    );
end component;

-- Declare UART Tx component
component UART_TX is
  generic (
    g_CLKS_PER_BIT : integer := 434 -- 50 MHz Clock / 115200 baud UART
    );
  port (
    i_Clk       : in  std_logic;
    i_TX_DV     : in  std_logic;
    i_TX_Byte   : in  std_logic_vector(7 downto 0);
    data_count : in integer;
    o_TX_Active : out std_logic;
    o_TX_Serial : out std_logic;
    o_TX_Done   : out std_logic
    );
end component;


-- Define intermediate signals
signal r_wr_en : std_logic := '0';  -- MEM write enable
signal data_temp : std_logic_vector(7 downto 0);
signal r_w_done : std_logic := '0';
signal process_done : std_logic := '0';  -- Image processing completed
signal row : integer range 0 to HEIGHT := (HEIGHT-1);
signal col : integer range 0 to WIDTH := 0;
signal pixel : integer range 0 to 2 := 0;
signal data_count : integer range 0 to (WIDTH*HEIGHT*3);
signal index_0_0 : integer range 0 to 255;  -- RAM array index for top left pixel of 3x3 matrix
signal index_0_1 : integer range 0 to 255;  -- RAM array index for top middle pixel of 3x3 matrix
signal index_0_2 : integer range 0 to 255;  -- RAM array index for top right pixel of 3x3 matrix
signal index_1_0 : integer range 0 to 255;  -- RAM array index for middle left pixel of 3x3 matrix
signal index_1_2 : integer range 0 to 255;  -- RAM array index for middle right pixel of 3x3 matrix
signal index_2_0 : integer range 0 to 255;  -- RAM array index for bottom left pixel of 3x3 matrix
signal index_2_1 : integer range 0 to 255;  -- RAM array index for bottom middle pixel of 3x3 matrix
signal index_2_2 : integer range 0 to 255;  -- RAM array index for bottom right pixel of 3x3 matrix
signal o_tx_active : std_logic := '0';
signal o_tx_done : std_logic := '0';
signal i_tx_dv : std_logic := '1';

begin

-- Instantiate the UART Rx component to receive image data from the computer
UART_READ : UART_RX port map ( i_clk=> i_clk, i_RX_Serial=> i_RX_Serial, o_RX_DV=> r_wr_en,  o_RX_Byte => data_temp );

-- Instantiate the MEM component to write received image data to RAM
w_r_mem : MEM   generic map(mem_depth=> mem_depth)
                port map (i_clk => i_clk, i_rst=> i_rst, i_wr_en => r_wr_en, i_data=> data_temp, i_r_adr=>i_r_adr, o_data=>o_data, r_w_done=>r_w_done, row_cnt=>row, col_cnt=>col, index_0_0=>index_0_0, index_0_1=>index_0_1, index_0_2=>index_0_2, index_1_0=>index_1_0, index_1_2=>index_1_2, index_2_0=>index_2_0, index_2_1=>index_2_1, index_2_2=>index_2_2 );

-- Instantiate the UART Tx component to send processed (edge detected) image data byte back to the computer
UART_TRANSMIT : UART_TX port map ( i_Clk=> i_clk, i_TX_DV=> i_tx_dv, i_TX_Byte=> o_data, data_count=> data_count, o_TX_Active=> o_tx_active, o_TX_Serial=> o_tx_serial, o_TX_Done=> o_tx_done );


-- Main process block
process(i_clk, r_w_done)
	begin
	
	    -- Only increment pixel element and calculate RAM array indices on a rising edge clock, when the writing
	    -- to RAM has completed, the image processing has not completed, and a processed byte is not 
	    -- being currently sent back over UART to the computer.
		if(rising_edge(i_clk) and r_w_done = '1' and process_done = '0' and o_tx_active = '0') then
			
			-- Image processing is complete when the data_count is equal to the total amount of bytes
			-- in the image
			if(data_count = WIDTH*HEIGHT*3) then
				process_done <= '1';
				
		    -- If the data count has not reached the limit, increment the pixel element
			else
			    
			    -- This logic block determines the current pixel element to be processed into a new
			    -- edge-detected pixel element byte. There are 3 pixel elements per column, 300 columns
			    -- per row, and 300 rows. Each cycle increments the pixel element, column, and row
			    -- as appropriate. The row count decrements down from 300 because the image data is 
			    -- read into RAM from the bottom row up.
		        if(pixel = 2) then
		            pixel <= 0;
		            
		            if(col = WIDTH-1) then
                        row <= row - 1;
                        col <= 0;
                    else
                        col <= col + 1;
                    end if;
                    
		        else
		            pixel <= pixel + 1;
		        end if;
		        
		        -- Increment the data count when the pixel element is incremented
                data_count <= data_count + 1;
                
                -- This is where the RAM array indices are calculated needed to access
                -- the neighboring 8 pixel values of the current pixel element. The 
                -- algorithm uses the width and height constants as well as the current
                -- pixel, column, and row count to determine the proper index for each
                -- neighbor pixel element
                index_0_0 <= WIDTH*3*(HEIGHT-(row-1)-1)+3*(col-1)+pixel-2;  -- Top left pixel index
                index_0_1 <= WIDTH*3*(HEIGHT-(row-1)-1)+3*col+pixel-2;  -- Top middle pixel index
                index_0_2 <= WIDTH*3*(HEIGHT-(row-1)-1)+3*(col+1)+pixel-2;  -- Top right pixel index
                index_1_0 <= WIDTH*3*(HEIGHT-row-1)+3*(col-1)+pixel-2;  -- Middle left pixel index
                index_1_2 <= WIDTH*3*(HEIGHT-row-1)+3*(col+1)+pixel-2;  -- Middle right pixel index
                index_2_0 <= WIDTH*3*(HEIGHT-(row+1)-1)+3*(col-1)+pixel-2;  -- Bottom left pixel index
                index_2_1 <= WIDTH*3*(HEIGHT-(row+1)-1)+3*col+pixel-2;  -- Bottom middle pixel index
                index_2_2 <= WIDTH*3*(HEIGHT-(row+1)-1)+3*(col+1)+pixel-2;  -- Bottom right pixel index

			end if;
			
		end if;
end process;
   
end Behavioral;
