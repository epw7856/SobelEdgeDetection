----------------------------------------------------------------------------------
-- ECE2120 Final Project - Image Processing Edge Detection
--
-- Authors: Eric Walker, Tyler Garrett, and Vince DeMaio. 
--
-- This is the MEM submodule for the Image Edge Detection project. In this 
-- module, image data is written to RAM and also pixel elements are processed to
-- produce new output pixel data that is edge detected.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MEM is
    generic( mem_depth: integer := 270000 );
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_wr_en : in STD_LOGIC;  -- Write data enable 
           i_data : in STD_LOGIC_VECTOR (7 downto 0);  -- Incoming pixel element byte
           i_r_adr : in STD_LOGIC_VECTOR (15 downto 0);  -- Read data address
           o_data : out STD_LOGIC_VECTOR (7 downto 0);   -- Output read data
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
end MEM;

architecture Behavioral of MEM is

constant WIDTH : integer := 300;
constant HEIGHT : integer := 300;

-- Image data is stored in RAM initialized to the total number of bytes in
-- the image. The data type stored is integer becasue all pixel data will be
-- in the form of 8-bit unsigned integers (0 to 255) for colors.
TYPE MEM_type IS ARRAY ( 0 to (mem_depth-1)) OF integer range 0 to 255;
SIGNAL r_mem : MEM_type;
SIGNAL r_w_adr : INTEGER RANGE 0 TO mem_depth :=0;  -- Write data address
Alias row_current is row_cnt;
Alias col_current is col_cnt;

begin

-- Main process block
process (i_clk)

-- Intermediate variables needed for the edge detection algorithm. Hx is the resultant of a convolution of the 3x3 Sobel Horizontal Filter
-- with the 3x3 pixel matrix with the current pixel element at the center. Hy is the same but using the Sobel Veritical Filter.
variable Hx, Hy : integer := 0;
variable element_0_0, element_0_1, element_0_2, element_1_0, element_1_2, element_2_0, element_2_1, element_2_2 : integer := 0;
variable row, col : integer := 0;

begin

    if i_rst ='1' then
        r_w_done <='0';
        r_w_adr <=0;
    else
        if rising_edge(i_clk) then
            if r_w_done = '0' then       -- When write operation is not done, write data
                if i_wr_en ='1' then
                    if r_w_adr < mem_depth-1 then  -- When RAM is not full, write data
                        r_mem(r_w_adr)<= to_integer(unsigned(i_data));
                        r_w_adr <=r_w_adr + 1;
                    else                      -- When the RAM is full, write operation is done
                        r_mem(r_w_adr)<= to_integer(unsigned(i_data));
                        r_w_adr <=r_w_adr + 1;  
                        r_w_done <= '1';
                    end if;
                end if;
            else 
                      
                 --Writing to memory is finished. Calculate new pixel values for Edge Detected image.
                
                -- This logic block recalculates the column count based on clock cycle delay
                -- from when it was incremented in the top level module
                if(col_current = 0 and row_current = HEIGHT - 1) then
                    col := col_current;
                elsif(col_current = WIDTH-1 and row_current = 0) then
                    col := col_current;
                elsif(col_current > 0) then
                    col := col_current - 1;
                else
                    col := WIDTH - 1;
                end if;
                                                                                  
                -- This logic block recalculates the row count based on clock cycle delay
                -- from when it was incremented in the top level module                                                                  
                if(row_current < HEIGHT-1 and col_current = 0) then
                    row := row_current + 1;
                else
                    row := row_current;
                end if;
                
                -- If the current pixel element (r, g, or b) is on the edge of the image, set
                -- the new pixel value to color to black (0)                       
                if((col = 0) or (col = WIDTH-1) or (row = 0) or (row = HEIGHT-1)) then
                    Hx := 0;
                    Hy := 0;
                
                -- If the current pixel element is inside the image, the edge detection algorithm must be applied. In
                -- the following equation, the term "Pixel_Array" means the 3x3 array formed from the current pixel
                -- element at the center with its 8 neighboring pixel values surrounding it.
                --
                --   Hx = Pixel_Array * Gx  ,  Hy = Pixel_Array * Gy
                --
                --   New Pixel Value = abs(Hx) + abs(Hy)
                --
                --                                 |  -1 0 1  |
                --   Sobel Horizontal Filter: Gx = |  -2 0 2  |
                --                                 |  -1 0 1  |
                --
                --
                --                                  |  1 2 1   |
                --   Sobel Vertical Filter: Gy =  = |  0 0 0   |
                --                                  | -1-2-1   |
                --
                else
                    
                    -- Access the neighboring pixel element values
                    element_0_0 := r_mem(index_0_0);  -- Pixel element top left
                    element_0_1 := r_mem(index_0_1);  -- Pixel element top middle
                    element_0_2 := r_mem(index_0_2);  -- Pixel element top right
                    element_1_0 := r_mem(index_1_0);  -- Pixel element middle left
                    element_1_2 := r_mem(index_1_2);  -- Pixel element middle right
                    element_2_0 := r_mem(index_2_0);  -- Pixel element bottom left
                    element_2_1 := r_mem(index_2_1);  -- Pixel element bottom middle
                    element_2_2 := r_mem(index_2_2);  -- Pixel element middle right
                    
                    -- Apply convolution of Sobel Horizontal Filter to the pixel array values
                    Hx := element_0_2 + 2*element_1_2 + element_2_2 - element_0_0 - 2*element_1_0 - element_2_0;
                    -- Take the absolute value of Hx
                    if(Hx < 0 ) then
                        Hx := (-1)*Hx;
                    end if;
                     
                    -- Apply convolution of Sobel Vertical Filter to the pixel array values       
                    Hy := element_0_0 + 2*element_0_1 + element_0_2 - element_2_0 - 2*element_2_1 - element_2_2;
                    -- Take the absolute value of Hy
                    if(Hy < 0 ) then
                        Hy := (-1)*Hy;
                    end if;
                        
                end if;
                
                -- Add the Hx and Hy components. Max allowable pixel element value is 255 (white)   
                if(Hx + Hy > 255) then
                    o_data <= std_logic_vector(to_unsigned(255,8));
                else
                    o_data <= std_logic_vector(to_unsigned(Hx+Hy,8));
                end if;
                
            end if;
        end if;
    end if;
end process;    
    

end Behavioral;
