%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Gaussian noise and filters
%% Developed by DIAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load filter coefficients from filter_coe.mex
filter_coe=load('filter_coe');
filter1=filter_coe.filter1;
filter2=filter_coe.filter2;
filter3=filter_coe.filter3;

% gaussian white noise
noise_wb=randn(1,500);

% filter1
noise_nb1=conv(noise_wb,filter1);
figure(1);
plot(noise_nb1);

% filter2
noise_nb2=conv(noise_wb,filter2);
figure(2);
plot(noise_nb2);

% filter3
noise_nb3=conv(noise_wb,filter3);
figure(3);
plot(noise_nb3);

% plot white noise
figure(4);
plot(noise_wb);
