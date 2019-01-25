function [AOA,CSI] = compute_AOA(CSI,WLAN_paras)
%% 求AOA
% 相邻天线之间距离 单位：m
antenna_space = (WLAN_paras.speed_light/WLAN_paras.frequency) * WLAN_paras.antenna_space_ofwaveLen(1) * (0:WLAN_paras.num_Rantenna-1);

% 画网格
AOA_grid = WLAN_paras.precison(1):WLAN_paras.precison(1):WLAN_paras.grid_range(1);

AOA = 0;
AOA_energy = -realmax;
for angle = 1:length(AOA_grid)
    now_energy = 0;
    AOA_steering_vector = exp((-1i * 2 * pi * antenna_space * cos(deg2rad(AOA_grid(angle))) * WLAN_paras.frequency / WLAN_paras.speed_light));
    for t = 1:WLAN_paras.num_Tantenna
        now_energy = now_energy + sum(abs(squeeze(CSI(t,:,:)).' * AOA_steering_vector').^2);
    end
    if now_energy > AOA_energy
        AOA = AOA_grid(angle);
        AOA_energy = now_energy;
    end
end

% 更新CSI
AOA_steering_vector = exp((-1i * 2*pi * antenna_space * cos(deg2rad(AOA)) * WLAN_paras.frequency / WLAN_paras.speed_light));
tmp_CSI = CSI;
CSI = complex(zeros(WLAN_paras.num_Tantenna,WLAN_paras.num_subcarrier));
for t = 1:WLAN_paras.num_Tantenna
    CSI(t,:) = (squeeze(tmp_CSI(t,:,:)).' * AOA_steering_vector').';
end

end