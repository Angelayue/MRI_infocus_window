clear;
%% load images
%read mag img
im100=imread('mag_freq1_imag100.jpg');
im356=imread('mag_freq2_imag356.jpg');
im612=imread('mag_freq3_imag612.jpg');
im868=imread('mag_freq4_imag868.jpg');
im1124=imread('mag_freq5_imag1124.jpg');
im1380=imread('mag_freq6_imag1380.jpg');
im1636=imread('mag_freq7_imag1636.jpg');
im1892=imread('mag_freq8_imag1892.jpg');
im2148=imread('mag_freq9_imag2148.jpg');
%% 3d Matrix
matrix_3dm=(im100);
matrix_3dm(:,:,2)=(im356);
matrix_3dm(:,:,3)=(im612);
matrix_3dm(:,:,4)=(im868);
matrix_3dm(:,:,5)=(im1124);
matrix_3dm(:,:,6)=(im1380);
matrix_3dm(:,:,7)=(im1636);
matrix_3dm(:,:,8)=(im1892);
matrix_3dm(:,:,9)=(im2148);
%% change sliding window to standard method
std_matrix = zeros(256, 256, 9);
Image_index = ones(256, 256);
Image_std = zeros(256, 256);
for i = 1:256
    for j = 1:256
        for k = 1:9
            std_matrix(i, j, k) = std2(matrix_3dm(max(1, i-10): min(i+10, 256),max(1, j-10): min(j+10, 256),k));
        end
    end
end
%% find the max std
% [Image_std,Image_index] = max(std_matrix,[],3);
%% find the smoothed index
[old_std, old_sharpest] = max(std_matrix(1,1,:),[],3);
for i = 1:256
    for j = 1:256
        [new_std, new_sharpest] = max(std_matrix(i,j,:),[],3);
        Image_index(i,j) = round((old_std*old_sharpest + new_std*new_sharpest)/(old_std + new_std));
    end
end
Image = matrix_3dm(reshape([1:256*256],[256,256])+256*256*(Image_index-1));
figure,imshow(uint8(Image))