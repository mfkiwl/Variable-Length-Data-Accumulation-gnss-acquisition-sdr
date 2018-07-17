%%ϵͳ��ʼֵ
%---------------------------------------------------------------
%   fs        ����Ƶ��
%   fifTheory ������Ƶ
%   fcTheory  ���������Ƶ��
%   fnhTHeory NH����������
%   deltaIF   �ز�Ƶƫ
%   deltaC    �����Ƶƫ
%   deltaNH   NH��Ƶƫ
%   fif       ʵ���ز�Ƶ��
%   pha       �ز�����
%   fc        ʵ�ʲ����Ƶ��
%   fnh       ʵ��NH����
%   fnav      ʵ�ʵ�������Ƶ��
%   PRN       ����PRN��
%   rangCode  �����ڲ����
%   NHcode    ������NH��
%   navCode   ��������
%   CN0       �����(dB)
%   SNR       �����(dB)
%----------------------------------------------------------------
%%
PRN = 14;
fs  = 10e6;
fifTheory = 2.5e6;
fcTheory  = 2.046e6;
fnhTheory = 1e3;
deltaIF = 1625;
deltaC  = deltaIF/763;
deltaNH = deltaC/2046;
fif  = fifTheory + deltaIF;
pha  = 0.2;
fc   = fcTheory + deltaC;
fnh  = fnhTheory + deltaNH;
fnav = 50;
CN0 = 30:0.2:40;
SNR = CN0-10*log10(fs/2);
NHcode   = [-1,-1,-1,-1,-1,1,-1,-1,1,1,-1,1,-1,1,-1,-1,1,1,1,-1];
navCode  = 2*randi(2,1,110/0.02)-3;
rangCode = generaterangcode(PRN);
h4M = BDSsimfilter_4M;
% h2M = BDSsimfilter_2M;
ss = zeros(1,21*fs);
load noise.mat navCode
for ii = 1:21
    t = ii-1+(1:1*fs)/fs;
    signal((ii-1)*fs+1:ii*fs) = navCode(ceil(t*fnav)).*NHcode(mod(floor(t*fnh),20)+1).*rangCode(mod(floor(t*fc),2046)+1).*cos((2*pi*fif*t+pha));
end
clear t 
% noise = wgn(1,21*fs,20);
load noise.mat noise
for CN0 = 40.2:0.2:45
    SNR = CN0-10*log10(fs/2);
    fid = fopen(['1\BDSsim_4M_' num2str(10*CN0) 'dB.bin'],'wb');
    signalAmp = 10^((SNR + 20)/20);
    ss = noise + signal*signalAmp*realsqrt(2.0636);
    %
    % filter the signal and write to the file
    temp = filter(h4M,ss(1:1e7+118));
    fwrite(fid,int8(temp(60:end)),'int8');
    for ii = 1:19
        temp = filter(h4M,ss(1+ii*fs:(ii+1)*fs+118));
        fwrite(fid, int8(temp(119:end)),'int8');
    end
    temp = filter(h4M,ss(20*fs:end));
    fwrite(fid,int8(temp(119:end)),'int8');
    %
    %
    fclose(fid);
end

    