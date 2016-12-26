close all

I = double(rgb2gray(imread('tom_hanks.jpg')))/255;
% region specification
fig = figure;
[bw, xi, yi] = roipoly(I);
% [xp, yp] = getpts;
bwi = 1 - bw;

[bw_row, bw_col, ~] = find(bw);
maskindex = sub2ind(size(I), bw_row, bw_col);
% 
% diff_x = bw_row(1) - xp;
% diff_y = bw_col(1) - yp;
% clone_region = sub2ind(size(I), bw_row-25, bw_col-25);

%% building b
% guidance field v_pq = g_p - g_q
filter = [0 -1 0; -1 4 -1; 0 -1 0];
sum_v_neighbours = imfilter(double(I), filter, 'replicate');
v_val = sum_v_neighbours(clone_region);
I(maskindex) = v_val;

% boundary pixels
fstar = I - bw;
fstar(fstar < 0) = 0;
filter = [0 1 0; 1 0 1; 0 1 0];
sum_fstar_boundary = imfilter(fstar, filter, 'replicate');
fstar_val_boundary = sum_fstar_boundary(maskindex);

b = v_val + fstar_val_boundary;


%% COMPUTING A
% Ugly for loop for adjacency
dim = size(bw_col, 1);
A = zeros(dim);
[w, l, c] = size(I);

coor = [bw_row, bw_col];

% THIS IS WRONG
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

A = A + diag(ones(1,dim)*4);
maskindex = sub2ind(size(I), bw_row, bw_col);
x = sparse(A)\b;
I(maskindex) = x;

imagesc(I)
axis image
