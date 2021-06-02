%{
  ----------------- 画出信号的功率谱密度(PSD) -----------------------------
  1）该怎样实现根据信号是否存在自动更改legend呢？
  --- 暂时使用手动修改吧

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   [] = PSD_Plot(Xs)
% 全局变量
global   settings

% 分段长度 --- 同时认为它是所需的fft的点数
nfft     = 1024;

% 加窗
window   = hanning(nfft);

% 重叠数据点数 --- 重叠50%
noverlop = nfft/2;
   
% 使用welch方法估计有用信号的PSD
[Pxs, f] = pwelch(Xs, window, noverlop, nfft, settings.fs);

% 对频谱刻度进行搬移
f        = -settings.fs/2 + f;
   
plot(f./1e6, 10*log10(fftshift(Pxs)));
grid on
hold on
xlabel('频率 [MHz]');
ylabel('功率密度 [dBW/Hz]');
title('功率谱密度');

return