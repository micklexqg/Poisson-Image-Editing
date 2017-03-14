close all;
clear workspace;

I_target = double(imread('mona.jpg'))/255;
I_target_r = I_target(:,:,1);
I_target_g = I_target(:,:,2);
I_target_b = I_target(:,:,3);

I_source = double(imread('mona.jpg'))/255;
I_source_r = I_source(:,:,1);
I_source_g = I_source(:,:,2);
I_source_b = I_source(:,:,3);

% specify region in source
[bw_source, xi_source, yi_source] = roipoly(I_source);
[bw_row, bw_col, ~] = find(bw_source);

% shift region from source to target
source_index = sub2ind(size(I_source_r), bw_row, bw_col);
target_index = sub2ind(size(I_target_r), bw_row, bw_col);
bw_target = zeros(size(I_target_r));
bw_target(target_index) = 1;

% solve the poisson for every for each color componente seperately
[I_r, sum_fstar_r] = poissonSolver_selection(I_source_r, I_target_r, bw_target, source_index, target_index);
[I_g, sum_fstar_g] = poissonSolver_selection(I_source_g, I_target_g, bw_target, source_index, target_index);
[I_b, sum_fstar_b] = poissonSolver_selection(I_source_b, I_target_b, bw_target, source_index, target_index);
I = cat(3, I_r, I_g, I_b);

imagesc(I)
axis image

%% RESULT
figure 
subplot(1,2,1)
imagesc(I_source)
hold on;
colormap gray;
axis image
plot(xi_source, yi_source);
title('Source image')

subplot(1,2,2)
imagesc(I)
colormap gray;
axis image
hold on;
title('Target image')