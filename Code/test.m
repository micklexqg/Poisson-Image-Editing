figure;
plot(xi_target, yi_target)
bw_target_row = bw_source_row + diffy;
bw_target_col = bw_source_col + diffx;
hold on
plot(bw_target_col, bw_target_row)