function MainRecDAQ

close all
global s Ch capture dataListener errorListener hGui captNum

% initialize parameters
[s, Ch, capture] = setDAQsession;
captNum = 0;

% open GUI
hGui = createUI(s);

% Add a listener for DataAvailable events
dataListener = addlistener(s, 'DataAvailable', @(src, event) dataCapture(src, event, capture, hGui));
errorListener = addlistener(s, 'ErrorOccurred', @(src, event) disp(getReport(event.Error)));

s.IsContinuous = true;
startBackground(s);

while s.IsRunning
    pause(0.5);
end


disp('Stop')

%% nested functions


end % end of MainRecDAQ


%% %%%%%%%%%%%%%%%%%%%%  subfunctions %%%%%%%%%%%%%%%%%%%% %%

function [s, Ch, capture] = setDAQsession

if exist('daq', 'file')==7
    s = daq.createSession('ni');
    
    % Device ID setting
    Ch = addAnalogInputChannel(s, 'Dev1', 0, 'Voltage');
    Ch.TerminalConfig = 'Differential';
    Ch.Range = [-1.0, 1.0];
    Ch.Coupling = 'DC';
    
    s.Rate = 30000; %sampling rate 30K
    s.DurationInSeconds = 2;
    %s.NotifyWhenDataAvailableExceeds = s.Rate * s.DurationInSeconds / 10;
    
    %
    capture.TimeSpan = 5;
    capture.plotTimeSpan = 2;
    callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;
    capture.bufferTimeSpan = max([capture.plotTimeSpan, capture.TimeSpan*2, callbackTimeSpan*3]);
    capture.bufferSize = round(capture.bufferTimeSpan * s.Rate);
    
else
    s = 0;
    Ch = 0;
    capture.TimeSpan = 5;
    capture.plotTimeSpan = 5;
end

end

%%
function hGui = createUI(s)
%Create GUI and configure callback functions
% "s" is DAQ session

hGui.Fig = figure('NumberTitle', 'off', 'Resize', 'off', 'Position', [10 200 1000 650],...
    'DeleteFcn', {@endDAQ, s});

%Create the continous data plot axes
%(one line per acquisition channel)
hGui.Axes1 = axes('Units', 'Pixels', 'Position', [400 420 580 200]);
hGui.LivePlot = plot(0, zeros(1, numel(s.Channels)));
xlabel('Time (s)');
ylabel('Voltage (mV)');
title('Live Plot');

%Create the capture data plot axes
%(one line per acquisition channle)
hGui.Axes2 = axes('Units', 'Pixels', 'Position', [400 150 580 200]);
hGui.CapturePlot = plot(NaN, NaN(1, numel(s.Channels)));
xlabel('Time (s)');
ylabel('Voltage (mv)');
title('Captured Data');

% Edit Field
%
% Select Sampling rate
hGui.txtSampleRate = uicontrol('Style', 'Text', 'String', 'Sample Rate (Hz):', 'Position', [10 500 100 25],...
    'HorizontalAlignment', 'Right');
hGui.SampleRate = uicontrol('Style', 'Edit', 'String', s.Rate , 'Units','Pixels', 'Position', [120 500 100 30]);

% Set Duration (live plot)
hGui.txtLiveDuration = uicontrol('Style', 'Text', 'String', 'Live Duration (s):', 'Position', [10 460 100 25],...
    'HorizontalAlignment', 'Right');
hGui.LiveDuration = uicontrol('Style', 'Edit', 'String', '2', 'Units','Pixels', 'Position', [120 460 100 30]);


% Select Channel for Trigger
hGui.txtTrigChannel = uicontrol('Style', 'Text', 'String', 'Trig Channel:', 'Position', [10 360 100 25],...
    'HorizontalAlignment', 'Right');
hGui.TrigChannel = uicontrol('Style', 'Text', 'String', 'Ch(1)', 'Units','Pixels', 'Position', [120 355 100 30]);

% Trigger Level (Threshold)
hGui.txtTrigLevel = uicontrol('Style', 'Text', 'String', 'Trig Level (mV):', 'Position', [10 320 100 25],...
    'HorizontalAlignment', 'Right');
hGui.TrigLevel = uicontrol('Style', 'Edit', 'String', '1', 'Units','Pixels', 'Position', [120 320 100 30]);

% Trig Slope
hGui.txtTrigSlope = uicontrol('Style', 'Text', 'String', 'Trig Sloe (V/s):', 'Position', [10 280 100 25],...
    'HorizontalAlignment', 'Right');
hGui.TrigSlope = uicontrol('Style', 'Edit', 'String', '200', 'Units','Pixels', 'Position', [120 280 100 30]);

% default setting: mydata
hGui.txtVarName = uicontrol('Style', 'Text', 'String', 'Variable Name:', 'Position', [10 240 100 25],...
    'HorizontalAlignment', 'Right');
hGui.VarName = uicontrol('Style', 'Edit', 'String', 'mydata', 'Units','Pixels', 'Position', [120 240 100 30]);

