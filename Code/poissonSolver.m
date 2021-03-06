function [I_target, sum_fstar] = poissonSolver(I_source, I_target, bw_target, source_index, target_index)

bw_source_inv = I_source;
bw_source_inv(source_index) = 0;
bw_source_inv(bw_source_inv > 0) = 1;

bw_target_inv = 1 - bw_target;
bw_target_inv(bw_target_inv < 0) = 0;

%% building b
mixing = 0;
v_val = zeros(size(target_index));
for i_index = 1:numel(target_index)
    idx_target = target_index(i_index);
    [x_target, y_target] = ind2sub(size(I_target), idx_target);
    
    idx_source = source_index(i_index);
    [x_source, y_source] = ind2sub(size(I_source), idx_source);
    
    sum_grad = 0;
    if (abs(I_target(x_target, y_target)-I_target(x_target-1, y_target))*mixing > abs(I_source(x_source, y_source)-I_source(x_source-1, y_source)))
        sum_grad = sum_grad + I_target(x_target, y_target) - I_target(x_target-1, y_target);
    else
        sum_grad = sum_grad + I_source(x_source, y_source) - I_source(x_source-1, y_source);
    end
    if (abs(I_target(x_target, y_target)-I_target(x_target, y_target-1))*mixing > abs(I_source(x_source, y_source)-I_source(x_source, y_source-1)))
        sum_grad = sum_grad + I_target(x_target, y_target)-I_target(x_target, y_target-1);
    else
        sum_grad = sum_grad + I_source(x_source, y_source)-I_source(x_source, y_source-1);
    end
    if (abs(I_target(x_target, y_target)-I_target(x_target+1, y_target))*mixing > abs(I_source(x_source, y_source)-I_source(x_source+1, y_source)))
        sum_grad = sum_grad + I_target(x_target, y_target)-I_target(x_target+1, y_target);
    else
        sum_grad = sum_grad + I_source(x_source, y_source)-I_source(x_source+1, y_source);
    end
    if (abs(I_target(x_target, y_target)-I_target(x_target, y_target+1))*mixing > abs(I_source(x_source, y_source)-I_source(x_source, y_source+1)))
        sum_grad = sum_grad + I_target(x_target, y_target)-I_target(x_target, y_target+1);
    else
        sum_grad = sum_grad + I_source(x_source, y_source)-I_source(x_source, y_source+1);
    end
    v_val(i_index) = sum_grad;
end

% sum fstar
fstar = I_target - bw_target;
fstar(fstar < 0) = 0;


filter = [0 1 0; 1 0 1; 0 1 0];
sum_fstar = imfilter(fstar, filter, 'replicate');
fstar_val = sum_fstar(target_index);

b = v_val + fstar_val;

%% building A
% Neighbours
filterN = [0 1 0; 1 0 1; 0 1 0];
neighbours = imfilter(bw_target, filterN, 'replicate');
N = neighbours(target_index);

dim = size(source_index, 1);
A = sparse(dim, dim);
for i_index = 1:numel(target_index)
    idx_target = target_index(i_index);
    [x_target, y_target] = ind2sub(size(I_target), idx_target);
    if(bw_target(x_target-1, y_target) == 1)
        j_index = target_index == sub2ind(size(I_target), x_target-1, y_target);
        A(i_index, j_index) = -1;
    end
    if(bw_target(x_target, y_target-1) == 1)
        j_index = target_index == sub2ind(size(I_target), x_target, y_target-1);
        A(i_index, j_index) = -1;
    end
    if(bw_target(x_target+1, y_target) == 1)
        j_index = target_index == sub2ind(size(I_target), x_target+1, y_target);
        A(i_index, j_index) = -1;
    end
    if(bw_target(x_target, y_target+1) == 1)
        j_index = target_index == sub2ind(size(I_target), x_target, y_target+1);
        A(i_index, j_index) = -1;
    end
end

A = A + diag(sparse(ones(1,dim)*4));
x_target = sparse(A)\b;

x_target(x_target>1)
x_target(x_target>1) = 1;

I_target(target_index) = x_target;