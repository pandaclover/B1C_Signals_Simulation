%{
  ------------------ 系统参数设置 -----------------------------------------

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function    settings  = iniSettings()

% 常数
settings.c            = 3e8;                         % 光速

%--------------------- 信号参数设置 ---------------------------------------
settings.fc           = 1575.42e6;                   % 载波频率
settings.lambda       = settings.c/settings.fc;      % 信号波长
settings.freCode      = 1.023e6;                     % 测距码速率
settings.CodeLength   = 10230;                       % 测距码长度
settings.freScA       = 1*1.023e6;                   % 子载波A的频率
settings.freScB       = 6*1.023e6;                   % 子载波B的频率

%--------------------- 接收机参数设置 -------------------------------------
settings.IF           = 10e6;                        % 中心频率
settings.fs           = 96*1.023e6;                  % 采样频率
settings.ts           = 1/settings.fs;               % 采样周期
settings.N            = 512;                         % FFT点数
settings.M            = 50;                          % 分段数
settings.SampleNum    = settings.N*settings.M;       % 信号长度（采样点数）
settings.NumPerCode   = ceil(settings.fs ...
                      / settings.freCode);           % 每个码片采样点数
settings.NumPerScode  = settings.CodeLength ...
                      * settings.NumPerCode;         % 每个子码采样点数
% 这是因为导频分量子码的码片宽度与主码的周期相同

%--------------------- 仿真场景设置 ---------------------------------------
settings.SigNum       = 1;                           % 信号数

end