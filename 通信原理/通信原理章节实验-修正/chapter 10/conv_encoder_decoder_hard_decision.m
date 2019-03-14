clear all;

%----------参数设定----------
msglength = 1000;%  用来编码的消息序列长度
states_num = 64;%  (2,1,7)卷积码的状态数量
coder_constraint = 7;%  约束长度    
g1 = [1; 1; 1; 1; 0; 0; 1] ;% 基本生成矩阵第一行 171，用列向量表示，方便计算
g2 = [1; 0; 1; 1; 0; 1; 1] ;% 基本生成矩阵第二行 133，用列向量表示，方便计算
max_metric = 100000; % 设定一个解码器最大可能的度量值
decode_steps = msglength + coder_constraint - 1;%  解码器运行的步骤数

%----------生成信息序列----------
msg = randint(1, msglength, 2, 123);%  长度为msglength的随机消息序列 

%----------调用matlab库函数生成(2,1,7)卷积码编码结果----------
trel = poly2trellis(coder_constraint, [171, 133]);
msg_with_tail = [msg, zeros(size(1 : coder_constraint - 1))];%  结尾处理, 在消息的结尾添加 coder_constraint-1 个零
code = convenc(msg_with_tail, trel);%  调用库函数所生成卷积码



%----------------------------------------------------------------------------------------
%-----------------------------------------编码及验证---------------------------------------
%----------------------------------------------------------------------------------------


%----------初始化移位寄存器coder_state和输出coder_output----------
coder_state = [0 0 0 0 0 0];
coder_output = [];
%----------计算编码输出及寄存器移位----------
for i = 1 : length(msg_with_tail)
   coder_data = [msg_with_tail(i) coder_state];
   coder_output_bit1 = rem(coder_data * g1, 2);
   coder_output_bit2 = rem(coder_data * g2, 2);
   coder_output = [coder_output, coder_output_bit1, coder_output_bit2];
   coder_state = [msg_with_tail(i) coder_state(1:5)];
end
%----------比较两种编码方式的结果，若差为全0，则说明编码是正确的----------
count_coder_err = sum(abs(code - coder_output)); %  统计result中非零元素的个数



%----------------------------------------------------------------------------------------
%---------------经过调制、传输和解调，编码序列中被, 在编码序列中引入若干错误-------------
%----------------------------------------------------------------------------------------
noise_power=0.5;
hard_decision=zeros(1,2012);
modulated=1-2*code;
noise_added=modulated+sqrt(noise_power)*randn(1,2012);
for iter=1:2012
    if noise_added(iter)>0
        hard_decision(iter)=0;
    else
        hard_decision(iter)=1;
    end
end

%----------------------------------------------------------------------------------------
%---------------------------------------解码及验证-----------------------------------------
%----------------------------------------------------------------------------------------

%----------将引入若干错误后的编码序列作为解码器的输入----------
decoder_input = hard_decision;%  解码输入

%--------------------------------------------------------------------------
%   计算解码过程中所用的状态转移图:
%   state_if_input_0(state_index+1)  ,  表示在状态state_index输入 0 时迁移到的状态——(0—63)
%   outbit1_if_input_0(state_index+1)   ,  表示在状态state_index输入 0 时的输出的第一位——0、1
%   outbit2_if_input_0(state_index+1)   ,  表示在状态state_index输入 0 时的输出的第二位——0、1
%   state_if_input_1(state_index+1)  ,  表示在状态state_index输入 1 时迁移到的状态——(0—63)
%   outbit1_if_input_1(state_index+1)   ,  表示在状态state_index输入 1 时的输出的第一位——0、1
%   outbit2_if_input_1(state_index+1)   ,  表示在状态state_index输入 1 时的输出的第二位——0、1   
%--------------------------------------------------------------------------

for state_index = 0 : states_num - 1 
    decoder_state_tmp = dec2bin(state_index, coder_constraint - 1);%　把状态state_index用二进制数表示，例如state_index=5,则decoder_state_tmp=000101　
    for j = 1 : coder_constraint - 1
        decoder_state(j) = decoder_state_tmp(coder_constraint - j);%　decoder_state为decoder_state_tmp的倒序，若decoder_state_tmp=000101,decoder_state=101000
    end
    decoder_data_if_input_0 = [0 decoder_state];
    decoder_data_if_input_1 = [1 decoder_state];
    outbit1_if_input_0(state_index+1) = rem(decoder_data_if_input_0 * g1, 2);
    outbit2_if_input_0(state_index+1) = rem(decoder_data_if_input_0 * g2, 2);
    outbit1_if_input_1(state_index+1) = rem(decoder_data_if_input_1 * g1, 2);
    outbit2_if_input_1(state_index+1) = rem(decoder_data_if_input_1 * g2, 2);
