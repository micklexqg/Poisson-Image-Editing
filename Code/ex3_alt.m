close all;
clear workspace;

I_target = double(imread('birds2.jpg'))/255;
I_source = double(imread('birds.jpg'))/255;


I_target_r = I_target(:,:,1);
I_target_g = I_target(:,:,2);
I_target_b = I_target(:,:,3);

I_source_r = I_source(:,:,1);
I_source_g = I_source(:,:,2);
I_source_b = I_source(:,:,3);

% region specification
[bw_source, xi_source, yi_source] = roipoly(I_source);
[bw_row, bw_col, ~] = find(bw_source);

figure
imagesc(I_target)
[x_target, y_target] = getpts();

diffx = round(y_target) - bw_row(1);
diffy = round(x_target) - bw_col(1);

xi_target = xi_source + diffy;
yi_target = yi_source + diffx;

source_index = sub2ind(size(I_source_r), bw_row, bw_col);
target_index = sub2ind(size(I_target_r), bw_row + diffx, bw_col + diffy);
bw_target = zeros(size(I_target_r));
bw_target(target_index) = 1;

[I_r, sum_fstar_r] = poissonSolver(I_source_r, I_target_r, bw_target, source_index, target_index);
[I_g, sum_fstar_g] = poissonSolver(I_source_g, I_target_g, bw_target, source_index, target_index);
[I_b, sum_fstar_b] = poissonSolver(I_source_b, I_target_b, bw_target, source_index, target_index);

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
plot(xi_target, yi_target)
title('Target image')