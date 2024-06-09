clear all;


Img_0p27 = load("meas_MID00122_FID64056_cones_1h_we480_te0p96.mat");
TE0p27 = Img_0p27.img_recon2;
Img_1p19 = load("meas_MID00123_FID64057_cones_1h_we480_te4p80.mat");
TE1p19 = Img_1p19.img_recon2;
Img_2p14 = load("meas_MID00124_FID64058_cones_1h_we480_te9p60.mat");
TE2p14 = Img_2p14.img_recon2;
Img_3p08 = load("3p08ms_shank.mat","img_recon2");
TE3p08 = Img_3p08.img_recon2;

TE_times = [0.27, 1.19, 2.14, 3.08]; % Echo Time Array
combinedData = zeros(240,240,240,4);

combinedData(:,:,:,1) = TE0p27(:,:,:);
combinedData(:,:,:,2) = TE1p19(:,:,:);
combinedData(:,:,:,3) = TE2p14(:,:,:);
combinedData(:,:,:,4) = TE3p08(:,:,:);

counter = 0;
%% 
[x, y, z, n] = size(combinedData(:,:,:,:));
T2starMap = zeros(x, y, z);
Squeezed_data = zeros(x,y,z,n);

%% 
for i = 1:x
    for j = 1:y
        for k = 1:z
            
            S =  transpose(squeeze(combinedData(i, j, k, :)));

            if (S(1) > 0.0007)

                initialGuess = [S(1)+2*S(1), 1, 0.0001]; % Replace S0_guess and T2Star_guess with your estimates

                % Lower and upper bounds for the parameters, if known
                lb = [0, 0, 0.0001]; % Example lower bounds: no negative values for S0 and T2*
                ub = [1, 20, 0.1];

                % Perform the fitting
                options = optimoptions('lsqcurvefit', 'Display', 'off'); % Showing iterations; adjust as needed
                [x, resnorm, exitflag, output] = lsqcurvefit(@(x, TE_times) myModel(x, TE_times), initialGuess, TE_times, S, lb, ub, options);

                % x contains the fitted values for S0 and T2*
                fittedS0 = x(1);
                fittedT2Star = x(2); 
                Cstar = x(3);

                T2starMap(i,j,k) = fittedT2Star;

            else
                T2starMap(i,j,k) = 0;

            end      
            
             
        end
    end
    i
end


%% 

%% 

figure
sgtitle('Water Phantom')

subplot(1,3,1)
imshow(axial, [min(axial(:)) max(axial(:))]);
title('Axial View')


subplot(1,3,2)
imshow(sagittal, [min(sagittal(:)) max(sagittal(:))]);

title('Sagittal View')

subplot(1,3,3)
imshow(coronal, [min(coronal(:)) max(coronal(:))]);
title('Coronal View')
%
%% 

axial = T2starMap(:,:,98);
coronal = reshape(T2starMap(:,90,:),[240,240,1]);
sagittal = reshape(T2starMap(150,:,:),[240,240,1]);

imshow(sagittal, [min(sagittal(:)) max(sagittal(:))], Colormap=jet)
%% 
imshow(axial, [min(axial(:)) max(axial(:))], Colormap=jet);
%% 
imshow(coronal, [min(coronal(:)) max(coronal(:))], Colormap = jet);
%% 

axis tight manual % this ensures that getframe() returns a consistent size
filename = 'testAnimated.gif';

colormap jet;
for slc = 1:240
    imagesc(squeeze(T2starMap(:,slc,:)))
    clim([0 5]);
    drawnow;
    pause(0.01)
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if slc == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf, 'DelayTime', 0.1);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append', 'DelayTime', 0.1);
    end
end



%% 
G =  transpose(squeeze(combinedData(100, 21, 40, :)));
% Lower and upper bounds for the parameters, if known
 % Upper bounds: can adjust based on your knowledge of the system

% Perform the fitting
options = optimoptions('lsqcurvefit', 'Display', 'off'); % Showing iterations; adjust as needed
[x, resnorm, ~, exitflag, output] = lsqcurvefit(@(x, TE_times) myModel(x, TE_times), initialGuess, TE_times, S, lb, ub, options);

% x contains the fitted values for S0 and T2*
fittedS0 = x(1);
fittedT2Star = x(2);     

plot(TE_times, S)


axe = imagesc(TE1p19(:,:,78));
clim([0 0.5]);

