close all

I = double(rgb2gray(imread('tom_hanks.jpg')))/255;
I_orig = I;

% region specification
fig = figure;
[bw, xi, yi] = roipoly(I);
bwi = 1 - bw;

[bw_row, bw_col, ~] = find(bw);
domain_index = sub2ind(size(I), bw_row, bw_col);

%% building b
% boundary pixels
fstar = I - bw;
fstar(fstar < 0) = 0;
filter = [0 1 0; 1 0 1; 0 1 0];
sum_fstar_boundary = imfilter(fstar, filter, 'replicate');
fstar_val_boundary = sum_fstar_boundary(domain_index);

b = fstar_val_boundary;

%% building A
% Ugly for loop for adjacency
dim = size(bw_col, 1);
A = zeros(dim);
[w, l, c] = size(I);

coor = [bw_row, bw_col];

for x = 1:w
    for y = 1:l
        if (bw(x, y) == 1)
            i_index = find(ismember(coor,[x,y],'rows'));
            if(bw(x-1, y) == 1)
                j_index = find(ismember(coor,[x-1, y],'rows'));
                A(i_index, j_index) = -1;
            end
            if(bw(x, y-1) == 1)
                j_index = find(ismember(coor,[x, y-1],'rows'));
                A(i_index, j_index) = -1;
            end
            if(bw(x+1, y) == 1)
                j_index = find(ismember(coor,[x+1, y],'rows'));
                A(i_index, j_index) = -1;
            end
            if(bw(x, y+1) == 1)
                j_index = find(ismember(coor,[x, y+1],'rows'));
                A(i_index, j_index) = -1;
            end
        end
    end
end

%% Solving the LSE
A = A + diag(ones(1,dim)*4);
x = sparse(A)\b;


%% RESULT
I(domain_index) = x;
figure 
subplot(1,2,1)
imagesc(I_orig)
colormap gray;
axis image
title('Original image')
subplot(1,2,2)
imagesc(I)
colormap gray;
axis image
hold on;
plot(xi, yi)
title('Edited image')
