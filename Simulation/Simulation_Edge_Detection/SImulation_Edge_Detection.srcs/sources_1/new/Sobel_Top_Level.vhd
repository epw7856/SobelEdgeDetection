----------------------------------------------------------------------------------
-- ECE2120 Final Project - Image Processing Edge Detection for Eric
-- Walker, Tyler Garrett, and Vince DeMaio. This project consists of a single top
-- level module that is used for simulation purposes to verify the edge detection
-- algorithm. This code cannot be synthesized. In this code, a 768x512 sized input
-- image (in the form of a pre-processed, newline-delimited hex file) is processed 
-- to produce an output hex file. The output hex file must be post-processed to 
-- produce a viewable bitmap image. The output is the edge detected image.


-- Theory of Operation
-- The code initializes the RAM and reads in the contents of the input hex file.
-- The image data consists of 3 bytes per pixel and is stored in RAM one byte at a
-- time from the bottom row up, and from the left column to the right. To produce
-- output image data, each byte must be processed via matrix operations with its 
-- neighboring pixel values and the Sobel matrix coefficients. First, the pixel,
-- column, and row count is incremented appropriately every clock cycle. The 
-- current byte is then passed into the "MEM" procedure to produce the new, 
-- processed output byte. If the pixel is on the edge of the image, it will
-- automatically be set to color block, or 0. Because the MEM procedure is behind
-- one clock cycle, the pixel, column, and row count is decremented to stay current.
-- To access the neighboring pixel values, the RAM array indices are calculated 
-- also passed into the MEM procedure. After the new byte is calculated in MEM,
-- the write_output procedure is called to write the byte to the output file in 
-- hex. This operation is performed for every byte of the image (WIDTH*HEIGHT*3).
----------------------------------------------------------------------------------

--Load Libraries. Textio needed for file operations.
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
LIBRARY STD;
USE STD.textio.all;
LIBRARY work;

--Declare top level entity
entity top_level_test is
    generic( HEIGHT: integer := 512; WIDTH: integer := 768 );  -- Define image size as 768x512 pixels
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
            index_0_0 : inout integer := 0;
            index_0_1 : inout integer := 0;
            index_0_2 : inout integer := 0;
            index_1_0 : inout integer := 0;
            index_1_2 : inout integer := 0;
            index_2_0 : inout integer := 0;
            index_2_1 : inout integer := 0;
            index_2_2 : inout integer := 0
         );
end top_level_test;

architecture Behavioral of top_level_test is

constant sizeOfLengthReal : integer := 1179648;  -- Total size of the RGB pixel data: WIDTH * HEIGHT * 3
constant INFILE : string := "Cathedral_Input.hex";  -- Define the input hex file name

-- Declare intermediate signals
signal r_w_done : std_logic := '1';
signal process_done : std_logic := '0';
signal start : std_logic := '0';

--Read in all pixel data from the image and store in block RAM
TYPE mem_type IS ARRAY(0 TO (sizeOfLengthReal-1)) OF integer range 0 to 255;  -- Pixel data inside RAM array will never be greater than 255 or less than 0

impure function init_mem(mif_file_name : in string) return mem_type is
    file mif_file : text open read_mode is mif_file_name;
    variable mif_line : line;
    variable temp_bv : integer range 0 to 255;
    variable temp_mem : mem_type;

begin
    -- Iterate through each line of the file and store the contents as an unsigned integer in RAM
    for i in mem_type'range loop
        readline(mif_file, mif_line);
        read(mif_line, temp_bv);
        temp_mem(i) := temp_bv;
    end loop;
    return temp_mem;
end function;

-- Initialize the RAM and call the function to read the input file
signal ram_block: mem_type := init_mem(INFILE);


-- Define the procedure to perform edge detection image processing
procedure MEM(
           signal i_clk : in STD_LOGIC;
           signal o_data : out STD_LOGIC_VECTOR (7 downto 0);
           signal r_w_done : in STD_LOGIC;
           signal row_cnt : in integer;
           signal col_cnt : in integer;
           signal index_0_0 : in integer;
           signal index_0_1 : in integer;
           signal index_0_2 : in integer;
           signal index_1_0 : in integer;
           signal index_1_2 : in integer;
           signal index_2_0 : in integer;
           signal index_2_1 : in integer;
           signal index_2_2 : in integer
           ) is

--Declare intermediate variables
variable Hx, Hy : integer := 0;  -- Hx and Hy are used to directly calculate each new pixel value
variable element_0_0, element_0_1, element_0_2, element_1_0, element_1_2, element_2_0, element_2_1, element_2_2 : integer := 0;  -- Neighboring pixel values for the pixel under consideration 
variable row, col : integer := 0;
Alias row_current is row_cnt;
Alias col_current is col_cnt;

