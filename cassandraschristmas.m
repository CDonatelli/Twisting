
function [cal1, cal2, WaveInfo, time] = cassandraschristmas(trial, gravity, time)
% Cassandra and Vishesh

% Line 172 (ish) = be sure to change input depending on orientation of the 
% chip in question. Chip orientation vs fish orientation may change trial 
% to trial if you are not consistant with chip placement!

clc

% set calib files for the load_imu function (Eric Tytell)
calib.chip2world1 = eye(3);
calib.chip2world2 = eye(3);
calib.world2chip1 = eye(3);
calib.world2chip2 = eye(3);

% Load necessary IMU's
[grav1, grav2] = load_2imu(gravity, calib);
[cal1, cal2] = load_2imu(trial, calib);

% cal1 = B11_071;
% cal2 = B11_072;
% grav1 = G1;
% grav2 = G2;
% Let's load everything file
% load('E:\QuaternionORientation\DriftWks.mat')
% cal1 = IMU for chip 1 (at the radial center)
% cal2 = IMU for chip 2 (at the radial edge)
% grav1, grav2 = IMUs at rest for respective chips
% grav1, grav2 = used for calibration purposes

% Step 1 : calibration only for biases
% Let's get rid of the constant biases
% It has been corrected - the random jump
% IMPORTANT - UNITS ARE 'G' AND 'DEGREES'
cal1.N          = length(cal1.t);
cal2.N          = length(cal2.t);

% cal1.acc_bias   = mean(cal1.acc(1:350,:));
% cal2.acc_bias   = mean(cal2.acc(1:350,:));
% cal1.gyro_bias  = mean(cal1.gyro(1:350,:));
% cal2.gyro_bias  = mean(cal2.gyro(1:350,:));

cal1.acc_bias   = mean(grav1.acc) - [0,0,1];
cal2.acc_bias   = mean(grav2.acc) - [0,0,1];
cal1.gyro_bias  = mean(grav1.gyro);
cal2.gyro_bias  = mean(grav2.gyro);


cal1.acc_errnorm= 3*norm(std(grav1.acc));
cal2.acc_errnorm= 3*norm(std(grav2.acc));
cal1.gyro_errnorm= 3*norm(std(grav1.gyro));
cal2.gyro_errnorm= 3*norm(std(grav2.gyro));

% keyboard
cal1.acc_corrected  = cal1.acc-repmat(cal1.acc_bias,cal1.N,1);
cal1.gyro_corrected = cal1.gyro-repmat(cal1.gyro_bias,cal1.N,1);

