clear all;

%----------�����趨----------
msglength = 1000;%  �����������Ϣ���г���
states_num = 64;%  (2,1,7)������״̬����
coder_constraint = 7;%  Լ������    
g1 = [1; 1; 1; 1; 0; 0; 1] ;% �������ɾ����һ�� 171������������ʾ���������
g2 = [1; 0; 1; 1; 0; 1; 1] ;% �������ɾ���ڶ��� 133������������ʾ���������
max_metric = 100000; % �趨һ�������������ܵĶ���ֵ
decode_steps = msglength + coder_constraint - 1;%  ���������еĲ�����

%----------������Ϣ����----------
msg = randint(1, msglength, 2, 123);%  ����Ϊmsglength�������Ϣ���� 

%----------����matlab�⺯������(2,1,7)����������----------
trel = poly2trellis(coder_constraint, [171, 133]);
msg_with_tail = [msg, zeros(size(1 : coder_constraint - 1))];%  ��β����, ����Ϣ�Ľ�β��� coder_constraint-1 ����
code = convenc(msg_with_tail, trel);%  ���ÿ⺯�������ɾ����



%----------------------------------------------------------------------------------------
%-----------------------------------------���뼰��֤---------------------------------------
%----------------------------------------------------------------------------------------


%----------��ʼ����λ�Ĵ���coder_state�����coder_output----------
coder_state = [0 0 0 0 0 0];
coder_output = [];
%----------�������������Ĵ�����λ----------
for i = 1 : length(msg_with_tail)
   coder_data = [msg_with_tail(i) coder_state];
   coder_output_bit1 = rem(coder_data * g1, 2);
   coder_output_bit2 = rem(coder_data * g2, 2);
   coder_output = [coder_output, coder_output_bit1, coder_output_bit2];
   coder_state = [msg_with_tail(i) coder_state(1:5)];
end
%----------�Ƚ����ֱ��뷽ʽ�Ľ��������Ϊȫ0����˵����������ȷ��----------
count_coder_err = sum(abs(code - coder_output)); %  ͳ��result�з���Ԫ�صĸ���



%----------------------------------------------------------------------------------------
%---------------�������ơ�����ͽ�������������б�, �ڱ����������������ɴ���-------------
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
%---------------------------------------���뼰��֤-----------------------------------------
%----------------------------------------------------------------------------------------

%----------���������ɴ����ı���������Ϊ������������----------
decoder_input = hard_decision;%  ��������

%--------------------------------------------------------------------------
%   ���������������õ�״̬ת��ͼ:
%   state_if_input_0(state_index+1)  ,  ��ʾ��״̬state_index���� 0 ʱǨ�Ƶ���״̬����(0��63)
%   outbit1_if_input_0(state_index+1)   ,  ��ʾ��״̬state_index���� 0 ʱ������ĵ�һλ����0��1
%   outbit2_if_input_0(state_index+1)   ,  ��ʾ��״̬state_index���� 0 ʱ������ĵڶ�λ����0��1
%   state_if_input_1(state_index+1)  ,  ��ʾ��״̬state_index���� 1 ʱǨ�Ƶ���״̬����(0��63)
%   outbit1_if_input_1(state_index+1)   ,  ��ʾ��״̬state_index���� 1 ʱ������ĵ�һλ����0��1
%   outbit2_if_input_1(state_index+1)   ,  ��ʾ��״̬state_index���� 1 ʱ������ĵڶ�λ����0��1   
%--------------------------------------------------------------------------

for state_index = 0 : states_num - 1 
    decoder_state_tmp = dec2bin(state_index, coder_constraint - 1);%����״̬state_index�ö���������ʾ������state_index=5,��decoder_state_tmp=000101��
    for j = 1 : coder_constraint - 1
        decoder_state(j) = decoder_state_tmp(coder_constraint - j);%��decoder_stateΪdecoder_state_tmp�ĵ�����decoder_state_tmp=000101,decoder_state=101000
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
%   ���������������õķ�����״̬ת��ͼ:
%   last_state_smaller(state_index+1)      ,  ��ʾ��Ǩ�Ƶ�state_index״̬�Ľ�С��״̬������0��61��
%   outbit1_from_last_state_smaller(state_index+1)       ,  ��ʾ�ӽ�С��״̬Ǩ�Ƶ�state_index״̬ʱ������ĵ�һλ����0��1
%   outbit2_from_last_state_smaller(state_index+1)       ,  ��ʾ�ӽ�С��״̬Ǩ�Ƶ�state_index״̬ʱ������ĵڶ�λ����0��1
%   last_state_larger(state_index+1)      ,   ��ʾ��Ǩ�Ƶ�state_index״̬�Ľϴ��״̬������32��63����
%   outbit1_from_last_state_larger(state_index+1)       ,  ��ʾ�ӽϴ��״̬Ǩ�Ƶ�state_index״̬ʱ������ĵ�һλ����0��1
%   outbit2_from_last_state_larger(state_index+1)       ,  ��ʾ�ӽϴ��״̬Ǩ�Ƶ�state_index״̬ʱ������ĵ�һλ����0��1
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
%   ACS���㣬�����֧������·���ۻ�������״̬�ۻ�����
%   state_metrics(state_index+1)  , ��¼״̬state_index��״̬�ۻ�����ֵ
%   state_metrics_last(state_index+1)  , ��¼ǰһ��״̬state_index��״̬�ۻ�����ֵ
%
%   branch_metrics_from_smaller(state_index+1) ,��¼�ӽ�С״̬Ǩ�Ƶ�״̬state_indexʱ�ķ�֧����ֵ
%   branch_metrics_from_larger(state_index+1) ,��¼�ӽϴ�״̬Ǩ�Ƶ�״̬state_indexʱ�ķ�֧����ֵ
%
%   path_metrics_from_smaller(state_index+1) ,��¼�ӽ�С״̬Ǩ�Ƶ�״̬state_indexʱ��·���ۻ�����ֵ
%   path_metrics_from_larger(state_index+1) ,��¼�ӽϴ�״̬Ǩ�Ƶ�״̬state_indexʱ��·���ۻ�����ֵ
% 
%   path_record(state_index+1, step_index) , ��¼ÿһ�����Ҵ��֧, 0: �ӽ�С״̬Ǩ�Ƶ�״̬state_index, 1: �ӽϴ�״̬Ǩ�Ƶ�״̬state_index                
%--------------------------------------------------------------------------


