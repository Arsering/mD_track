function [TOF,CSI] = compute_TOF(CSI,WLAN_paras)
% »­Íø¸ñ
TOF_grid = WLAN_paras.precison(2):WLAN_paras.precison(2):WLAN_paras.grid_range(2);

TOF = 0;
TOF_energy = -realmax;
for t = 1:length(TOF_grid)
    steering_vector = exp(-1i * 2*pi * (0:WLAN_paras.num_subcarrier-1) * WLAN_paras.frequency_space * TOF_grid(t) / WLAN_paras.speed_light);
    now_energy = sum(abs(CSI * steering_vector').^2);
    if now_energy > TOF_energy
        TOF = TOF_grid(t);
        TOF_energy = now_energy;
    end
end
TOF_steering_vector = exp(-1i * 2*pi * (0:WLAN_paras.num_subcarrier-1) * WLAN_paras.frequency_space * TOF / WLAN_paras.speed_light);
CSI = CSI * TOF_steering_vector';
end