cal2.acc_corrected  = cal2.acc-repmat(cal2.acc_bias,cal2.N,1);
cal2.gyro_corrected = cal2.gyro-repmat(cal2.gyro_bias,cal2.N,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Try adding a filter
f = 1/(cal1.t(2) - cal1.t(1));
    gyrolo1 = get_low_baseline(cal1.t, cal1.gyro, 0.1);
    cal1.gyro_corrected = cal1.gyro_corrected - gyrolo1;
    gyrolo2 = get_low_baseline(cal2.t, cal2.gyro, 0.1);
    cal2.gyro_corrected = cal2.gyro_corrected - gyrolo2;
    %and then a low pass filter to get rid of the high frequencies
    [b,a] = butter(5,10/(f/2), 'low');
    cal1.gyro_corrected = filtfilt(b,a, cal1.gyro_corrected);
    cal1.gyro_corrected = cal1.gyro_corrected - ...
        repmat(nanmean(cal1.gyro_corrected),[cal1.N 1]);
    cal2.gyro_corrected = filtfilt(b,a, cal2.gyro_corrected);
    cal2.gyro_corrected = cal2.gyro_corrected - ...
        repmat(nanmean(cal2.gyro_corrected),[cal2.N 1]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 2 : Simple Integration of GYROSCOPE
cal1.orient = cumtrapz(cal1.t, cal1.gyro_corrected);
cal2.orient = cumtrapz(cal2.t, cal2.gyro_corrected);

% Step 3 : Correct it when the acceleration is gravity
cal1.accelNorm  = sqrt(sum(cal1.acc.^2,2));
cal1.gyroNorm   = sqrt(sum(cal1.gyro.^2,2));
Err1_acc = abs(cal1.accelNorm - 1);
cal2.accelNorm = sqrt(sum(cal2.acc.^2,2));
cal2.gyroNorm   = sqrt(sum(cal2.gyro.^2,2));
Err2_acc = abs(cal2.accelNorm - 1);

% orient
for ii = 1:cal1.N
    aNorm1 = norm(cal1.acc_corrected(ii,:));
    gNorm1 = norm(cal1.gyro_corrected(ii,:));
    if(abs(aNorm1-1)<cal1.acc_errnorm)
        
    end
end


% Using cal.acc_errnorm as the error range
InRange1 = find((Err1_acc<cal1.acc_errnorm));
InRange2 = find(Err2_acc<cal2.acc_errnorm);

Okvar = 0;
while Okvar == 0
    %Get the length of the trial
    %time = input('Enter time : ');
    start1 = find(abs(cal1.t)<time);
    start2 = find(abs(cal2.t)<time);
    start1 = start1(1);
    start2 = start2(1);

    % Plot the orientations over the length of the trial
    f = figure();
    set(f, 'name', [trial, ' RAW'], 'numbertitle', 'off');
    subplot(2,1,1)
    plot(cal1.t(start1:end), cal1.orient(start1:end,:));
    % plot(cal1.t, cal1.orient);
    title('IMU 1 orientation');
    xlabel('time');
    ylabel('angle (degrees)');
    legend('Roll', 'Pitch', 'Yaw');
    grid on;
    subplot(2,1,2)
    plot(cal2.t(start2:end), cal2.orient(start2:end,:));
    % plot(cal2.t, cal2.orient);
    title('IMU 2 orientation');
    xlabel('time');
    ylabel('angle (degrees)');
    legend('Roll', 'Pitch', 'Yaw')
    grid on;
    
    Okvar = input('Does this look ok (1 = yes, 0 = no) : ');
    if Okvar == 0
        time = input(['Time currently = ', time, '. Enter a new value : ']);
        close
    else
        time = time;
    end
end

% Save orientatons from start of trial to end
t = cal1.t(start1:end);
roll1 = cal1.orient(start1:end,1);
pitch1 = cal1.orient(start1:end,2);
yaw1 = cal1.orient(start1:end,3);

roll2 = cal2.orient(start2:end,1);
pitch2 = cal2.orient(start2:end,2);
yaw2 = cal2.orient(start2:end,3);

cal1.TrialOrient = [roll1, pitch1, yaw1];
cal2.TrialOrient = [roll2, pitch2, yaw2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correct the rest of the drift

R1p = polyfit(t, roll1, 5); roll1 = roll1 - polyval(R1p, t);
P1p = polyfit(t, pitch1, 5); pitch1 = pitch1 - polyval(P1p, t);
Y1p = polyfit(t, yaw1, 5); yaw1 = yaw1 - polyval(Y1p, t);

R2p = polyfit(t, roll2, 5); roll2 = roll2 - polyval(R2p, t);
P2p = polyfit(t, pitch2, 5); pitch2 = pitch2 - polyval(P2p, t);
Y2p = polyfit(t, yaw2, 5); yaw2 = yaw2 - polyval(Y2p, t);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Get Phase info
% Change chip pitch to fish yaw and chip yaw to fish pitch <<---
WaveInfo = FindPhaseInfo([roll1, pitch1, yaw1], [roll2, pitch2, yaw2], t, trial);

PitchPeakLag = mean(WaveInfo.PPLags);
PPL = std(WaveInfo.PPLags);
PitchValLag = mean(WaveInfo.PVLags);
PVL = std(WaveInfo.PVLags);
YawPeakLag = mean(WaveInfo.YPLags);
YPL = std(WaveInfo.YPLags);
YawValLag = mean(WaveInfo.YVLags);
YVL = std(WaveInfo.YVLags);

% PitchPeakLag = mean(PhaseInfo.Lags(:,1));
% PPL = std(PhaseInfo.Lags(:,1));
% PitchValLag = mean(PhaseInfo.Lags(:,2));
% PVL = std(PhaseInfo.Lags(:,2));
% YawPeakLag = mean(PhaseInfo.Lags(:,3));
% YPL = std(PhaseInfo.Lags(:,3));
% YawValLag = mean(PhaseInfo.Lags(:,4));
% YVL = std(PhaseInfo.Lags(:,4));

WaveInfo.Mstd = [PitchPeakLag, PitchValLag, YawPeakLag, YawValLag;
                      PPL,          PVL,         YPL,       YVL    ];

WaveInfo.C1Orient = cal1.orient;
WaveInfo.C2Orient = cal2.orient;

end