%----------------��ʼ����֧������·���ۻ�������״̬�ۻ�����-------------------
for state_index = 0 : states_num-1 
    state_metrics(state_index+1) = 0;%  ��ʼ��״̬�ۻ�����ֵ
    branch_metrics_from_smaller(state_index+1) = 0;
    branch_metrics_from_larger(state_index+1) = 0;
    path_metrics_from_smaller(state_index+1) = 0;
    path_metrics_from_larger(state_index+1) = 0;
end

for step_index = 1 : decode_steps
    for state_index = 0 : states_num-1
        path_record(state_index+1, step_index) = 0;%  ��ʼ��·���������������·��
    end
end


%--------------------------------------------------------------------------
% �����֧������·���ۻ�������״̬�ۻ�����
% ����·���ķ�֧����ֵ(��¼��branch_metrics_from_smaller��branch_metrics_from_larger��)��
% ����ǰһ��״̬�ۻ�����ֵ(��¼��state_metrics_last)��ӣ�
% ����·���ۻ�����ֵ(��¼��path_metrics_from_smaller��path_metrics_from_larger)��
% ͨ���Ƚϣ�ѡ��·���ۻ�����ֵ��С����Ϊ״̬�ۻ�����ֵ(��¼��state_metrics)��
% ������Ӧ��ѡ����(�Ҵ�·��)��¼��path_record�С�
%--------------------------------------------------------------------------

for step_index = 1 : decode_steps 
    
    if step_index <= coder_constraint-1  %  ��Ϊ��ʼ״̬��֪Ϊȫ��״̬�����������⴦��
        state_metrics_last = state_metrics;
        for state_index = 0 : pow2(step_index)-1
            branch_metrics_from_smaller(state_index+1) = abs(decoder_input(2 * step_index - 1) - outbit1_from_last_state_smaller(state_index+1)) + abs(decoder_input(2 * step_index) - outbit2_from_last_state_smaller(state_index+1));
            path_metrics_from_smaller(state_index+1) = state_metrics_last(last_state_smaller(state_index+1) + 1) + branch_metrics_from_smaller(state_index+1);
            path_metrics_from_larger(state_index+1) = max_metric;
            state_metrics(state_index+1) = path_metrics_from_smaller(state_index+1);
            path_record(state_index+1, step_index) = 0;%  �Ҵ�·��ȫ�����Խ�С״̬
        end            
    else  %  ����ACS����
        state_metrics_last = state_metrics;
        for state_index = 0 : states_num-1
            branch_metrics_from_smaller(state_index+1) = abs(decoder_input(2 * step_index - 1) - outbit1_from_last_state_smaller(state_index+1)) + abs(decoder_input(2 * step_index) - outbit2_from_last_state_smaller(state_index+1));
            branch_metrics_from_larger(state_index+1) = abs(decoder_input(2 * step_index - 1) - outbit1_from_last_state_larger(state_index+1)) + abs(decoder_input(2 * step_index) - outbit2_from_last_state_larger(state_index+1));
            path_metrics_from_smaller(state_index+1) = state_metrics_last(last_state_smaller(state_index+1) + 1) + branch_metrics_from_smaller(state_index+1);
            path_metrics_from_larger(state_index+1) = state_metrics_last(last_state_larger(state_index+1) + 1) + branch_metrics_from_larger(state_index+1);
            %   �Ƚ�path_metrics_from_smaller��path_metrics_from_larger�Ĵ�С,����С�Ĵ���state_metrics
            %   �����С��ֵ��path_metrics_from_larger����ô�� 1 ����path_record(state_index+1, step_index);
            %   ���� 0 ����path_record(state_index+1, step_index)
            if path_metrics_from_larger(state_index+1) < path_metrics_from_smaller(state_index+1)
                state_metrics(state_index+1) = path_metrics_from_larger(state_index+1);
                path_record(state_index+1, step_index) = 1;%  �Ҵ�·�������Խϴ�״̬
            else 
                state_metrics(state_index+1) = path_metrics_from_smaller(state_index+1);
                path_record(state_index+1, step_index) = 0;%  �Ҵ�·�������Խ�С״̬
            end
        end 
    end
    
end



%--------------------------------------------------------------------------
%  ����
%  ��from_state״̬�ɺ���ǰ����path_record(i, j)��
%  ���鵽��0��1(branch_record)����decoder_output��
%--------------------------------------------------------------------------

from_state = 0; % ��Ϊ��֪��β��ȫ�㣬���Ի�����ʼ״̬Ϊȫ��״̬

for step_index = decode_steps : -1 : coder_constraint
    branch_record = path_record(from_state+1, step_index);
    decoder_output(step_index - coder_constraint + 1) = branch_record;
    if branch_record == 0
        from_state = last_state_smaller(from_state+1);
    else
        from_state = last_state_larger(from_state+1);
    end
end

%-----------�ȽϽ�����-----------
p = decoder_output - msg;
count_decode_err = sum(abs(p))

