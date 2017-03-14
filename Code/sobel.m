function nEdgeIm = sobel(image)
    kernel = [-1,0,1;-2,0,2;-1,0,1];
    conv_im_h = imfilter(image, kernel, 'conv');
    conv_im_v = imfilter(image, kernel', 'conv');
    sobel = sqrt(conv_im_h.^2+conv_im_v.^2);
    nEdgeIm = sobel/max(max(sobel));
    nEdgeIm = nEdgeIm > 0.1;