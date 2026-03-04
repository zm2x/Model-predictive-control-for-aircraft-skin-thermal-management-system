% known values
plant = Gdev;
Ts = plant.Ts;
ny = size(plant.C,1);

% choose the two outputs to control (indices in 1..ny)
ctrl_idx = [6 7];
% time vector
Tsim = 9000;  t = (0:round(Tsim/Ts))'*Ts;  N = numel(t);

% references (deviation form): start with zeros
rmat = zeros(N, ny);
% Disturbance (areodynamic heat load) unmeasured 
% dist0 = ones(N,1)*u0(4);
% Disturbance measured
% dist1 = zeros(N,1);
% fill only the two controlled outputs
% 
% reference generate
rmat(t>=5000, ctrl_idx(1)) =10.0-y0(ctrl_idx(1));
rmat(t>=6000 & t<7500,ctrl_idx(2)) = 288.0 - y0(ctrl_idx(2));
rmat(t>=7500,ctrl_idx(2)) =285.0- y0(ctrl_idx(2));

%% === First-order filter parameters ===
tau = 10;                 % Filter time constant [s]
alpha = exp(-Ts/tau);     % Discrete coefficient: y[k] = alpha*y[k-1] + (1-alpha)*u[k]

%% === Apply filter only to the controlled channels (ctrl_idx) ===
r_filt = zeros(size(rmat));   % Filtered reference signal (still in deviation form, initial value = 0)
for k = 2:N
    % Filter only the selected controlled outputs
    r_filt(k, ctrl_idx) = alpha * r_filt(k-1, ctrl_idx) + (1 - alpha) * rmat(k, ctrl_idx);
    % Other channels remain 0 (same as in rmat)
end

%% === Create timeseries for Simulink ===
r_ts_raw   = timeseries(rmat,  t);      % Original step-like reference
r_ts_filt  = timeseries(r_filt, t);     % Filtered reference (recommended for MPC input)

% Disturbance timeseries (unchanged)
% dis_um_ts  = timeseries(dist0, t);

%% === Visualization: raw vs filtered reference ===
figure;
tiledlayout(2,1);

nexttile;  % First controlled output
plot(t, rmat(:, ctrl_idx(1)),  'LineWidth', 1.2); hold on;
plot(t, r_filt(:, ctrl_idx(1)), 'LineWidth', 1.8);
grid on; xlabel('Time (s)'); ylabel(sprintf('r_{%d} (deviation)', ctrl_idx(1)));
title(sprintf('Reference CH %d: Raw vs Filtered (\\tau = %.1f s)', ctrl_idx(1), tau));
legend('Raw','Filtered','Location','best');

nexttile;  % Second controlled output
plot(t, rmat(:, ctrl_idx(2)),  'LineWidth', 1.2); hold on;
plot(t, r_filt(:, ctrl_idx(2)), 'LineWidth', 1.8);
grid on; xlabel('Time (s)'); ylabel(sprintf('r_{%d} (deviation)', ctrl_idx(2)));
title(sprintf('Reference CH %d: Raw vs Filtered (\\tau = %.1f s)', ctrl_idx(2), tau));
legend('Raw','Filtered','Location','best');