end
for state_index = 0 : states_num - 1
    if state_index < states_num / 2
        state_if_input_0(state_index+1) = 2 * state_index;        
        state_if_input_1(state_index+1) = 2 * state_index + 1;
    else
        state_if_input_0(state_index+1) = 2 * state_index - states_num;
        state_if_input_1(state_index+1) = 2 * state_index - states_num + 1;
    end
end


%--------------------------------------------------------------------------
%   计算解码过程中所用的反方向状态转移图:
%   last_state_smaller(state_index+1)      ,  表示可迁移到state_index状态的较小的状态——（0—61）
%   outbit1_from_last_state_smaller(state_index+1)       ,  表示从较小的状态迁移到state_index状态时的输出的第一位——0、1
%   outbit2_from_last_state_smaller(state_index+1)       ,  表示从较小的状态迁移到state_index状态时的输出的第二位——0、1
%   last_state_larger(state_index+1)      ,   表示可迁移到state_index状态的较大的状态——（32—63），
%   outbit1_from_last_state_larger(state_index+1)       ,  表示从较大的状态迁移到state_index状态时的输出的第一位——0、1
%   outbit2_from_last_state_larger(state_index+1)       ,  表示从较大的状态迁移到state_index状态时的输出的第一位——0、1
%--------------------------------------------------------------------------

for state_index = 0 : states_num - 1
   if rem(state_index, 2) == 0
       last_state_smaller(state_index+1) = state_index / 2;
       outbit1_from_last_state_smaller(state_index+1)  = outbit1_if_input_0(last_state_smaller(state_index+1)+1);
       outbit2_from_last_state_smaller(state_index+1)  = outbit2_if_input_0(last_state_smaller(state_index+1)+1);
       last_state_larger(state_index+1)  = (states_num + state_index) / 2;
       outbit1_from_last_state_larger(state_index+1)  = outbit1_if_input_0(last_state_larger(state_index+1)+1);
       outbit2_from_last_state_larger(state_index+1)  = outbit2_if_input_0(last_state_larger(state_index+1)+1);
   else
       last_state_smaller(state_index+1) = last_state_smaller(state_index-1+1);
       outbit1_from_last_state_smaller(state_index+1)  = outbit1_if_input_1(last_state_smaller(state_index) + 1);
       outbit2_from_last_state_smaller(state_index+1)  = outbit2_if_input_1(last_state_smaller(state_index) + 1);
       last_state_larger(state_index+1)  = last_state_larger(state_index-1+1);
       outbit1_from_last_state_larger(state_index+1)  = outbit1_if_input_1(last_state_larger(state_index) + 1);
       outbit2_from_last_state_larger(state_index+1)  = outbit2_if_input_1(last_state_larger(state_index) + 1);
   end
end


%--------------------------------------------------------------------------
%   ACS运算，计算分支度量、路径累积度量、状态累积度量
%   state_metrics(state_index+1)  , 记录状态state_index的状态累积度量值
%   state_metrics_last(state_index+1)  , 记录前一步状态state_index的状态累积度量值
%
%   branch_metrics_from_smaller(state_index+1) ,记录从较小状态迁移到状态state_index时的分支度量值
%   branch_metrics_from_larger(state_index+1) ,记录从较大状态迁移到状态state_index时的分支度量值
%
%   path_metrics_from_smaller(state_index+1) ,记录从较小状态迁移到状态state_index时的路径累积度量值
%   path_metrics_from_larger(state_index+1) ,记录从较大状态迁移到状态state_index时的路径累积度量值
% 
%   path_record(state_index+1, step_index) , 记录每一步的幸存分支, 0: 从较小状态迁移到状态state_index, 1: 从较大状态迁移到状态state_index                
%--------------------------------------------------------------------------


