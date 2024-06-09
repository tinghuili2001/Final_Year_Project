clear all;

% Load Images

Img_nowe = load("knee_no_we.mat");
TE0pnow = Img_nowe.img_recon2;
Img_0p96 = load("meas_MID00123_FID64057_cones_1h_we480_te4p80.mat");
TE0p96 = Img_0p96.img_recon2;
Img_4p80 = load("meas_MID00122_FID64056_cones_1h_we480_te0p96.mat");
TE4p80 = Img_4p80.img_recon2;
Img_9p60 = load("meas_MID00124_FID64058_cones_1h_we480_te9p60.mat");
TE9p60= Img_9p60.img_recon2;

Img_9p6w0 = load("bottle_400.mat");
TE9p6w0= Img_9p6w0.img_recon2;

Img_9p6w = load("nowe_water.mat");
TE9p6w= Img_9p6w.img_recon2;

TE_times = [0.96, 4.80, 9.60]; % Echo Time Array
combinedData = zeros(240,240,240,3);

combinedData(:,:,:,1) = TE0p96(:,:,:);
combinedData(:,:,:,2) = TE4p80(:,:,:);
combinedData(:,:,:,3) = TE9p60(:,:,:);

[x, y, z, n] = size(combinedData(:,:,:,:));
T2starMap = zeros(x, y, z);
Squeezed_data = zeros(x,y,z,n);


%% 

for i = 1:x
    for j = 1:y
        for k = 1:z
            
            S =  transpose(squeeze(combinedData(i, j, k, :)));

            if (S(1) > 0.0005)

                initialGuess = [S(1), 3, 0]; % Replace S0_guess and T2Star_guess with your estimates

                % Lower and upper bounds for the parameters, if known
                lb = [0, 0,  0]; % Example lower bounds: no negative values for S0 and T2*
                ub = [1, 20, 5];

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
axial = TE0p96(:,:,120);
coronal = reshape(T2starMap(:,150,:),[240,240,1]);
sagittal = reshape(T2starMap(150,:,:),[240,240,1]);

imshow(sagittal, [min(sagittal(:)) max(sagittal(:))/2], Colormap=jet)
%% 

sagittal_r = reshape(TE0p96(160,:,:),[240,240,1]);

imshow(sagittal_r, [min(sagittal_r(:)) max(sagittal_r(:))], Colormap=gray)

%% 

figure

subplot(1,2,1)
imshow(sagittal_r, [min(sagittal_r(:)) max(sagittal_r(:))/2], Colormap=gray)

subplot(1,2,2)
imshow(sagittal, [min(sagittal(:)) max(sagittal(:))], Colormap=jet)

%% 
figure



%% 
figure

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

figure

slicenow = TE0pnow(:,:,120);

slice1 = TE0p96(:,:,120);
slice2 = TE4p80(:,:,120);
slice3 = TE9p60(:,:,120);

subplot(1,2,1)
imshow(slicenow, [min(slice1(:)) max(slice1(:))/2], Colormap=gray)
title("No Water Excitation")

subplot(1,2,2)
imshow(slice1, [min(slice1(:)) max(slice1(:))/2], Colormap=gray)
title("With Water Excitation, TE = 0.96")

sgtitle("Knee slice: 120")

pIXEL = T2starMap(117,110,150);

%% 

imshow(slice2, [min(slice1(:)) max(slice1(:))], Colormap=gray)

%% 

imshow(slice3, [min(slice1(:)) max(slice1(:))], Colormap=gray)
%% 
 
S = transpose(squeeze(combinedData(197,51,160, :)));
initialGuess = [S(1), 3, 0]; % Replace S0_guess and T2Star_guess with your estimates

% Lower and upper bounds for the parameters, if known
lb = [0, 0, 0]; % Example lower bounds: no negative values for S0 and T2*
ub = [1, 20, 0.01]; % Upper bounds: can adjust based on your knowledge of the system

% Perform the fitting
options = optimoptions('lsqcurvefit', 'Display', 'off'); % Showing iterations; adjust as needed
[x, resnorm, ~, exitflag, output] = lsqcurvefit(@(x, TE_times) myModel(x, TE_times), initialGuess, TE_times, S, lb, ub, options);