begin
            -- Only perform operations on rising clock edge and when the writing to RAM is complete
            if (rising_edge(i_clk) and r_w_done ='1') then

                -- The current column will be delayed by a clock cycle. This logic block calculates
                -- the previous column number needed for the processing operations.
                if(col_current = 0 and row_current = HEIGHT - 1) then
                    col := col_current;  -- Keep the column number current if first pixel
                elsif(col_current = WIDTH-1 and row_current = 0) then
                    col := col_current;  -- Keep the column number current if last pixel
                elsif(col_current > 0) then
                    col := col_current - 1;  -- Decrement the column number
                else
                    col := WIDTH - 1;  -- Decrement the column number
                end if;
                                                 
                
                -- Just as the column was adjusted because of the clock cycle delay,
                -- the same is performed for the row number. However, the image data
                -- is stored in RAM from the bottom row to the top so the row number
                -- must be incremented instead of decremented                               
                if(row_current < HEIGHT-1 and col_current = 0) then
                    row := row_current + 1;
                else
                    row := row_current;
                end if;
                
                -- If the current pixel is on the edge of the image, set Hx and Hy to be color black (or 0)                      
                if((col = 0) or (col = WIDTH-1) or (row = 0) or (row = HEIGHT-1)) then
                    Hx := 0;
                    Hy := 0;
                    
                -- If the current pixel is not the image edge, perform processing
                else
                    
                    -- Read the 8 neighboring pixel values to the current pixel from the RAM array
                    element_0_0 := ram_block(index_0_0);
                    element_0_1 := ram_block(index_0_1);
                    element_0_2 := ram_block(index_0_2);
                    element_1_0 := ram_block(index_1_0);
                    element_1_2 := ram_block(index_1_2);
                    element_2_0 := ram_block(index_2_0);
                    element_2_1 := ram_block(index_2_1);
                    element_2_2 := ram_block(index_2_2);
                    
                    -- Calculate Hx based on neighboring pixel values and Sobel operator horizontal filter coefficients : [-1 0 1; -2 0 2; -1 0 1]
                    Hx := element_0_2 + 2*element_1_2 + element_2_2 - element_0_0 - 2*element_1_0 - element_2_0;
                    -- Ensure that Hx is a positive value (absolute value)
                    if(Hx < 0 ) then
                        Hx := (-1)*Hx;
                    end if;
                    
                    -- Calculate Hy based on neighboring pixel values and Sobel operator vertical filter coefficients : [1 2 1; 0 0 0; -1 -2 -1]       
                    Hy := element_0_0 + 2*element_0_1 + element_0_2 - element_2_0 - 2*element_2_1 - element_2_2;
                    -- Ensure that Hy is a positive value (absolute value)
                    if(Hy < 0 ) then
                        Hy := (-1)*Hy;
                    end if;
                        
                end if;
                    
                -- The original equation for Edge Detection calls for sqrt(Hx^2 + Hy^2) but it will be aproximated by abs(Hx) + abs(Hy)
                
                -- Ensure that the new pixel value is less than the max 255     
                if(Hx + Hy > 255) then
                    o_data <= std_logic_vector(to_unsigned(255,8));  -- Assign output signal the new pixel value (255)
                else
                    o_data <= std_logic_vector(to_unsigned(Hx+Hy,8)); -- Assign output signal the new pixel value (Hx + Hy)
                end if;
                
            end if;
end MEM;

-- Define procedure to write processing pixel data to output hex file
-- NOTE: write mode is set to APPEND so make sure output file is deleted following
-- each simulation
procedure write_output(
		      signal o_data : in STD_LOGIC_VECTOR(7 downto 0)
		      ) is

file file_pointer : text;
variable line_num : line;
variable byte : character;
variable val : integer;

begin
        file_open(file_pointer,"Cathedral_Output_Edge_Detected.hex",APPEND_MODE);
        hwrite(line_num,o_data);  -- Write the processed pixel byte to the output file
        writeline (file_pointer,line_num);
        file_close(file_pointer);
end write_output;


-- Begin the main process...
begin

-- When the current pixel is incremented, data_count is also incremented and a processed pixel byte is ready to be written to output file
process (data_count) begin
    -- Start writing only after 1st increment
    if(data_count>0) then
        write_output(o_data);  -- Call the write procedure
    end if;
end process;

-- Process to increment the pixel, column, and the row count
process(i_clk, r_w_done)
variable row_new, col_new, pixel_new : integer := 0;
begin
        -- Only execute on rising clock edge, when the image data was completely written to RAM, and the image processing is not complete
		if(rising_edge(i_clk) and r_w_done = '1' and process_done = '0') then
			
			-- When all image data has been processed, the operation is complete
			if(data_count = WIDTH*HEIGHT*3) then
				process_done <= '1';
				
		    -- Increment pixel, col, row count. There are 3 pixels for each column, 768 columns for each row, and 512 rows total.
		    -- The image data is stored in RAM from the bottom row to the top, left column to the right, so the row number will be 
		    -- decremented while the column number will be incremented.
			else
			
			    -- Pixel is indexed from 0 to 2, column from 0 to (WIDTH - 1), and row from 0 to (HEIGHT - 1)
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
		        
		        -- Increment data count
                data_count <= data_count + 1;
                
                -- Calculate the indices for accessing the neighboring pixel values in the RAM array based on the 
                -- current pixel, column, and row values.
                index_0_0 <= WIDTH*3*(HEIGHT-(row-1)-1)+3*(col-1)+pixel-2;
                index_0_1 <= WIDTH*3*(HEIGHT-(row-1)-1)+3*col+pixel-2;
                index_0_2 <= WIDTH*3*(HEIGHT-(row-1)-1)+3*(col+1)+pixel-2;
                index_1_0 <= WIDTH*3*(HEIGHT-row-1)+3*(col-1)+pixel-2;
                index_1_2 <= WIDTH*3*(HEIGHT-row-1)+3*(col+1)+pixel-2;
                index_2_0 <= WIDTH*3*(HEIGHT-(row+1)-1)+3*(col-1)+pixel-2;
                index_2_1 <= WIDTH*3*(HEIGHT-(row+1)-1)+3*col+pixel-2;
                index_2_2 <= WIDTH*3*(HEIGHT-(row+1)-1)+3*(col+1)+pixel-2;
                
                -- Call the image processing algorithm and pass in the RAM array indices for accessing neighboring pixel data. Output of this 
                -- procedure is the processed pixel byte
                MEM(i_clk, o_data, r_w_done, row, col, index_0_0, index_0_1, index_0_2, index_1_0, index_1_2, index_2_0, index_2_1, index_2_2);
			end if;
			
		end if;
end process;
   
end Behavioral;
