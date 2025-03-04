clear
clc

[img, ~, t] = imread("flappy2.png");

[height, width, ~] = size(img);

rgba = zeros(height, width, 4); % Preallocate cell array
range = linspace(0, 15, 256);

for i = 1:height
    for j = 1:width
        % Extract RGBA values from the image and transparency mask
        r = img(i, j, 1);
        g = img(i, j, 2);
        b = img(i, j, 3);
        a = t(i, j) ~= 0; % Transparency check

        % Convert each value to 1-bit binary representation as strings
        r_bin = num2str(r);
        g_bin = num2str(g);
        b_bin = num2str(b);
        a_bin = num2str(a);

        % Concatenate binary strings for RGBA values
        rgba(i, j, 1) = round(interp1(0 : 255, range, double(r)));
        rgba(i, j, 2) = round(interp1(0 : 255, range, double(g)));
        rgba(i, j, 3) = round(interp1(0 : 255, range, double(b)));
        rgba(i, j, 4) = a;
    end
end


fileID = fopen('image_data.mif','w');
fprintf(fileID, 'Depth = %d;\n', height * width);
fprintf(fileID, 'Width = %d;\n', 16);
fprintf(fileID, 'Address_radix = hex;\n');
fprintf(fileID, 'Data_radix = bin;\n');
fprintf(fileID, 'Content \n\tBegin\n');

tile = 0;
count = 0;
for i = 1 : height
    for j = 1 : width
       fprintf(fileID, "%02s\t:\t", num2str(dec2hex (count)));
       r = dec2bin(rgba(i,j, 1),4);
       g = dec2bin(rgba(i,j, 2),4);
       b = dec2bin(rgba(i,j, 3),4);
       a = dec2bin(rgba(i,j, 4),4);
       out = [a r g b];
       fprintf(fileID, '%4s;\n', string(out));

       count = count + 1;
    end
end
fprintf(fileID, "End;");
%fprintf(fileID,'%6.2f %12.8f\n',A);
fclose(fileID);