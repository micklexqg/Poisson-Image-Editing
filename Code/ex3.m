close all;

I_target = double(rgb2gray(imread('birds.jpg')))/255;
I_source = double(rgb2gray(imread('beatles.jpg')))/255;
% region specification
[bw_source, xi_source, yi_source] = roipoly(I_source);
imagesc(I_target)
[x_target, y_target] = getpts();

diffx = 156 - xi_source(1);
diffy = 159 - yi_source(1);

xi_target = xi_source + diffx;
yi_target = yi_source + diffy;

[bw_source_row, bw_source_col, ~] = find(bw_source);
source_index = sub2ind(size(I_source), bw_source_row, bw_source_col);

bw_target_row = bw_source_row + diffy;
bw_target_col = bw_source_col + diffx;
target_index = sub2ind(size(I_target), bw_target_col, bw_target_row);

% create mask for target
bw_target = zeros(size(I_target));
bw_target(target_index) = 1;

%% building b
% guidance field v_pq = g_p - g_q
filter = [0 -1 0; -1 4 -1; 0 -1 0];
sum_v_neighbours = imfilter(I_source, filter, 'replicate');
% extract domain
v_val = sum_v_neighbours(source_index);

% fstar
fstar = I_target - bw_target;
fstar(fstar < 0) = 0;
filter = [0 1 0; 1 0 1; 0 1 0];
sum_fstar = imfilter(fstar, filter, 'replicate');
fstar_val = sum_fstar(target_index);

b = v_val + fstar_val;

%% COMPUTING A
% Ugly for loop for adjacency
dim = size(source_index, 1);
A = zeros(dim);
[w, l, c] = size(I_target);

coor = [bw_target_row, bw_target_col];

% THIS IS WRONG
for x = 1:w
    for y = 1:l
        if (bw_target(x, y) == 1)
            i_index = find(ismember(coor,[x,y],'rows'));
            if(bw_target(x-1, y) == 1)
                j_index = find(ismember(coor,[x-1, y],'rows'));
                A(i_index, j_index) = -1;
            end
            if(bw_target(x, y-1) == 1)
                j_index = find(ismember(coor,[x, y-1],'rows'));
                A(i_index, j_index) = -1;
            end
            if(bw_target(x+1, y) == 1)
                j_index = find(ismember(coor,[x+1, y],'rows'));
                A(i_index, j_index) = -1;
            end
            if(bw_target(x, y+1) == 1)
                j_index = find(ismember(coor,[x, y+1],'rows'));
                A(i_index, j_index) = -1;
            end
        end
    end
end

A = A + diag(ones(1,dim)*4);
% A = A + diag(N_val);
linindx = sub2ind(size(I_target), bw_target_row, bw_target_col);
x = sparse(A)\b;

%% RESULT
I_target(target_index) = x;
figure 
subplot(1,2,1)
imagesc(I_source)
hold on;
colormap gray;
axis image
plot(xi_source, yi_source);
title('Source image')
subplot(1,2,2)
imagesc(I_target)
colormap gray;
axis image
hold on;
plot(xi_target, yi_target)
title('Target image')
