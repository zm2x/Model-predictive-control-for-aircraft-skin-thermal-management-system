% ---------- user parameters ----------
Ts = 2;                    % sampling time [s]
warm_T = 2000;
totalPRBS_T = 8*3600;            % total experiment time [s] (e.g. 8 hours)
Npr = floor(totalPRBS_T / Ts);    % number of  PRBS points


% desired bit widths (s)
Tbit = [600,800,1000,1200];     

% desired amplitudes (physical units) -- set per input
% e.g. [ValveOpening_amp, CompressorSpeed_amp,PumpSpeed_amp, Qaero_amp]
amp = [0.01, 100, 300, 160];    % peak ± amplitude (you can tune)

% nominal operating points (bias)
u0 = [0.44,1200,1250,6000];    % bias for each input

% ---------- generate PRBS via idinput with normalized freq ----------
fs = 1/Ts;
fNy = fs/2;
Uprbs = zeros(Npr,4);

for i=1:4
    fmax = 1/(2*Tbit(i));              % target maximal stim frequency [Hz]
    fnorm = fmax / fNy;                % normalized to Nyquist (0..1)
    if fnorm >= 1
        error('Tbit too small relative to Ts -> fmax >= Nyquist');
    end
    % idinput expects freq normalized to Nyquist (i.e. between 0 and 1)
    % create sequence in [-1,1]
    seq = idinput(Npr,'prbs',[0 fnorm],[-1 1]);
    % optional: shift the sequence by different offsets to avoid simultaneous flips
    shiftSamples = round((i-1) * (Tbit(i)/5) / Ts); % shift by 1/5 of bit width
    seq = circshift(seq, shiftSamples);
%     delaySamples = round((i-1) * (Tbit(i)/4) / Ts);  
%     seq_delayed = [repmat(seq(1), delaySamples, 1);
%                    seq(1:end-delaySamples)];
    Uprbs(:,i) = seq * amp(i) + u0(i);
end

% prepend warm-up steady block
Nwarm = round(warm_T/ Ts);
Uwarm = repmat(u0, Nwarm, 1);   % hold bias for warm-up

%full input
Ufull = [Uwarm;Uprbs];
tfull = (0:size(Ufull,1)-1)'*Ts;
% pack to timeseries for Simulink
PRBS_full_ts = timeseries(Ufull, tfull);
PRBS_full_ts.TimeInfo.Units = 'seconds';

% save to workspace
save('PRBS_with_warm_inputs.mat','PRBS_full_ts','tfull','Ufull','Ts','Tbit','amp','u0');