function [ PhaseInfo ] = FindPhaseInfo( Orient1, Orient2, time )
% Computes the phase lag between chips 1 and 2

% Seperate Roll Pitch and Yaw
R1 = Orient1(:,1); P1 = Orient1(:,2); Y1 = Orient1(:,3);
R2 = Orient2(:,1); P2 = Orient2(:,2); Y2 = Orient2(:,3);

[R1pY, R1pX] = findpeaks(R1); [R1vY, R1vX] = findpeaks((-1*R1));
[P1pY, P1pX] = findpeaks(P1); [P1vY, P1vX] = findpeaks((-1*P1));
[Y1pY, Y1pX] = findpeaks(Y1); [Y1vY, Y1vX] = findpeaks((-1*Y1));
R1vY = -R1vY; P1vY = -P1vY; Y1vY = -Y1vY;

[R2pY, R2pX] = findpeaks(R2); [R2vY, R2vX] = findpeaks((-1*R2));
[P2pY, P2pX] = findpeaks(P2); [P2vY, P2vX] = findpeaks((-1*P2));
[Y2pY, Y2pX] = findpeaks(Y2); [Y2vY, Y2vX] = findpeaks((-1*Y2));
R2vY = -R2vY; P2vY = -P2vY; Y2vY = -Y2vY;

R1P1 = [time(R1pX),R1pY]; R1P2 = [time(R1vX), R1vY]; R1Phase = [R1P1; R1P2];
% R1Phase = sortrows(R1Phase,1);
P1P1 = [time(P1pX),P1pY]; P1P2 = [time(P1vX), P1vY]; P1Phase = [P1P1; P1P2];
% P1Phase = sortrows(P1Phase,1);
Y1P1 = [time(Y1pX),Y1pY]; Y1P2 = [time(Y1vX), Y1vY];  Y1Phase = [Y1P1; Y1P2];
% Y1Phase = sortrows(Y1Phase,1);

R2P1 = [time(R2pX),R2pY]; R2P2 = [time(R2vX), R2vY]; R2Phase = [R2P1; R2P2];
% R2Phase = sortrows(R2Phase,1);
P2P1 = [time(P2pX),P2pY]; P2P2 = [time(P2vX), P2vY]; P2Phase = [P2P1; P2P2];
% P2Phase = sortrows(P2Phase,1);
Y2P1 = [time(Y2pX),Y2pY]; Y2P2 = [time(Y2vX), Y2vY]; Y2Phase = [Y2P1; Y2P2];
% Y2Phase = sortrows(Y2Phase,1);



figure
subplot(3,1,1)
plot(time, [R1, R2])
hold on
plot(R1Phase(:,1), R1Phase(:,2), 'r*'); 
plot(R2Phase(:,1), R2Phase(:,2), 'c*'); 
title('Roll'); xlabel('time'); ylabel('angle (degrees)');
legend('Chip1', 'Chip2');

subplot(3,1,2)
plot(time, [P1, P2])
hold on
plot(P1Phase(:,1), P1Phase(:,2), 'r*'); 
plot(P2Phase(:,1), P2Phase(:,2), 'c*');
title('Pitch'); xlabel('time'); ylabel('angle (degrees)');
legend('Chip1', 'Chip2');

subplot(3,1,3)
plot(time, [Y1, Y2])
hold on
plot(Y1Phase(:,1), Y1Phase(:,2), 'r*'); 
plot(Y2Phase(:,1), Y2Phase(:,2), 'c*');
title('Yaw'); xlabel('time'); ylabel('angle (degrees)');
legend('Chip1', 'Chip2');

% RollLag = R1Phase(:,1) - R2Phase(:,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delete 1st peak of Chip1 if C1 fitst peak comes before Chip2 first peak
% Want to be sure C2 (body) starts of leading C1
if abs(P1P1(1,1)) < abs(P2P1(1,1))
    P1P1(1,:) = [];
else
end
    if abs(P1P2(1,1)) < abs(P2P2(1,1))
        P1P2(1,:) = [];
    else
    end
if abs(Y1P1(1,1)) < abs(Y2P1(1,1))
    Y1P1(1,:) = [];
else
end
    if abs(Y1P2(1,1)) < abs(Y2P2(1,1))
        Y1P2(1,:) = [];
    else
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if vectors are the same length and delete last peak if one is 
% greater then the other
if length(P1P1) > length(P2P1)
    P1P1 = P1P1(1:length(P2P1),:);
elseif length(P2P1) > length(P1P1)
    P2P1 = P2P1(1:length(P1P1),:);
else    
end
    if length(P1P2) > length(P2P2)
        P1P2 = P1P2(1:length(P2P2),:);
    elseif length(P2P2) > length(P1P2)
        P2P2 = P2P2(1:length(P1P2),:);
    else    
    end
if length(Y1P1) > length(Y2P1)
    Y1P1 = Y1P1(1:length(Y2P1),:);
elseif length(Y2P1) > length(Y1P1)
    Y2P1 = Y2P1(1:length(Y1P1),:);
else    
end
    if length(Y1P2) > length(Y2P2)
        Y1P2 = Y1P2(1:length(Y2P2),:);
    elseif length(Y2P2) > length(Y1P2)
        Y2P2 = Y2P2(1:length(Y1P2),:);
    else    
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute lag
PitchLag1 = P1P1(:,1) - P2P1(:,1);
PitchLag2 = P1P2(:,1) - P2P2(:,1);
YawLag1 = Y1P1(:,1) - Y2P1(:,1);
YawLag2 = Y1P2(:,1) - Y2P2(:,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set outputs
% Lags = [[PitchLag1, PitchLag2], [YawLag1, YawLag2]];
Phase1.roll = R1Phase; Phase1.pitch = P1Phase; Phase1.yaw = Y1Phase;
Phase2.roll = R2Phase; Phase2.pitch = P2Phase; Phase2.yaw = Y2Phase;

% PhaseInfo.Lags = Lags; 
PhaseInfo.PPLags = PitchLag1;
PhaseInfo.PVLags = PitchLag2;
PhaseInfo.YPLags = YawLag1;
PhaseInfo.YVLags = YawLag2;
PhaseInfo.Phase1 = Phase1;
PhaseInfo.Phase2 = Phase2;

end

