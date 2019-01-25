function [AOD,CSI] = compute_AOD(CSI,WLAN_paras)
%% 求AOA
% 相邻天线之间距离 单位：m
antenna_space = (WLAN_paras.speed_light/WLAN_paras.frequency) * WLAN_paras.antenna_space_ofwaveLen(2) * (0:WLAN_paras.num_Tantenna-1);

% 画网格
AOD_grid = WLAN_paras.precison(1):WLAN_paras.precison(1):WLAN_paras.grid_range(1);

AOD = 0;
AOD_energy = -realmax;
for t = 1:length(AOD_grid)
    AOD_steering_vector = exp((-1i * 2 * pi * antenna_space * cos(deg2rad(AOD_grid(t))) * WLAN_paras.frequency / WLAN_paras.speed_light));
    now_energy = sum(abs(CSI.' * AOD_steering_vector').^2);
    if now_energy > AOD_energy
        AOD = AOD_grid(t);
        AOD_energy = now_energy;
    end
end

AOD_steering_vector = exp((-1i * 2*pi * antenna_space * cos(deg2rad(AOD)) * WLAN_paras.frequency / WLAN_paras.speed_light));
CSI = (CSI.' * AOD_steering_vector').';

end