function [psf, spsf_filtered, edge_map] = blur_estimate_our(im)
%%
%   @input: im, Colorful RGB image at scale [0,1]
%   @output: psf, Estmated defocus blur map
%            spsf_filtered, Sparse defocus blur map  
%            edge_map, Estimated reliable edge map
% 
%   written by Ali Karaali, alixkaraali@gmail.com
   
    % important parameters
    sigmas = 1:0.5:5;
    std1 = 1;
   
    
    % working on one channel images
    if size(im,3) == 3
        gI_im = rgb2ycbcr(im);
        gI = gI_im(:,:,1).^2.4;
    else
        gI = im;
    end
    
    % Edge detection on multiple scales
    [H,W] = size(gI);
    edges = zeros(H, W, 9);
    k = 1;
    for i1 = 1 : 0.5 : 5
        edges(:,:,k) = edge(gI, 'Canny', [], i1);
        k = k + 1;
    end
    
    et4 = sum(edges(:,:,1:4), 3);
    edge_map = et4 == 4;

    
    ind = find(edge_map ~= 0);
    et = sum(edges, 3);
    
    
    max_blur = 5; 
    pad_size = (2*ceil(2 * max_blur)) + 1;
    % padding for filtering
    padded_gI = padarray(gI, [pad_size pad_size], 'symmetric');
    
    spsf = zeros(H,W);
    sigmamatrix = zeros(H,W);
    
    
    for ii = 1 : length(ind)
        [rowno, colno] = ind2sub([H,W], ind(ii)); % edge point
        % at which scales this edge point appears ?
        ep = reshape(edges(rowno, colno, :), 1, 9);
        
        d = diff(ep);
        b = find(d == -1);
        if ~isempty(b)
            chosen_sigma = b(1);
        else
            chosen_sigma = 9;
        end
        sigmamatrix(ind(ii)) = 0.5*(sigmas(chosen_sigma));
    end
    
    %figure; imagesc(sigmamatrix); colorbar;
      
    %  Estimate blur amount for each edge point
    for jj = 1 : length(ind)
        [rowno, colno] = ind2sub([H,W], ind(jj)); % edge point
        std2 = sigmamatrix(ind(jj)) ;
        
      %%
        sizegaus = (2*ceil(2 * std2))+1;
        rowno_padded = pad_size + rowno;
        colno_padded = pad_size + colno;
        [X2, Y2] = meshgrid(-sizegaus:sizegaus);
        gx1 = g1x(X2, Y2, std1);
        gy1 = g1y(X2, Y2, std1);
        gx2 = g1x(X2, Y2, std2);
        gy2 = g1y(X2, Y2, std2);
        window = padded_gI(rowno_padded-sizegaus:rowno_padded+sizegaus, ...
                           colno_padded-sizegaus:colno_padded+sizegaus);

                                               
        gimx1_edgepoint = sum(sum(window .* gx1));
        gimy1_edgepoint = sum(sum(window .* gy1));           
        gimx2_edgepoint = sum(sum(window .* gx2));
        gimy2_edgepoint = sum(sum(window .* gy2));
        
        edgepoint_mag1 = sqrt(gimx1_edgepoint.^2 + gimy1_edgepoint.^2);
        edgepoint_mag2 = sqrt(gimx2_edgepoint.^2 + gimy2_edgepoint.^2);
        
        R = edgepoint_mag1 ./ edgepoint_mag2;
 
        edge_point_psf = sqrt((R.^2 * std1^2 - std2^2)/ (1 - R.^2));
        spsf(ind(jj)) = edge_point_psf;
        
    end    

    % Get rid of outliers 
    spsf(spsf ~= real(spsf)) = 0;
    spsf(spsf>5) = 5;
    

    % Edge consistency filtering
    cc_edge = bwlabel(edge_map);
    cc_count = max(max(cc_edge)); % connected edge count

    C1 = zeros(H,W) + et;  
    C2 = ones(H,W)  + et;

    gamma = 10;

    spsf_filtered = zeros(H,W);
    range = 1;
    for k = 1 : cc_count
        %fprintf(1, 'loop no : %d\n', k);
        indices = find(cc_edge==k);
        
        cc1 = C1(indices);
        cc2 = C2(indices);
        A = zeros(length(indices), length(indices));
        for i = 1 : length(indices)
            found_leftu = find(indices == indices(i) - H - 1);
            found_up = find(indices == indices(i) - 1);
            found_rightu = find(indices == indices(i) + H - 1);
            found_left = find(indices == indices(i) - H);
            found_right = find(indices== indices(i) + H);
            found_leftd = find(indices == indices(i) - H + 1);
            found_down = find(indices == indices(i) + 1);
            found_rightd = find(indices == indices(i) + H + 1);

            % Finding the existing neighbours
            neighbours = zeros(1,8);
            if ~isempty(found_leftu)
                neighbours(1) = 1;
                A(i, found_leftu) = -2*gamma;
            end
            if ~isempty(found_up)
                neighbours(2) = 1;
                A(i, found_up) = -2*gamma;
            end
            if ~isempty(found_rightu)
                neighbours(3) = 1;
                A(i, found_rightu) = -2*gamma;
            end
            if ~isempty(found_left)
                neighbours(4) = 1;
                A(i, found_left) = -2*gamma;
            end
            if ~isempty(found_right)
                neighbours(5) = 1;
                A(i, found_right) = -2*gamma;
            end
            if ~isempty(found_leftd)
                neighbours(6) = 1;
                A(i, found_leftd) = -2*gamma;
            end
            if ~isempty(found_down)
                neighbours(7) = 1;
                A(i, found_down) = -2*gamma;
            end
            if ~isempty(found_rightd)
                neighbours(8) = 1;
                A(i, found_rightd) = -2*gamma;
            end

            neighbour_count = sum(neighbours,2);
            A(i , i) = neighbour_count*2*gamma +1+cc1(i);
        end

        
        b = spsf(indices) .* cc2;
        range = range + length(indices);
        spsf_filtered(indices) = A \ b;

    end
    % Propagate the blur amount from edge location to whole image
    psf = EdgeAwareInterpolation(im, spsf_filtered, edge_map); 
end
