function denseDMap = EdgeAwareInterpolation(Iref, sparseDMap, edgeMap)
 %%
 %   @input: Iref, Original RGB Image at scale [0,1]
 %           sparseDMap, Estimated sparse defocus blur map  
 %           edgeMap, Estimated reliable edge map
 %   @output: denseDMap, Full defocus blur map
 %   written by Ali Karaali, alixkaraali@gmail.com

    [H,W] = size(edgeMap);
    I = sparseDMap;
    mask = double(edgeMap); 

    sigma_s = min(H,W)/8;

    sigma_r = 3.75;
    niter = 5;

    Iref = RF(Iref, 7, 0.5, niter);

    F_ic    = RF(I.*mask, sigma_s, sigma_r, niter, Iref);
    mask_ic = RF(mask, sigma_s, sigma_r, niter, Iref);
    denseDMap = F_ic./mask_ic;

end
