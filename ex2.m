I = double(rgb2gray(imread('tom_hanks.jpg')))/255;

% region specification
[bw, xi, yi] = roipoly(I);
bwi = 1 - bw;

f = I - bwi;
f(f < 0) = 0;
% bulding xima
[f_row, f_col, f_val] = find(f);

%% building b
fstar = I-bw;
fstar(fstar < 0) = 0;

fstar_p = padarray(fstar, [1,1], 'symmetric');

% 4 neighborhood
filter = [0 1 0; 1 0 1; 0 1 0];
sum_fstar = imfilter(fstar, filter, 'replicate');
sum_fstar_max = max(max(sum_fstar));
nsum_fstar = sum_fstar/sum_fstar_max;

% determining the pixels corresponding to the border.
% all the pixel at the order have a non zero value
% Let's get them.

h = nsum_fstar - bwi;
h(h < 0) = 0;
h = h * sum_fstar_max;

[fstar_row, fstar_col, fstar_val] = find(h+bw);
% normalize back
fstar_val = fstar_val - 1;
b = fstar_val;

% guidance field v_pq = g_p - g_q
% I_p = padarray(I, [1,1], 'symmetric');
% diffI_t = I_p(2:end-1, 2:end-1) - I_p(2:end-1, 1:end-2);
% diffI_r = I_p(2:end-1, 2:end-1) - I_p(3:end, 2:end-1);
% diffI_b = I_p(2:end-1, 2:end-1) - I_p(2:end-1, 3:end);
% diffI_l = I_p(2:end-1, 2:end-1) - I_p(1:end-2, 2:end-1);
% 
% sum_v_neighbours = diffI_t + diffI_r + diffI_b + diffI_l;
filter = [0 -1 0; -1 4 -1; 0 -1 0];
sum_v_neighbours = imfilter(double(I), filter, 'replicate');

% extract domain
h3 = sum_v_neighbours - bwi;
h3(h3 < 0) = 0;

[v_row, v_col, v_val] = find(h3+bw);
v_val = v_val - 1;
% b = b + v_val;


%% COMPUTING A
bwp = padarray(bw, [1,1], 'symmetric');
sum_N = bwp(2:end-1,3:end) + bwp(3:end, 2:end-1) + ...
        bwp(1:end-2, 2:end-1) + bwp(2:end-1, 1:end-2);
N_max = max(max(sum_N));
sum_N = sum_N/N_max;
h2 = (sum_N - bwi)*N_max;
h2(h2 < 0) = 0;
[N_row, N_col, N_val] = find(h2);

% Ugly for loop for a's
dim = size(f_col, 1);
A = zeros(dim);
[w, l, c] = size(I);

coor = [f_row, f_col];

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
linindx = sub2ind(size(I), f_row, f_col);
x = sparse(A)\b;
I(linindx) = x;

imagesc(I)
axis image



