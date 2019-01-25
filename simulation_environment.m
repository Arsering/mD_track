function path_info_output = simulation_environment(path_info_input,SNR,has_noise,num_samples,correlation_coefficient)
%% 将实验环境抽象为一个二维坐标系 每个单位长度代表1m
% target_location 是定位目标的位置 大小为：1-2（一般设置为坐标原点）
% APs_location 是AP的位置 大小为：2-2-Nap 
%              Nap是实验中用到的AP总个数，每个AP对应着两行且 
%              每行表示一个二维坐标点，两个坐标点即确定了一个AP中所有天线所在的
%              平面。默认两个坐标点中距离target最近的即为天线组中第一个天线的位
%              置，另一个坐标点代表天线组中的其他成员与第一个天线的位置关系
% frequency 信息传输的工作频率 单位：Hz
% antenna_space AP上相邻天线之间的距离 表示为波长的倍数
% num_antenna 每个AP上天线的个数
% num_subcarrier 每个天线上的子载波数
% num_path 每个AP上的路径总数
% add_len 对于非直接路径 路径长度范围是(direct_len * add_len,direct_len * (add_len + 1))
% speed_light 信号传播速度 m/s

%% 定义变量
WLAN.path_info_input = path_info_input;
WLAN.SNR = SNR;
WLAN.has_noise = has_noise; % 为1则添加噪声 否则不添加噪声
WLAN.num_samples = num_samples;
WLAN.correlation_coefficient = correlation_coefficient;
WLAN.window_size = 2;
WLAN.grid_range = [180,90];
WLAN.precison = [1,1,0.5]'; % 第一个是AOA 单位：度 第二个是TOF 单位：m
WLAN.threshold = WLAN.precison;
WLAN.frequency = 5 * 10^9;
WLAN.antenna_space_ofwaveLen = [0.5,0.5];
WLAN.num_Rantenna = 8; % 接收天线的个数
WLAN.num_Tantenna = 3; % 发送天线的个数
WLAN.num_subcarrier = 64; % 子载波的个数
WLAN.frequency_space = 312.5 * 10^3; % 单位：Hz
WLAN.add_len = 1.1;
WLAN.speed_light = 3 * 10^8;
WLAN.iterateID = 1;

%% 先产生对应的CSI数据 之后利用MUSIC算法解出相应的AOA和TOF

    % 生成每个AP对应的CSI矩阵和它所接收到的路径信息
    CSI = simulation_generateCSI(WLAN);
    
    % 利用MUSIC算法从CSI矩阵中反解出每条路径的AoA TOF
    path_info_output = mD_track(CSI,WLAN,size(WLAN.path_info_input,2));
%     path_info_output = music_SpotFi(CSI,WLAN,size(WLAN.path_info_input,1));
   

end
    