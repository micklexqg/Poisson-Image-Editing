function [I_target, sum_fstar] = poissonSolver_selection(I_source, I_target, bw_target, source_index, target_index)

% source_index = target_index when doing selection editing
% I_source = I_target when doing selection editing
bw_source_inv = I_source;
bw_source_inv(source_index) = 0;
bw_source_inv(bw_source_inv > 0) = 1;

bw_target_inv = 1 - bw_target;
bw_target_inv(bw_target_inv < 0) = 0;

%% building b
% guidance field v_pq = g_p - g_q
I_source_bw = I_source - bw_source_inv;
I_source_bw(I_source_bw < 0) = 0;
edgeMap = sobel(I_source);
I_source_bw = I_source_bw.*edgeMap;
I_source_pad = padarray(I_source_bw, [1, 1], 'replicate');
v_val_source = zeros(size(source_index));
counts = zeros(1, sum(sum(bw_target)));
for i_index = 1:numel(source_index)
    idx = source_index(i_index);
    [x, y] = ind2sub(size(I_source_bw), idx);
    x = x+1;
    y = y+1;
    sum_grad = 0;
    if (I_source_pad(x, y) ~= 0)
        if (I_source_pad(x-1, y) ~= 0)
            sum_grad = sum_grad + I_source_pad(x,y) - I_source_pad(x-1, y);
            counts(i_index) = counts(i_index) + 1;
        end
        if (I_source_pad(x, y-1) ~= 0)
            sum_grad = sum_grad + I_source_pad(x,y) - I_source_pad(x, y-1);
            counts(i_index) = counts(i_index) + 1;
        end
        if (I_source_pad(x+1, y) ~= 0)
            sum_grad = sum_grad + I_source_pad(x,y) - I_source_pad(x+1, y);
            counts(i_index) = counts(i_index) + 1;
        end
        if (I_source_pad(x, y+1) ~= 0)
            sum_grad = sum_grad + I_source_pad(x,y) - I_source_pad(x, y+1);
            counts(i_index) = counts(i_index) + 1;
        end
    end
   
    v_val_source(i_index) = sum_grad;
end

% not mixing the gradients
v_val = v_val_source;

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
A = sparse(dim,dim);
for i_index = 1:numel(target_index)
    idx = target_index(i_index);
    [x, y] = ind2sub(size(I_target), idx);
    if(bw_target(x-1, y) == 1)
        j_index = target_index == sub2ind(size(I_target), x-1, y);
        A(i_index, j_index) = -1;
    end
    if(bw_target(x, y-1) == 1)
        j_index = target_index == sub2ind(size(I_target), x, y-1);
        A(i_index, j_index) = -1;
    end
    if(bw_target(x+1, y) == 1)
        j_index = target_index == sub2ind(size(I_target), x+1, y);
        A(i_index, j_index) = -1;
    end
    if(bw_target(x, y+1) == 1)
        j_index = target_index == sub2ind(size(I_target), x, y+1);
        A(i_index, j_index) = -1;
    end
end

% how can this work?
A = A + diag(sparse(ones(1,dim)*4));

% why doesn't this work?
% A = A + diag(N);

% and this not?
x = sparse(A)\b;
% x(x>1)

I_target(target_index) = x;