% Set capture start timing (ms from the trigger timing)
hGui.txtCapturePreTrig = uicontrol('Style', 'Text', 'String', 'Capture Pre-Trig Duration (s):', 'Position', [10 200 100 25],...
    'HorizontalAlignment', 'Right');
hGui.CapturePreTrig = uicontrol('Style', 'Edit', 'String', '0', 'Units','Pixels', 'Position', [120 200 100 30]);

% Set capture Duration
hGui.txtCaptureDuration = uicontrol('Style', 'Text', 'String', 'Capture Post-Trig Duration (s):', 'Position', [10 160 100 25],...
    'HorizontalAlignment', 'Right');
hGui.CaptureDuration = uicontrol('Style', 'Edit', 'String', '5', 'Units','Pixels', 'Position', [120 160 100 30]);

% Buttons

%Stop Button
hGui.stopDAQButton = uicontrol('Style', 'Pushbutton', 'String', 'Pause', 'Units', 'Pixels', 'FontSize', 14,...
    'Position', [10 550 100 50], 'Callback', {@pauseDAQ, s, hGui});

%Capture Button(green) -> Waiting(yello) -> Triggerd(blue) ->Capture
%(green)
hGui.CaptureButton = uicontrol('Style', 'Togglebutton', 'String', 'Capture', 'Units', 'Pixels', 'FontSize', 14,...
    'Position', [230 550 100 50], 'Callback', {@startCapture, hGui}, 'BackgroundColor', 'g');

%Start Button
hGui.startDAQButton = uicontrol('Style', 'Pushbutton', 'String', 'Start', 'Units', 'Pixel', 'FontSize', 14,...
    'Position', [120 550 100 50], 'Callback', {@startDAQ, hGui});

%Save Button
hGui.save = uicontrol('Style', 'Pushbutton', 'String', 'Save Vars', 'FontSize', 14,...
    'Position', [10, 20, 100 50], 'Callback', {@saveVars, hGui});
end % end of createUI

%%
function startCapture(hObject, ~, hGui)
global captNum
captNum = captNum + 1;
if get(hObject, 'value')
    for ii = 1:numel(hGui.CapturePlot)
        set(hGui.CapturePlot(ii), 'XData', NaN, 'YData', NaN);
    end
end
end

%%
function pauseDAQ(~, ~, s, hGui)
global dataListener errorListener

set(hGui.SampleRate,'Style', 'Edit', 'Position', [120 500 100 30]);
set(hGui.LiveDuration,'Style', 'Edit', 'Position', [120 460 100 30]);

%set(hGui.TrigChannel,'Style', 'Edit', 'Position', [120 355 100 30]);
set(hGui.TrigLevel,'Style', 'Edit', 'Position', [120 320 100 30]);
set(hGui.TrigSlope,'Style', 'Edit', 'Position', [120 280 100 30]);
set(hGui.VarName,'Style', 'Edit', 'Position', [120 240 100 30]);
set(hGui.CapturePreTrig,'Style', 'Edit', 'Position', [120 200 100 30]);
set(hGui.CaptureDuration,'Style', 'Edit', 'Position', [120 160 100 30]);

if isvalid(s)
    if s.IsRunning
        stop(s);
    end
end


delete(dataListener);
delete(errorListener);
end

%%
function startDAQ(~, ~, hGui)
global s capture dataListener errorListener

% GUI
set(hGui.SampleRate,'Style', 'Text', 'Position', [120 495 100 30]);
set(hGui.LiveDuration,'Style', 'Text', 'Position', [120 455 100 30]);

%set(hGui.TrigChannel,'Style', 'Text', 'Position', [120 355 100 30]);
set(hGui.TrigLevel,'Style', 'Text', 'Position', [120 315 100 30]);
set(hGui.TrigSlope,'Style', 'Text', 'Position', [120 275 100 30]);
set(hGui.VarName,'Style', 'Text', 'Position', [120 235 100 30]);
set(hGui.CapturePreTrig,'Style', 'Text', 'Position', [120 195 100 30]);
set(hGui.CaptureDuration,'Style', 'Text', 'Position', [120 155 100 30]);


if s.IsRunning == false
    %% Reload params from GUI
    if s.IsContinuous
        s.IsContinuous = false;
    end
    s.Rate = str2double(get(hGui.SampleRate,'String'));
    s.DurationInSeconds = str2double(get(hGui.LiveDuration, 'String'));
    capture.TimeSpan = str2double(get(hGui.CaptureDuration, 'String'))...
        + str2double(get(hGui.CapturePreTrig,'string'));
    capture.plotTimeSpan = str2double(get(hGui.LiveDuration, 'String'));
        
    callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;
    capture.bufferTimeSpan = max([capture.plotTimeSpan, capture.TimeSpan * 2, callbackTimeSpan * 3]);
    capture.bufferSize = round(capture.bufferTimeSpan * s.Rate);
    
    disp(capture.TimeSpan);
    disp(capture.bufferSize)
    
    %% Restart
    dataListener = addlistener(s, 'DataAvailable', @(src, event) dataCapture(src, event, capture, hGui));
    errorListener = addlistener(s, 'ErrorOccurred', @(src, event) disp(getReport(event.Error)));
    s.IsContinuous = true;
    startBackground(s);
    
    while s.IsRunning
        pause(0.5);
    end
