close all;
clear workspace;

I_target = double(rgb2gray(imread('birds2.jpg')))/255;
I_source = double(rgb2gray(imread('balloon_girl.jpg')))/255;

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

source_index = sub2ind(size(I_source), bw_row, bw_col);
target_index = sub2ind(size(I_target), bw_row+diffx, bw_col+diffy);
bw_target = zeros(size(I_target));
bw_target(target_index) = 1;

[I, sum_fstar] = poissonSolver(I_source, I_target, bw_target, source_index, target_index);
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