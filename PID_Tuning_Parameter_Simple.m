% Faster target bandwidth + tracking focus
wc   = 0.02;  % try 0.015 ~ 0.025
opts = pidtuneOptions('DesignFocus','reference-tracking','PhaseMargin',45);

CV = pidtune(G_SH,'PIDF',wc,opts);

% Convert to block params
KpV = CV.Kp; KiV = CV.Ki; KdV = CV.Kd;
TiV = KpV/max(KiV,eps);
TdV = (KpV~=0)*KdV/max(KpV,eps);
NV  = isprop(CV,'Tf') * (1/max(CV.Tf,eps)) + ~isprop(CV,'Tf') * 20;  % fallback

% 2DOF weights and anti-windup
TtV   = TiV/10;              % back-calculation time constant

CT = pidtune(G_eq_T,'PIDF',wc,opts);

% Convert to block params
KpT = CT.Kp; KiT = CT.Ki; KdT = CT.Kd;
TiT = KpT/max(KiT,eps);
TdT = (KpT~=0)*KdT/max(KpT,eps);
NT  = isprop(CT,'Tf') * (1/max(CT.Tf,eps)) + ~isprop(CT,'Tf') * 20;  % fallback

% 2DOF weights and anti-windup
TtT   = TiT/10;              % back-calculation time constant
% simple tuning
KpV = KpV *1.1;
KiV = KiV *1.25;
KdV = KdV * 1.1;
NV = NV *1.2;
KpT = KpT *1.1;
KiT = KiT *1.25;
KdT = KdT * 1.1;
NT = NT *1.2;

