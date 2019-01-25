function CSI = simulation_generateCSI(WLAN_paras)

% 相邻天线之间距离 单位：m
Rantenna_space = (WLAN_paras.speed_light/WLAN_paras.frequency) * WLAN_paras.antenna_space_ofwaveLen(1);
Tantenna_space = (WLAN_paras.speed_light/WLAN_paras.frequency) * WLAN_paras.antenna_space_ofwaveLen(2);


% 定义存储CSI值的矩阵
CSI = complex(zeros(WLAN_paras.num_Tantenna,WLAN_paras.num_Rantenna,WLAN_paras.num_subcarrier));

complex_gain = create_complexGain(WLAN_paras);

%计算CSI
for k = 1:size(WLAN_paras.path_info_input,2)
    exp_AOD = exp((-1i * 2*pi * Tantenna_space * (0:(WLAN_paras.num_Tantenna-1)) * cos(deg2rad(WLAN_paras.path_info_input(2,k))) * WLAN_paras.frequency / WLAN_paras.speed_light));
    for t = 1:WLAN_paras.num_Tantenna
        exp_AOA = exp((-1i * 2*pi * Rantenna_space * (0:(WLAN_paras.num_Rantenna-1)) * cos(deg2rad(WLAN_paras.path_info_input(1,k))) * WLAN_paras.frequency / WLAN_paras.speed_light));
        exp_TOF = exp(-1i * 2*pi * (0:(WLAN_paras.num_subcarrier-1)) * WLAN_paras.frequency_space * WLAN_paras.path_info_input(3,k) / WLAN_paras.speed_light);
        CSI(t,:,:) = CSI(t,:,:) + reshape(exp_AOA.' * exp_TOF * exp_AOD(t),1,WLAN_paras.num_Rantenna,WLAN_paras.num_subcarrier) * complex_gain(k,1);
    end
end

if WLAN_paras.has_noise == 1
    CSI = awgn(CSI,WLAN_paras.SNR,'measured');
end

end

%% 生成特定的complex_gain
function complex_gain = create_complexGain(Model_paras)

% 生成初始的协方差矩阵
signalCovMat = 1*eye(size(Model_paras.path_info_input,2));

% 为了简便 我将任意两个不同信源之间的相关系数都置同一个值
for t = 1:size(Model_paras.path_info_input,2)
    for k = 1:size(Model_paras.path_info_input,2)
        if t == k
            continue;
        else
            signalCovMat(t,k) = Model_paras.correlation_coefficient;
        end
    end
end

complex_gain = mvnrnd(zeros(size(Model_paras.path_info_input,2),1),signalCovMat,Model_paras.num_samples).';

% 为了简便才如此 可以修改（无论修改与否，都不影响我们的实验效果）
complex_gain = exp(1i * complex_gain);

end

