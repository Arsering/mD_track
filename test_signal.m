path_info_input = [50,50;...
    50,50;...
    17,26]; % the first row is AOA,the second row is AOD,the third row is TOF
SNR = 0;
has_noise = 1;
num_samples = 1;
correlation_coefficient = 0.99;
format longE
path_info_output = simulation_environment(path_info_input,SNR,has_noise,num_samples,correlation_coefficient);

