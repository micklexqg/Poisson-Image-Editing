I = double(rgb2gray(imread('tom_hanks.jpg')))/255;

% region specification
[bw, xi, yi] = roipoly(I);
bwi = 1 - bw;

f = I - bwi;
f(f < 0) = 0;
[bw_row, bw_col, ~] = find(bw);
target_index = sub2ind(size(I), bw_row, bw_col);
source_index = sub2ind(size(I), bw_row-50, bw_col-50);

%% building b

% guidance field v_pq = g_p - g_q
filter = [0 -1 0; -1 4 -1; 0 -1 0];
sum_v_neighbours = imfilter(I, filter, 'replicate');
v_val = sum_v_neighbours(source_index);

% sum fstar
fstar = I - bw;
fstar(fstar < 0) = 0;
filter = [0 1 0; 1 0 1; 0 1 0];
sum_fstar = imfilter(fstar, filter, 'replicate');
fstar_val = sum_fstar(target_index);

b = v_val + fstar_val;

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
x = sparse(A)\b;
I(target_index) = x;

imagesc(I)
axis image
