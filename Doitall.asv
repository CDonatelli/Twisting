function [ TrialData ] = Doitall(timeMat, GravH5, Dist )
% Input Variables
% timeMat = matrix of the time during the trial when steady swimming starts
%           h5 files are saved up to -90 seconds but steady swimming will
%           only occur during the last x seconds. This is a matrix of these
%           x values
% GravH5 = this is the name of the h5 calibration file. The file is created
%          by holding the fish steady (while asleep) for 3-5 seconds to
%          establish the direction of gravity
% Dist = This is the x distance between the two chips which can be measured
%        from the still images taken of the fish during surgery

% Get the directory containing the h5 trial files and create a list of all
% files in the directory. The directory can only contain the h5 files you
% wish to run throigh the script
Directory = uigetdir;
List = dir(Directory);
[m n] = size(List);

% Go through each file and get the information we need. A sub structure
% will be created for each file. You will have to sort by speeds later.
% Sorry future Cassandra. I know you're going to be annoyed
for i = 1:m
    TrialH5 = List(i).name;
    time = timeMat(i);
    
    % naming
    u = strfind(TrialH5, '_'); h = strfind(TrialH5, '.h5');
    Name = TrialH5; Name([u,h]) = [];
    
    [Chip1 Chip2 WaveInfo] = cassandraschristmas(TrialH5, GravH5, time);
    % Save the raw orientation file
    TrialData(Name).C1Orient = WaveInfo.C1orient;
    TrialData(Name).C2Orient = WaveInfo.C2orient;
    
    % Save the Roll Pitch and Yaw peaks and valleys
    TrialData.(Name).C1Roll = WaveInfo.C1Roll;
    TrialData.(Name).C2Roll = WaveInfo.C2Roll;
    TrialData.(Name).C1Pitch = WaveInfo.C1Pitch;
    TrialData.(Name).C2Pitch = WaveInfo.C2Pitch;
    TrialData.(Name).C1Yaw = WaveInfo.C1Yaw;
    TrialData.(Name).C2Yaw = WaveInfo.C2Yaw;
    
    TrialData.(Name).bodyroll = [mean(WaveInfo.C2Roll), std(WaveInfo.C2Roll)];
    WS = [WaveInfo.PPLags; WaveInfo.PVLags];
    % Wavespeed in cm/s
    TrialData.(Name).wavespeed = Dist/mean(WS);
    % Tail Beat Frequency (TBF) in beats per second
    TrialData.(Name).TBF = length(WaveInfo.C1Yaw(:,1))/time;
    TrialData.(Name).pitchLag = [WaveInfo.PPLags; PVLags];
    TrialData.(Name).yawLag = [WaveInfo.YPLags; WaveInfo.YVLags];
        
        Rpeaks = WaveInfo.C1Roll(:,1);
%         Rvals = WaveInfo.C1Roll(:,3);
    for j = 2:length(WaveInfo.C1Roll(:,1))
        peakDist = Rpeaks(i) - Rpeaks(i-1);
%         valDist = Rvals(i) - Rvals(i-1);
    end
%         Rspeed = [peakDist; valDist];
    % Roll Speed (frequency of one roll cycle) in rolls per second
    TrialData.(Name).rollSpeed = [1/mean(peakDist), std(peakDist)];
end

end
    