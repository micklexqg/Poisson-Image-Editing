function [I_target, sum_fstar] = poissonSolver(I_source, I_target, bw_target, source_index, target_index)
[bw_row_target, bw_col_target, ~] = find(bw_target);

%% building b
% guidance field v_pq = g_p - g_q
filter = [0 -1 0; -1 4 -1; 0 -1 0];
laplacian_source = imfilter(I_source, filter, 'replicate');
laplacian_target = imfilter(I_target, filter, 'replicate');
v_val_source = laplacian_source(source_index);
v_val_target = laplacian_target(target_index);
v_val = zeros(size(target_index));

for index = 1:size(target_index, 1)
    if abs(v_val_target(index)) > abs(v_val_source(index))
        v_val(index) = v_val_target(index);
    else 
        v_val(index) = v_val_source(index);
    end
end

v_val = v_val_source;

% sum fstar
fstar = I_target - bw_target;
fstar(fstar < 0) = 0;
filter = [0 1 0; 1 0 1; 0 1 0];
sum_fstar = imfilter(fstar, filter, 'replicate');
fstar_val = sum_fstar(target_index);

b = zeros(size(fstar_val));
for index = 1:size(fstar_val, 1)
    if (fstar_val(index) == 0)
        b(index) = v_val(index);
    else
        b(index) = fstar_val(index);
    end
end

b = v_val + fstar_val;

%% building A
dim = size(bw_col_target, 1);
A = zeros(dim);
for i_index = 1:numel(target_index)
    idx = target_index(i_index);
    [X, y] = ind2sub(size(I_target), idx);
    if(bw_target(X-1, y) == 1)
        j_index = target_index == sub2ind(size(I_target), X-1, y);
        A(i_index, j_index) = -1;
    end
    if(bw_target(X, y-1) == 1)
        j_index = target_index == sub2ind(size(I_target), X, y-1);
        A(i_index, j_index) = -1;
    end
    if(bw_target(X+1, y) == 1)
        j_index = target_index == sub2ind(size(I_target), X+1, y);
        A(i_index, j_index) = -1;
    end
    if(bw_target(X, y+1) == 1)
        j_index = target_index == sub2ind(size(I_target), X, y+1);
        A(i_index, j_index) = -1;
    end
end
A = A + diag(ones(1,dim)*4);
% filter = [0 1 0; 1 0 1; 0 1 0];
% n_neighbours = imfilter(double(bw_target), filter, 'replicate');
% N = n_neighbours(target_index);
% A = A + diag(ones(1,dim)*4);
% 
% 
% x0 = mean(fstar_val./N)*ones(size(target_index,1), 1);
% %Solve using conjagant gradient descent
% X = cgs(sparse(A), b, 1e-7, 200, [], [], x0);

X = sparse(A)\b;
if (sum(X > 1) ~= 0) 
    X = X/max(X);
end
I_target(target_index) = X;