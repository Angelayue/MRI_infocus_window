clear;
%% load images
%read mag img
im99=imread('mag_freq1_imag99.jpg');
im100=imread('mag_freq1_imag100.jpg');
im101=imread('mag_freq1_imag101.jpg');
im355=imread('mag_freq2_imag355.jpg');
im356=imread('mag_freq2_imag356.jpg');
im357=imread('mag_freq2_imag357.jpg');
im611=imread('mag_freq3_imag611.jpg');
im612=imread('mag_freq3_imag612.jpg');
im613=imread('mag_freq3_imag613.jpg');
im867=imread('mag_freq4_imag867.jpg');
im868=imread('mag_freq4_imag868.jpg');
im869=imread('mag_freq4_imag869.jpg');
im1123=imread('mag_freq5_imag1123.jpg');
im1124=imread('mag_freq5_imag1124.jpg');
im1125=imread('mag_freq5_imag1125.jpg');
im1379=imread('mag_freq6_imag1379.jpg');
im1380=imread('mag_freq6_imag1380.jpg');
im1381=imread('mag_freq6_imag1381.jpg');
im1635=imread('mag_freq7_imag1635.jpg');
im1636=imread('mag_freq7_imag1636.jpg');
im1637=imread('mag_freq7_imag1637.jpg');
im1891=imread('mag_freq8_imag1891.jpg');
im1892=imread('mag_freq8_imag1892.jpg');
im1893=imread('mag_freq8_imag1893.jpg');
im2147=imread('mag_freq9_imag2147.jpg');
im2148=imread('mag_freq9_imag2148.jpg');
im2149=imread('mag_freq9_imag2149.jpg');
%% 3d Matrix
matrix_3dm(:,:,1)=(im100);
matrix_3dm(:,:,2)=(im356);
matrix_3dm(:,:,3)=(im612);
matrix_3dm(:,:,4)=(im868);
matrix_3dm(:,:,5)=(im1124);
matrix_3dm(:,:,6)=(im1380);
matrix_3dm(:,:,7)=(im1636);
matrix_3dm(:,:,8)=(im1892);
matrix_3dm(:,:,9)=(im2148);
%% 4d Matrix Note: the calculate one should the second
matrix_4dm(:,:,1,1) = (im99);
matrix_4dm(:,:,2,1) = (im100);
matrix_4dm(:,:,3,1) = (im101);
matrix_4dm(:,:,1,2) = (im355);
matrix_4dm(:,:,2,2) = (im356);
matrix_4dm(:,:,3,2) = (im357);
matrix_4dm(:,:,1,3) = (im611);
matrix_4dm(:,:,2,3) = (im612);
matrix_4dm(:,:,3,3) = (im613);
matrix_4dm(:,:,1,4) = (im867);
matrix_4dm(:,:,2,4) = (im868);
matrix_4dm(:,:,3,4) = (im869);
matrix_4dm(:,:,1,5) = (im1123);
matrix_4dm(:,:,2,5) = (im1124);
matrix_4dm(:,:,3,5) = (im1125);
matrix_4dm(:,:,1,6) = (im1379);
matrix_4dm(:,:,2,6) = (im1380);
matrix_4dm(:,:,3,6) = (im1381);
matrix_4dm(:,:,1,7) = (im1635);
matrix_4dm(:,:,2,7) = (im1636);
matrix_4dm(:,:,3,7) = (im1637);
matrix_4dm(:,:,1,8) = (im1891);
matrix_4dm(:,:,2,8) = (im1892);
matrix_4dm(:,:,3,8) = (im1893);
matrix_4dm(:,:,1,9) = (im2147);
matrix_4dm(:,:,2,9) = (im2148);
matrix_4dm(:,:,3,9) = (im2149);
%% 4d cube picking up
std_matrix_4d = zeros(256, 256, 9);
Image_index_4d = ones(256, 256);
Image_std_4d = zeros(256, 256);
for i = 1: 256
    for j = 1:256
        for k = 1:9
            std_matrix_4d(i, j, k) = std2(matrix_4dm(max(1,i-1):min(i+1,256), max(1,j-1):min(j+1,256),1:3,k));
        end
    end
end
%% change sliding window to standard method
% std_matrix_3d = zeros(256, 256, 9);
% Image_index_3d = ones(256, 256);
% Image_std_3d = zeros(256, 256);
% for i = 1:256
%     for j = 1:256
%         for k = 1:9
%             std_matrix_3d(i, j, k) = std2(matrix_3dm(max(1, i-10): min(i+10, 256),max(1, j-10): min(j+10, 256),k));
%         end
%     end
% end
%% find the max std for 4d
[Image_std_4d,Image_index_4d] = max(std_matrix_4d,[],3);
%% find the max std for 3d
% [Image_std_3d,Image_index_3d] = max(std_matrix_3d,[],3);
%% find the smoothed index for 3d
% [old_std, old_sharpest] = max(std_matrix_3d(1,1,:),[],3);
% for i = 1:256
%     for j = 1:256
%         [new_std, new_sharpest] = max(std_matrix_3d(i,j,:),[],3);
%         Image_index_3d(i,j) = round((old_std*old_sharpest + new_std*new_sharpest)/(old_std + new_std));
%     end
% end
% Image_3d = matrix_3dm(reshape([1:256*256],[256,256])+256*256*(Image_index_3d-1));
% figure,imshow(uint8(Image_3d))
%% find the smoothed index for 4d
[old_std, old_sharpest] = max(std_matrix_4d(1,1,:),[],3);
for i = 1:256
    for j = 1:256
        [new_std, new_sharpest] = max(std_matrix_4d(i,j,:),[],3);
        Image_index_4d(i,j) = round((old_std*old_sharpest + new_std*new_sharpest)/(old_std + new_std));
    end
end
Image_4d = matrix_4dm(reshape([1:256*256],[256,256])+256*256*(Image_index_4d-1));
figure, imshow(uint8(Image_4d))