end
end

%%
function endDAQ(~, ~, s)
global dataListener errorListener
if isvalid(s)
    if s.IsRunning
        stop(s);
    end
    
    delete(dataListener);
    delete(errorListener);
    delete(s);
end

end

%%
function saveVars(~, ~, hGui)
%Save captureed data to the mat file
savedata = evalin('base', get(hGui.VarName, 'String'));
save(get(hGui.VarName, 'String'), 'savedata');
end

%%
function dataCapture(src, event, c, hGui)
global captNum
persistent dataBuffer trigActive trigMoment varCell

if event.TimeStamps(1)==0
    dataBuffer = [];          % data buffer
    trigActive = false;       % trigger condition flag
    trigMoment = [];          % data timestamp when trigger condition met
    prevData = [];            % last data point from previous callback execution
else
    prevData = dataBuffer(end, :);
end

%event.Data is show in mV
latestData = [event.TimeStamps, event.Data*1000];

%dataBuffer‚µ‚Ä‚¨‚¢‚Ä Trigger point ‚³‚ª‚·
dataBuffer = [dataBuffer; latestData];
numSamplesToDiscard = size(dataBuffer,1) - c.bufferSize;

%Updating buffer data
if (numSamplesToDiscard > 0)
    dataBuffer(1:numSamplesToDiscard, :) = [];
end

% update live plot
samplesToPlot = min([round(c.plotTimeSpan * src.Rate), size(dataBuffer,1)]);
firstPoint = size(dataBuffer, 1) - samplesToPlot + 1;

% update x-axis
xlim(hGui.Axes1, [dataBuffer(firstPoint, 1), dataBuffer(end, 1)]);

% Live plot has one line for each acquisition channel
for ii = 1:numel(hGui.LivePlot)
    set(hGui.LivePlot(ii), 'XData', dataBuffer(firstPoint:end, 1),...s
        'YData', dataBuffer(firstPoint:end, 1+ii))
end

% Get capture toggle button condition (1/0)
captureRequested = get(hGui.CaptureButton, 'value');


if captureRequested && (~trigActive)
    set(hGui.CaptureButton, 'String', 'Waiting', 'BackgroundColor', 'y');
    
    trigConfig.Channel = 1; %sscanf(get(hGui.TrigChannel, 'String'), '%u');
    trigConfig.Level = sscanf(get(hGui.TrigLevel, 'String'), '%f'); %mV
    trigConfig.Slope = sscanf(get(hGui.TrigSlope, 'String'), '%f'); %V/s
    
    [trigActive, trigMoment] = detectTrig(prevData, latestData, trigConfig);
    
elseif captureRequested && trigActive && ((dataBuffer(end,1)-trigMoment) > c.TimeSpan)
    pretrigDataPoint = sscanf(get(hGui.CapturePreTrig,'string'), '%f') * src.Rate;
    
    trigSampleIndex = find(dataBuffer(:,1) == trigMoment, 1, 'first') - pretrigDataPoint;
    lastSampleIndex = round(trigSampleIndex + c.TimeSpan * src.Rate);
    captureData = dataBuffer(trigSampleIndex:lastSampleIndex, :);
    captureData(:,2:end) = captureData(:,2:end);
    
    trigActive = false;
    
    for ii = 1:numel(hGui.CapturePlot)
        set(hGui.CapturePlot(ii),...
            'XData', captureData(:,1),...
            'YData', captureData(:, 1 + ii))
    end
    xlim(hGui.Axes2, [captureData(1,1), captureData(end,1)]);
    
    set(hGui.CaptureButton, 'Value', 0);
    
    varName = get(hGui.VarName, 'String');
    varCell{captNum} = captureData;
    assignin('base', varName, varCell);
    
elseif captureRequested && trigActive && ((dataBuffer(end,1)-trigMoment) < c.TimeSpan)
    set(hGui.CaptureButton, 'String', 'Triggered', 'BackgroundColor', 'b');
    
elseif ~captureRequested
    trigActive = false;
    set(hGui.CaptureButton, 'String', 'Capture', 'BackgroundColor', 'g')
    
end
drawnow;
end

%%
function [trigDetected, trigMoment] = detectTrig(prevData, latestData, trigConfig)
%check level
trigCondition1 = latestData(:, 1 + trigConfig.Channel) > trigConfig.Level;
data = [prevData; latestData];

%check slope
dt = latestData(2,1)-latestData(1,1);
slope = diff(data(:, 1+trigConfig.Channel))/dt;
trigCondition2 = slope > trigConfig.Slope;

if isempty(prevData)
    trigCondition2 = [false; trigCondition2];
end

%level and slope are used
trigCondition = trigCondition1 & trigCondition2;

trigDetected = any(trigCondition);
trigMoment = [];
if trigDetected
    % Find time moment when trigger condition has been met
    trigTimeStamps = latestData(trigCondition, 1);
    trigMoment = trigTimeStamps(1);
end
end