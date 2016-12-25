I = double(rgb2gray(imread('tom_hanks.jpg')))/255;

% region specification
[bw, xi, yi] = roipoly(I);
bwi = 1 - bw;

f = I - bwi;
f(f < 0) = 0;
% bulding xima
[bw_row, bw_col, ~] = find(bw);
linindx = sub2ind(size(I), bw_row, bw_col);

%% building b

% guidance field v_pq = g_p - g_q
filter = [0 -1 0; -1 4 -1; 0 -1 0];
sum_v_neighbours = imfilter(double(I), filter, 'replicate');
% extract domain
h3 = sum_v_neighbours - bwi*4;
h3(h3 < 0) = 0;

[v_row, v_col, v_val] = find(h3+bw);
v_val = v_val - 1;

linindx = sub2ind(size(I), v_row, v_col);
I(linindx) = v_val;


fstar = I - bw;
fstar(fstar < 0) = 0;

% 4 neighborhood
filter = [0 1 0; 1 0 1; 0 1 0];
sum_fstar = imfilter(fstar, filter, 'replicate');

% determining the pixels corresponding to the border.
% all the pixel at the order have a non zero value
% Let's get them.
h = sum_fstar - bwi*4;
h(h < 0) = 0;
[fstar_row, fstar_col, fstar_val] = find(h+bw);
% normalize back
fstar_val = fstar_val - 1;

b = fstar_val;


% b = fstar_val + v_val;


%% COMPUTING A
bwp = padarray(bw, [1,1], 'symmetric');
sum_N = bwp(2:end-1,3:end) + bwp(3:end, 2:end-1) + ...
        bwp(1:end-2, 2:end-1) + bwp(2:end-1, 1:end-2);
N_max = max(max(sum_N));
sum_N = sum_N/N_max;
h2 = (sum_N - bwi)*N_max;
h2(h2 < 0) = 0;
[N_row, N_col, N_val] = find(h2);

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
% A = A + diag(N_val);
linindx = sub2ind(size(I), bw_row, bw_col);
x = sparse(A)\b;
I(linindx) = x;

imagesc(I)
axis image



