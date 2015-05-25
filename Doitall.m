function [ TrialData, newTimeMat ] = Doitall(timeMat, GravH5, Dist, speeds)
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
num = input('What is the number of the bluegull you ran? : ');
Directory = uigetdir;
List = dir(Directory);
List = List(3:end);
[m n] = size(List);

% Go through each file and get the information we need. A sub structure
% will be created for each file. You will have to sort by speeds later.
% Sorry future Cassandra. I know you're going to be annoyed

for i = 1:m
    TrialH5 = List(i).name;
    time = timeMat(i);
    Trials{i} = TrialH5;
    
    % naming
    u = strfind(TrialH5, '_');
    Name = TrialH5; Name(u) = []; Name(end-2:end) = [];
    Names{i} = Name;
    % finding speed
    Speed = Name; Speed(1:4) = []; Speed(end-4:end) = [];
    if length(Speed) > 2
        Speed = str2num(Speed);
        Speed = Speed/10;
    else
        Speed = str2num(Speed);
    end
    
    TrialData.(Name).Speed = Speed;
    
    [Chip1, Chip2, WaveInfo, Ntime] = cassandraschristmas(TrialH5, GravH5, time);
    % Save the raw orientation file
    time = Ntime; timeMat(i) = Ntime;
    TrialData.(Name).C1Orient = WaveInfo.C1Orient;
    TrialData.(Name).C2Orient = WaveInfo.C2Orient;
    TrialData.(Name).C1Corrected = WaveInfo.C1Corrected;
    TrialData.(Name).C2Corrected = WaveInfo.C2Corrected;
    TrialData.(Name).t = WaveInfo.t;

    % Save the Roll Pitch and Yaw peaks and valleys
    % Pitch and Yaw switched to compensate for chip orientation
    TrialData.(Name).C1Roll = WaveInfo.C1Roll;
    TrialData.(Name).C2Roll = WaveInfo.C2Roll;
    TrialData.(Name).C1Pitch = WaveInfo.C1Yaw;
    TrialData.(Name).C2Pitch = WaveInfo.C2Yaw;
    TrialData.(Name).C1Yaw = WaveInfo.C1Pitch;
    TrialData.(Name).C2Yaw = WaveInfo.C2Pitch;
    
    TrialData.(Name).bodyroll = [mean(WaveInfo.C2Roll), std(WaveInfo.C2Roll)];
    WS = [WaveInfo.PPLags; WaveInfo.PVLags];
    % Wavespeed in cm/s
    TrialData.(Name).wavespeed = Dist/mean(WS);
    % Tail Beat Frequency (TBF) in beats per second
    TrialData.(Name).TBF = length(WaveInfo.C1Pitch(:,1))/ ...
        (WaveInfo.C1Pitch(end,1) - WaveInfo.C1Pitch(1,1));
    TrialData.(Name).pitchLag = [WaveInfo.YPLags; WaveInfo.YVLags];
    TrialData.(Name).yawLag = [WaveInfo.PPLags; WaveInfo.PVLags];
        
        Rpeaks = WaveInfo.C1Roll(:,1);
%         Rvals = WaveInfo.C1Roll(:,3);
    for j = 2:length(WaveInfo.C1Roll(:,1))
        peakDist = Rpeaks(j) - Rpeaks(j-1);
%         valDist = Rvals(i) - Rvals(i-1);
    end
%         Rspeed = [peakDist; valDist];
    % Roll Speed (frequency of one roll cycle) in rolls per second
    TrialData.(Name).rollSpeed = [1/mean(peakDist), std(peakDist)];
    
    
end

newTimeMat = timeMat;

% Sorting Trials

for i = 1:length(speeds)
    Speeds{i} = num2str(speeds(i));
end
Speeds = strrep(Speeds, '.', '_');
for i = 1:length(Speeds)
    Speeds{i} = [num2str(num),'_', Speeds{i}];
end
for i = 1:length(Speeds)
    Sort = strfind(Trials, Speeds{i});
    ind = find(~cellfun(@isempty,Sort));
    for j = 1:length(ind)
        TrialData2.(['BG',Speeds{i}]).(Names{ind(j)}) = getfield(TrialData, Names{ind(j)});
    end
end

TrialData = TrialData2;

end


    