% x contains the fitted values for S0 and T2*
fittedS0 = x(1);
fittedT2Star = x(2);     

% Calculate fitted values
fittedS = myModel(x, TE_times);

         
          %% 


figure


axial_r = T2starMap(:,:,120);

subplot(1,2,2)
imshow(axial_r, [min(axial_r(:)) max(axial_r(:))/3], Colormap=jet)

subplot(1,2,1)
imshow(axial, [min(axial(:)) max(axial(:))/3], Colormap=gray)

sgtitle("Axial View")
%% 

figure

subplot(1,2,1)
imshow(sagittal_r, [min(sagittal_r(:)) max(sagittal_r(:))], Colormap=gray)

subplot(1,2,2)
imshow(sagittal, [min(sagittal(:)) max(sagittal(:))], Colormap=jet)


sgtitle("Sagittal View")


%% 

figure;


plot(TE_times, S, 'bo', 'MarkerFaceColor', 'b'); % Original data
hold on;
plot(TE_times, fittedS, '*-', 'LineWidth', 2); % Fitted model
legend('Data', 'Fitted Model');
xlabel('Time (ms)');
ylabel('Signal Intensity');
title('T2* Relaxation Fit');
grid on;

          
%% 

figure

coronal = reshape(TE0p96(:,120,:),[240,240,1]);

coronal_r = reshape(T2starMap(:,120,:),[240,240,1]);



subplot(3,2,1)
imshow(coronal, [min(coronal(:)) max(coronal(:))], Colormap=gray)


title("Slice = 120, Coronal View")

cb = colorbar(); 
ylabel(cb,'Magnitude','FontSize',10,'Rotation',270)


subplot(3,2,2)
imshow(coronal_r, [min(coronal_r(:)) max(coronal_r(:))], Colormap=jet)

cb = colorbar(); 

ylabel(cb,'Milliseconds (ms)','FontSize',10,'Rotation',270)

title("T2* Map, Coronal View")


subplot(3,2,3)
imshow(sagittal_r, [min(sagittal_r(:)) max(sagittal_r(:))], Colormap=gray)

title("Slice = 165, Sagittal View")
cb = colorbar(); 
ylabel(cb,'Magnitude','FontSize',10,'Rotation',270)

subplot(3,2,4)
imshow(sagittal, [min(sagittal(:)) max(sagittal(:))], Colormap=jet)
title("T2* Map, Sagittal View")

cb = colorbar(); 
ylabel(cb,'Milliseconds (ms)','FontSize',10,'Rotation',270)


subplot(3,2,5)
imshow(axial, [min(axial(:)) max(axial(:))], Colormap=gray)
title("Slice = 120, Axial View")

cb = colorbar(); 
ylabel(cb,'Magnitude','FontSize',10,'Rotation',270)


subplot(3,2,6)

imshow(axial_r, [min(axial_r(:)) max(axial_r(:))], Colormap=jet)
cb = colorbar(); 
ylabel(cb,'Milliseconds (ms)','FontSize',10,'Rotation',270)
title("T2* Map, Axial View")


sgtitle("T2* Maps for Knee Scans")

       


%% 

mean1 = mean(TE0p96, "all");


mean2 = mean(TE4p80, "all");

mean3 = mean(t, "all");

%% 

figure

coronal_ww = reshape(TE9p6w(:,120,:),[240,240,1]);

coronal_we = reshape(TE9p6w0(:,120,:),[240,240,1]);

i = TE9p6w(:,:,120);

subplot(1,2,2)
ir = imrotate(i, 270);
imshow(ir, [min(TE9p6w(:)) max(TE9p6w(:))/3], Colormap=gray)
title("With Water Excitation, TE = 0.96")

j = TE9p6w0(:,:,120);

subplot(1,2,1)
jr = imrotate(j, 270);
imshow(jr, [min(TE9p6w0(:)) max(TE9p6w0(:))/3], Colormap=gray)

title("No Water Excitation")



sgtitle("Bottle, Slice = 180")

%% 





