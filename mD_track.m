function path_info_output = mD_track(CSI,WLAN_paras,num_path)

tmp_CSI = CSI;
resdual_CSI = CSI;
path_info_output = zeros(3,num_path);
complex_attenuation = complex(1,num_path);
% initial estimation
for p = 1:num_path   
    tmp_CSI = resdual_CSI;
    % compute the AOA AOD TOF of the next path
    [path_info_output(1,p),tmp_CSI] = compute_AOA(tmp_CSI,WLAN_paras);
    [path_info_output(2,p),tmp_CSI] = compute_AOD(tmp_CSI,WLAN_paras);
    [path_info_output(3,p),tmp_CSI] = compute_TOF(tmp_CSI,WLAN_paras);
    complex_attenuation(p) = tmp_CSI / (WLAN_paras.num_Tantenna * WLAN_paras.num_Rantenna * WLAN_paras.num_subcarrier); 
    % calculate the CSI for one specific path
    onePath_CSI = compute_CSI(WLAN_paras,path_info_output(:,p)) * complex_attenuation(p);
    
    % delete the CSI of this path from the residual signal
    resdual_CSI = resdual_CSI - onePath_CSI;
end

noise_est = resdual_CSI;
path_info_output

stop_mark = zeros(1,num_path);
stop_count = 0;
% iterative path parameter refinement
while stop_count < num_path
    for p = 1:num_path
        if stop_mark(p) == 1
            continue;
        end
        
        one_path_info = path_info_output(:,p);
        onePath_CSI = compute_CSI(WLAN_paras,path_info_output(:,p)) * complex_attenuation(p);
        resdual_CSI = noise_est + onePath_CSI;
        tmp_CSI = resdual_CSI;
        [path_info_output(1,p),tmp_CSI] = compute_AOA(tmp_CSI,WLAN_paras);
        [path_info_output(2,p),tmp_CSI] = compute_AOD(tmp_CSI,WLAN_paras);
        [path_info_output(3,p),tmp_CSI] = compute_TOF(tmp_CSI,WLAN_paras);
        complex_attenuation(p) = tmp_CSI / (WLAN_paras.num_Tantenna * WLAN_paras.num_Rantenna * WLAN_paras.num_subcarrier); 

        % if AOA and TOF of this path have little change in this iteration,
        % they won't be recomputed in the next iteration
        if abs(one_path_info - path_info_output(:,p)) <= WLAN_paras.threshold
            stop_mark(p) = 1;
            stop_count = stop_count + 1;
        end
        
        % update this noise
        noise_est = resdual_CSI - compute_CSI(WLAN_paras,path_info_output(:,p)) * complex_attenuation(p);        
    end
path_info_output
end


end

%% compute CSI for one path
function CSI = compute_CSI(WLAN_paras,path_info)
% 定义存储CSI值的矩阵
CSI = complex(zeros(WLAN_paras.num_Tantenna,WLAN_paras.num_Rantenna,WLAN_paras.num_subcarrier));

% 相邻天线之间距离 单位：m
Rantenna_space = (WLAN_paras.speed_light/WLAN_paras.frequency) * WLAN_paras.antenna_space_ofwaveLen(1) * (0:(WLAN_paras.num_Rantenna-1));
Tantenna_space = (WLAN_paras.speed_light/WLAN_paras.frequency) * WLAN_paras.antenna_space_ofwaveLen(2) * (0:(WLAN_paras.num_Tantenna-1));

exp_AOD = exp((-1i * 2*pi * Tantenna_space * cos(deg2rad(path_info(2))) * WLAN_paras.frequency / WLAN_paras.speed_light));
for t = 1:WLAN_paras.num_Tantenna
    exp_AOA = exp((-1i * 2*pi * Rantenna_space * cos(deg2rad(path_info(1))) * WLAN_paras.frequency / WLAN_paras.speed_light));
    exp_TOF = exp( -1i * 2*pi * (0:(WLAN_paras.num_subcarrier-1)) * WLAN_paras.frequency_space * path_info(3) / WLAN_paras.speed_light);
    CSI(t,:,:) = CSI(t,:,:) + reshape(exp_AOA.' * exp_TOF * exp_AOD(t),1,WLAN_paras.num_Rantenna,WLAN_paras.num_subcarrier); % * complex_gain(k,s);
end

end