%----------------初始化分支度量、路径累积度量、状态累积度量-------------------
for state_index = 0 : states_num-1 
    state_metrics(state_index+1) = 0;%  初始化状态累积度量值
    branch_metrics_from_smaller(state_index+1) = 0;
    branch_metrics_from_larger(state_index+1) = 0;
    path_metrics_from_smaller(state_index+1) = 0;
    path_metrics_from_larger(state_index+1) = 0;
end

for step_index = 1 : decode_steps
    for state_index = 0 : states_num-1
        path_record(state_index+1, step_index) = 0;%  初始化路径，用来查找最佳路径
    end
end


%--------------------------------------------------------------------------
% 计算分支度量、路径累积度量、状态累积度量
% 两条路径的分支度量值(记录在branch_metrics_from_smaller和branch_metrics_from_larger中)，
% 并与前一步状态累积度量值(记录在state_metrics_last)相加，
% 产生路径累积度量值(记录在path_metrics_from_smaller和path_metrics_from_larger)，
% 通过比较，选择路径累积度量值较小的作为状态累积度量值(记录在state_metrics)，
% 并将相应的选择结果(幸存路径)记录在path_record中。
%--------------------------------------------------------------------------

for step_index = 1 : decode_steps 
    
    if step_index <= coder_constraint-1  %  因为初始状态已知为全零状态，所以做特殊处理
        state_metrics_last = state_metrics;
        for state_index = 0 : pow2(step_index)-1
            branch_metrics_from_smaller(state_index+1) = abs(decoder_input(2 * step_index - 1) - outbit1_from_last_state_smaller(state_index+1)) + abs(decoder_input(2 * step_index) - outbit2_from_last_state_smaller(state_index+1));
            path_metrics_from_smaller(state_index+1) = state_metrics_last(last_state_smaller(state_index+1) + 1) + branch_metrics_from_smaller(state_index+1);
            path_metrics_from_larger(state_index+1) = max_metric;
            state_metrics(state_index+1) = path_metrics_from_smaller(state_index+1);
            path_record(state_index+1, step_index) = 0;%  幸存路径全部来自较小状态
        end            
    else  %  正常ACS运算
        state_metrics_last = state_metrics;
        for state_index = 0 : states_num-1
            branch_metrics_from_smaller(state_index+1) = abs(decoder_input(2 * step_index - 1) - outbit1_from_last_state_smaller(state_index+1)) + abs(decoder_input(2 * step_index) - outbit2_from_last_state_smaller(state_index+1));
            branch_metrics_from_larger(state_index+1) = abs(decoder_input(2 * step_index - 1) - outbit1_from_last_state_larger(state_index+1)) + abs(decoder_input(2 * step_index) - outbit2_from_last_state_larger(state_index+1));
            path_metrics_from_smaller(state_index+1) = state_metrics_last(last_state_smaller(state_index+1) + 1) + branch_metrics_from_smaller(state_index+1);
            path_metrics_from_larger(state_index+1) = state_metrics_last(last_state_larger(state_index+1) + 1) + branch_metrics_from_larger(state_index+1);
            %   比较path_metrics_from_smaller和path_metrics_from_larger的大小,将较小的存入state_metrics
            %   如果较小的值是path_metrics_from_larger，那么将 1 记入path_record(state_index+1, step_index);
            %   否则将 0 记入path_record(state_index+1, step_index)
            if path_metrics_from_larger(state_index+1) < path_metrics_from_smaller(state_index+1)
                state_metrics(state_index+1) = path_metrics_from_larger(state_index+1);
                path_record(state_index+1, step_index) = 1;%  幸存路径是来自较大状态
            else 
                state_metrics(state_index+1) = path_metrics_from_smaller(state_index+1);
                path_record(state_index+1, step_index) = 0;%  幸存路径是来自较小状态
            end
        end 
    end
    
end



%--------------------------------------------------------------------------
%  回溯
%  从from_state状态由后往前查找path_record(i, j)，
%  将查到的0或1(branch_record)记入decoder_output，
%--------------------------------------------------------------------------

from_state = 0; % 因为已知结尾是全零，所以回溯起始状态为全零状态

for step_index = decode_steps : -1 : coder_constraint
    branch_record = path_record(from_state+1, step_index);
    decoder_output(step_index - coder_constraint + 1) = branch_record;
    if branch_record == 0
        from_state = last_state_smaller(from_state+1);
    else
        from_state = last_state_larger(from_state+1);
    end
end

%-----------比较解码结果-----------
p = decoder_output - msg;
count_decode_err = sum(abs(p))

