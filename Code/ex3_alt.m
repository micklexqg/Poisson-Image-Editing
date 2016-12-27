I = double(rgb2gray(imread('tom_hanks.jpg')))/255;

% region specification
[bw, xi, yi] = roipoly(I);
bwi = 1 - bw;

f = I - bwi;
f(f < 0) = 0;
[bw_row, bw_col, ~] = find(bw);
target_index = sub2ind(size(I), bw_row, bw_col);
source_index = sub2ind(size(I), bw_row-50, bw_col-50);
I = poissonSolver(I, I, bw, source_index, target_index);
imagesc(I)
axis image
