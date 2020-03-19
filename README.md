# University of Pittsburgh - ECE2195 Final Project
This repo is the FPGA implementation of an edge detection image processor that utilizes the Sobel Algorithm. The first project contains VHDL code and a testbench for performing a simulation of the image processing capabilities. The second project is the synthesizable version targeted for the Xilinx Artix-7 development board. The synthesizable version utilizes asynchronous serial communication (UART) I/O to receive raw image data from a PC/Mac and then send back the processed image.

The following instructions provide details on how to run the simulation project code in Vivado to produce an edge-detected output image from an input image. The code is currently configured to process only 768x512 sized 24-bit-per-pixel images.

1. Generate a newline-delimited hex file from an input image. The MatLab script Create_Hex_File.m can be used to create the hex file “Cathedral_Input.hex” from the input image “Cathedral_Input.bmp”.

2. Configure the simulation runtime in Vivado to be 20ms. This time is required for the complete processing of all data elements of the image.

3. Run the simulation. The code is configured to read in the input hex file from the same directory in which the top level source file resides. 

4. Once the simulation has concluded, the output file “Cathedral_Output_Edge_Detected.hex” will be written to the location ..\Simulation_Edge_Detection.sim\sim_1\behav\xsim. 

5. To post-process the output hex file into produce a viewable image, run the Image Post Processing application. Specify the input hex file name and location (i.e. “C:\Users\Desktop\Cathedral_Output_Edge_Detected.hex”), the image width to be 768, the height to be 512, and the output jpeg file name and location (i.e. “C:\Users\Desktop\Cathedral_Output_Edge_Detected.jpeg”).

6. The edge-detected image will be created and saved to the specified location.


Note: If the simulation is re-run, the output hex file in the \xsim folder must be deleted because the write functionality is set to append mode in the source code.


# Input Image

![](/images/Cathedral_Input.bmp)

# Output Image

![](/images/Cathedral_Output_Edge_Detected.jpeg)
