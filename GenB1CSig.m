%{
  ------------------ 产生北斗B1C的中频信号 --------------------------------
  (1) S_B1C(t) = S_B1C_data(t) + 1i*S_B1C_pilot(t)
  --- S_B1C_data(t) = (1/2)*D_B1C_data(t)*C_B1C_data(t)*sc_B1C_data(t)
  --- S_B1C_pilot(t) = sqrt(3/4)*C_B1C_pilot(t)*sc_B1C_pilot(t)

  (2) 数据分量和导频分量的测距码序列的码长都是10230，码片速率都是1.023MHz
  
  (3) sc_B1C_data(t) = sign(sin(2*pi*f_sc_bic_a*t))
  --- f_sc_bic_a = 1.023MHz
  
  (4) sc_B1C_pilot(t) = sqrt(29/33)*sign(sin(2*pi*f_sc_b1c_a*t)) ...
  --- - 1i*sqrt(4/33)*sign(sin(2*pi*f_sc_b1c_b*t))

  -------------------------------------------------------------------------
  使用sign来生成子载波时会导致码相位的突变
  --- 考虑下面的关系：
  --- sign(sin(2*pi*fa*t))的码片宽度是测距码宽度的1/2
  --- sign(sin(2*pi*fb*t))的码片宽度是测距码宽度的1/12
  --- 尝试根据这个关系来按照明确的倍数关系产生子载波
  
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   Signal = GenB1CSig()

% 全局变量
global   settings;

% 计算扩频码的周期数
NumCs    = ceil(settings.SampleNum/settings.NumPerCode/settings.CodeLength);

% 计算采样点数与采样时间
NumSamp  = NumCs*settings.CodeLength*settings.NumPerCode;
t        = (1:NumSamp).*settings.ts;

% 子载波码片宽度
NumFreA  = ceil(settings.NumPerCode/2);
NumFreB  = ceil(settings.NumPerCode/12);

% 输出信号初始化
Signal   = zeros(settings.SigNum, settings.SampleNum);

for index = 1:settings.SigNum
    
    % 产生数据分量的主码
    CM_data  = genMaincode_data(index);
    
    % 将CM_data中的0映射到-1
    CM_data(CM_data == 0) = -1;
    
    % 对数据分量的主码进行码元扩展
    label    = ceil((1:settings.NumPerCode*settings.CodeLength) ...
             ./settings.NumPerCode);
         
    CM_dataL = CM_data(label);
    
    % 对扩频码进行周期重复，以避免采样点数超过1个扩频码周期时报错
    CM_dataL = repmat(CM_dataL, 1, NumCs);
    
    % 产生数据分量的子载波
    % Sc_data  = sign(sin(2*pi*settings.freScA.*t));
    sc_data  = [ones(1,NumFreA), -ones(1, NumFreA)];
    % 对一个码片长度的子载波进行周期扩展
    Sc_data  = repmat(sc_data, 1, NumCs*settings.CodeLength);
    
    % 异或构成数据分量
    S_data   = 0.5.*CM_dataL.*Sc_data;
    
    % ----------------- 构造导频分量部分 ----------------------------------
    % 产生导频分量的主码
    CM_pilot = genMaincode_pilot(index);
    CM_pilot(CM_pilot == 0) = -1;
    
    % 对导频分量的主码进行码元扩展
    label    = ceil((1:settings.NumPerCode*settings.CodeLength) ...
             ./settings.NumPerCode);
    
    CM_pilL  = CM_pilot(label);
    % 同样地，对导频分量的主码进行周期扩展
    CM_pilL  = repmat(CM_pilL, 1, NumCs);
    
    % 产生导频分量的子码 
    CS_pilot = genSubcode_pilot(index);
    CS_pilot(CS_pilot == 0) = -1;
    
    % 导频分量一个子码的长度是一个周期的主码
    % 采样点数一般不会超过1800个周期的主码信号 --- NumSamp < 1800*10230*NumPerCode
    % 因此这里暂不考虑子码的周期重复
    label    = ceil((1:NumSamp)./settings.NumPerScode);
    
    CS_pilL  = CS_pilot(label);
    
    % 导频分量主码与子码异或构成导频分量测距码
    C_b1c_pl = CM_pilL.*CS_pilL;
    
    % 产生导频分量的子载波
    sc_pil_a = [ones(1,NumFreA), -ones(1, NumFreA)];
    Sc_pil_a = repmat(sc_pil_a, 1, NumCs*settings.CodeLength);
    
    sc_pil_b = [ones(1, NumFreB), -ones(1, NumFreB)];
    Sc_pil_b = repmat(sc_pil_b, 1, 6*NumCs*settings.CodeLength);
    
    Sc_pilot = sqrt(29/33).*Sc_pil_a - 1i.*sqrt(4/33).*Sc_pil_b;
    
    % 导频分量测距码与子载波异或构成导频分量
    S_pilot  = sqrt(3/4).*C_b1c_pl.*Sc_pilot;
    
    %----------------------------------------------------------------------
    % B1C信号的复包络
    S_b1c    = S_data + 1i.*S_pilot;
    
    % 中频载波
    Carr     = exp(1i*2*pi*settings.IF(index).*t);
    
    % 复包络与载波相乘并截断
    temSig   = S_b1c.*Carr;
    Signal(index,:) = temSig(1:settings.SampleNum);
        
end % for index = 1:settings.SigNum

return