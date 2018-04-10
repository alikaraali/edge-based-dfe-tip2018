
numC = 20;
load map_22.mat;  % ('Non-parametric blur map regression for depth of field extension')
load convertion.mat % ('Non-parametric blur map regression for depth of field extension')
Iuint= imread('image_22.png'); % ('Non-parametric blur map regression for depth of field extension')
Iuint = Iuint(:,1:end-numC,:);
Idouble = im2double(Iuint);


[psf, sparse_psf, reliable_edge_map] = blur_estimate_our(Idouble);
% psf has the blur map that is produced by our method



blurMapGT = blurMap(:,1:end-numC); % from ('Non-parametric blur map regression for depth of field extension' paper)

% Disk to Gaussian kernel conversion since 
% ('Non-parametric blur map regression for depth of field extension' paper)
% uses disk kernel
gauss_psf = zeros(size(blurMapGT));
for k=1:size(blurMapGT,1)
    for j=1:size(blurMapGT,2)
        [~, inda] = min(abs(convertion(:,2) - blurMapGT(k,j))) ;
        gauss_psf(k,j) = convertion(inda,1);
    end
end

f0 = figure; imagesc(gauss_psf); 
 caxis([0.5, 4]); 
 axis off; set(gca,'position',[0 0 1 1],'units','normalized'); 
 set(gcf,'PaperUnits','inches','PaperPosition',[0 0  2.2667 2.4]);

f1 = figure; imagesc(psf); 
 caxis([0.5, 4]); 
 axis off; set(gca,'position',[0 0 1 1],'units','normalized');
 set(gcf,'PaperUnits','inches','PaperPosition',[0 0  2.2667 2.4]);
