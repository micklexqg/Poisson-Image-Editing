function [I_target] = poissonSolver(I_source, I_target, bw_target, source_index, target_index); 
[bw_row_target, bw_col_target, ~] = find(bw_target);

%% building b
% guidance field v_pq = g_p - g_q
filter = [0 -1 0; -1 4 -1; 0 -1 0];
sum_v_neighbours = imfilter(I_source, filter, 'replicate');
v_val = sum_v_neighbours(source_index);

% sum fstar
fstar = I_target - bw_target;
fstar(fstar < 0) = 0;
filter = [0 1 0; 1 0 1; 0 1 0];
sum_fstar = imfilter(fstar, filter, 'replicate');
fstar_val = sum_fstar(target_index);

b = v_val + fstar_val;

%% building A
% Ugly for loop for adjacency
dim = size(bw_col_target, 1);
A = zeros(dim);
[w, l, c] = size(I_target);

coor = [bw_row_target, bw_col_target];

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
x = sparse(A)\b;
I_target(target_index) = x;