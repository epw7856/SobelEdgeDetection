% This MatLab script processes a bitmap image into a hex file
% for use in the VHDL Sobel Edge Detection simulation.
%
% Author: Eric Walker

% Read in the 24-bit BMP image (RGB888 format)
b=imread('Cathedral_Input.bmp'); 

% The image is processed from the last row to the first
k=1;
for i=512:-1:1 
	for j=1:768
		a(k)=b(i,j,1);
		a(k+1)=b(i,j,2);
		a(k+2)=b(i,j,3);
		k=k+3;
	end
end

% Save the output hex file
fid = fopen('Cathedral_Input.hex', 'wt');
fprintf(fid, '%x\n', a );
disp('Hex file successfully created.');disp(' ');
fclose(fid);