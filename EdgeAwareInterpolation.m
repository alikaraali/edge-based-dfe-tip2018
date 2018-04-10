function denseDMap = EdgeAwareInterpolation(Iref, sparseDMap, edgeMap)


    [H,W] = size(edgeMap);
    I = sparseDMap;
    mask = double(edgeMap); 


    sigma_s = min(H,W)/8;
    % if sigma_s > 70
    %     sigma_s = 70;
    % end

    sigma_r = 3.75;
    niter = 5;

    Iref = RF(Iref, 7, 0.5, niter);

    F_ic    = RF(I.*mask, sigma_s, sigma_r, niter, Iref);
    mask_ic = RF(mask, sigma_s, sigma_r, niter, Iref);
    denseDMap = F_ic./mask_ic;

end
