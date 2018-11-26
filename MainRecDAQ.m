function MainRecDAQ

close all
global s Ch capture hGui captNum

% initialize parameters
[s, Ch, capture] = setDAQsession;
%data#
captNum = 1;

% open GUI
hGui = createUI(s, capture);

end % end of MainRecDAQ


%% %%%%%%%%%%%%%%%%%%%%  subfunctions %%%%%%%%%%%%%%%%%%%% %%

%% DAQ setting
function [s, Ch, capture] = setDAQsession
%Default settings
if exist('daq', 'file') == 7
    s = daq.createSession('ni');
    
    % Device ID setting
    Ch = addAnalogInputChannel(s, 'Dev1', 0, 'Voltage');
    Ch.TerminalConfig = 'Differential';
    Ch.Range = [-5.0, 5.0];
    Ch.Coupling = 'DC';
    
    s.Rate = 15*1000; %sampling rate 15K
    disp(s)
    s.DurationInSeconds = 1;
    %%%% s.NotifyWhenDataAvailableExceeds = s.Rate * s.DurationInSeconds / 10;
    
    capture.plotTimeSpan = 2;   % Live Plot Duration
    
    capture.PreTrig = 1;
    capture.PostTrig = 10;
    capture.TimeSpan = capture.PreTrig + capture.PostTrig;    % Captured data duration (after trigger detected)
    
    callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;
    capture.bufferTimeSpan = max([capture.plotTimeSpan, capture.TimeSpan*2, callbackTimeSpan*3]);
    capture.bufferSize = round(capture.bufferTimeSpan * s.Rate);
    %}
    
else
    s = 0;
    Ch = 0;
    capture.TimeSpan = 5;
    capture.plotTimeSpan = 5;
end

end

%% GUI
function hGui = createUI(s, c)
% Create GUI, configure callback functions
% "s" is DAQ session
% "c" is data capture setting

%##########################################################################
% Maing Window
hGui.Fig = figure('NumberTitle', 'off', 'Resize', 'off', 'Position', [10 200 1000 650],...
    'DeleteFcn', {@endDAQ, s});


%##########################################################################
% Plot Field1
%continous data plot axes
hGui.Axes1 = axes('Units', 'Pixels', 'Position', [400 420 580 200]);
hGui.LivePlot = plot(0, zeros(1, numel(s.Channels)));
xlabel('Time (s)');
ylabel('Voltage (mV)');
title('Live Plot');

% Plot Field2
%Create the capture data plot axes
hGui.Axes2 = axes('Units', 'Pixels', 'Position', [400 150 580 200]);
hGui.CapturePlot = plot(NaN, NaN(1, numel(s.Channels)));
xlabel('Time (s)');
ylabel('Voltage (mv)');
title('Captured Data');


%##########################################################################
% Edit Params Field

%Sampling rate(Hz)
hGui.txtSampleRate = uicontrol('Style', 'Text', 'String', 'Sampling Rate (Hz):', 'Position', [10 500 100 25],...
    'HorizontalAlignment', 'Right');
hGui.SampleRate = uicontrol('Style', 'Edit', 'String', s.Rate , 'Units','Pixels', 'Position', [120 500 100 30]);

%Live plot Duration (s)
hGui.txtLiveDuration = uicontrol('Style', 'Text', 'String', 'Live Duration (s):', 'Position', [10 460 100 25],...
    'HorizontalAlignment', 'Right');
hGui.LiveDuration = uicontrol('Style', 'Edit', 'String', c.plotTimeSpan, 'Units','Pixels', 'Position', [120 460 100 30]);

%Y axis range (mV)
uicontrol('Style', 'Text', 'String', 'Live Y-axis (mV)', 'Position', [10 420 100 25], 'HorizontalAlignment', 'Right');
hGui.LiveYaxis = uicontrol('Style', 'Edit', 'String', 0, 'Position', [120 420 100 30]);
uicontrol('Style', 'Text', 'String', '0: Auto ylim', 'Position', [225 420 100 25], 'HorizontalAlignment', 'Left');


%###############################
% Trigger Channel (fixed)
hGui.txtTrigChannel = uicontrol('Style', 'Text', 'String', 'Trig Channel:', 'Position', [10 360 100 25],...
    'HorizontalAlignment', 'Right');
hGui.TrigChannel = uicontrol('Style', 'Text', 'String', 'Ch(1)', 'Units','Pixels', 'Position', [120 355 100 30]);

% Trigger Level (mV)
hGui.txtTrigLevel = uicontrol('Style', 'Text', 'String', 'Trig Level (mV):', 'Position', [10 320 100 25],...
    'HorizontalAlignment', 'Right');
hGui.TrigLevel = uicontrol('Style', 'Edit', 'String', 800, 'Units','Pixels', 'Position', [120 320 100 30]);

% Triger Slope (V/s)... not used for now...
hGui.txtTrigSlope = uicontrol('Style', 'Text', 'String', 'Trig Sloe (V/s):', 'Position', [10 280 100 25],...
    'HorizontalAlignment', 'Right');
hGui.TrigSlope = uicontrol('Style', 'Edit', 'String', 200, 'Units','Pixels', 'Position', [120 280 100 30]);
%hGui.TrigSlope = uicontrol('Style', 'Text', 'String', '------', 'Units','Pixels', 'Position', [120 280 100 30]);

% File name...default setting: mydata
hGui.txtVarName = uicontrol('Style', 'Text', 'String', 'Variable Name:', 'Position', [10 240 100 25],...
    'HorizontalAlignment', 'Right');
hGui.VarName = uicontrol('Style', 'Edit', 'String', 'Group_X', 'Units','Pixels', 'Position', [120 240 100 30]);

hGui.txtCaptNum = uicontrol('Style', 'Text', 'String', '#=:', 'Position', [225, 240, 50, 25], 'HorizontalAlignment', 'Left');

% Set capture start timing (ms from the trigger timing)
hGui.txtCapturePreTrig = uicontrol('Style', 'Text', 'String', 'Capture Pre-Trig Duration (s):', 'Position', [10 200 100 25],...
    'HorizontalAlignment', 'Right');
hGui.CapturePreTrig = uicontrol('Style', 'Edit', 'String', c.PreTrig, 'Units','Pixels', 'Position', [120 200 100 30]);

% Set capture Duration
hGui.txtCaptureDuration = uicontrol('Style', 'Text', 'String', 'Capture Post-Trig Duration (s):', 'Position', [10 160 100 25],...
    'HorizontalAlignment', 'Right');
hGui.CaptureDuration = uicontrol('Style', 'Edit', 'String', c.PostTrig, 'Units','Pixels', 'Position', [120 160 100 30]);

% Set Gain
hGui.txtGain = uicontrol('Style', 'Text', 'String', 'Amp Gain:', 'Position', [10 110 100 25],...
    'HorizontalAlignment', 'Right');
gain = {'X100', 'X200', 'X500', 'X1000', 'X2000', 'X5000', 'X10K', 'X20K', 'X50K', 'X100K'}; 
hGui.Gain = uicontrol('Style', 'popup', 'String', gain, 'Position', [120 110 100 30]);
set(hGui.Gain, 'Value', 4);

%##########################################################################
% Button Field

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

%PDF Button
hGui.printPDF = uicontrol('Style', 'Pushbutton', 'String', 'PDF', 'FontSize', 14,...
    'Position', [120, 20, 100, 50], 'callback', {@printPDF, hGui});

end % end of createUI


%% pause 
function pauseDAQ(~, ~, s, hGui)
global dataListener errorListener
%GUI
set(hGui.SampleRate,'Style', 'Edit', 'Position', [120 500 100 30]);
set(hGui.LiveDuration,'Style', 'Edit', 'Position', [120 460 100 30]);
set(hGui.LiveYaxis, 'Style', 'Edit', 'Position', [120 420 100 30]);
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

%% data capture
function startCapture(hObject, ~, hGui)
global captNum
captNum = captNum + 1;
if get(hObject, 'value')
    for ii = 1:numel(hGui.CapturePlot)
        set(hGui.CapturePlot(ii), 'XData', NaN, 'YData', NaN);
    end
end
end

%% run live
function startDAQ(~, ~, hGui)
global s capture dataListener errorListener

% GUI
set(hGui.SampleRate,'Style', 'Text', 'Position', [120 495 100 30]);
set(hGui.LiveDuration,'Style', 'Text', 'Position', [120 455 100 30]);
set(hGui.LiveYaxis, 'Style', 'Text', 'Position', [120 415 100 30]);
%set(hGui.TrigChannel,'Style', 'Text', 'Position', [120 355 100 30]);
set(hGui.TrigLevel,'Style', 'Text', 'Position', [120 315 100 30]);
set(hGui.TrigSlope,'Style', 'Text', 'Position', [120 275 100 30]);
set(hGui.VarName,'Style', 'Text', 'Position', [120 235 100 30]);
set(hGui.CapturePreTrig,'Style', 'Text', 'Position', [120 195 100 30]);
set(hGui.CaptureDuration,'Style', 'Text', 'Position', [120 155 100 30]);


if s.IsRunning == false
    % Reload params from GUI
    if s.IsContinuous
        s.IsContinuous = false;
    end
    s.Rate = str2double(get(hGui.SampleRate,'String'));
    
    capture.plotTimeSpan = str2double(get(hGui.LiveDuration, 'String'));
    capture.TimeSpan = str2double(get(hGui.CaptureDuration, 'String'))...
        + str2double(get(hGui.CapturePreTrig,'string'));
    callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;
    capture.bufferTimeSpan = max([capture.plotTimeSpan, capture.TimeSpan * 2, callbackTimeSpan * 3]);
    capture.bufferSize = round(capture.bufferTimeSpan * s.Rate);
    
    % Restart
    dataListener = addlistener(s, 'DataAvailable', @(src, event) dataCapture(src, event, capture, hGui));
    errorListener = addlistener(s, 'ErrorOccurred', @(src, event) disp(getReport(event.Error)));
    s.IsContinuous = true;
    startBackground(s);
    
    while s.IsRunning
        pause(0.5);
    end
end
end

%% Window close fcn
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

%% Save Data
function saveVars(~, ~, hGui)
%Save captureed data to the mat file

savedata = evalin('base', get(hGui.VarName, 'String'));

%cell is saved as [hGui.VarName].mat.
%Opening this mat file, 'savedata' is loaded as the base workspace
save(get(hGui.VarName, 'String'), 'savedata');

save SaveVars.mat savedata
end

%% Export figure to PDF file
function printPDF(~, ~, hGui)
global captNum

savedata = evalin('base', get(hGui.VarName, 'String'));

duration = get(hGui.CaptureDuration, 'string');
PlotRaw(savedata, captNum, 1, str2double(duration), ['', num2str(captNum)], 1)

end



%%#######################################################################%%
%% Capture data event

function dataCapture(src, event, c, hGui)
%dataCapture is called when DAQ data are readable.

global captNum
persistent dataBuffer trigActive trigMoment varCell

%reset bufferd data
if event.TimeStamps(1)==0
    dataBuffer = [];          % data buffer
    trigActive = false;       % trigger condition flag
    trigMoment = [];          % data timestamp when trigger condition met
    prevData = [];            % last data point from previous callback execution
else
    prevData = dataBuffer(end, :);
end

%event.Data is shown in mV (event.Data is multiplied by 1000)
g = get(hGui.Gain, 'Value');
gain = [100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000];
latestData = [event.TimeStamps, event.Data * gain(g)];

%Update dataBuffer
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
ymax = str2double(get(hGui.LiveYaxis, 'String'));
if ymax==0
    ylim(hGui.Axes1, 'auto')
else
    ylim(hGui.Axes1, [-ymax ymax]);
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
    captureData(:, 2:end) = captureData(:, 2:end);
    
    trigActive = false;
    
    for ii = 1:numel(hGui.CapturePlot)
        set(hGui.CapturePlot(ii),...
            'XData', captureData(:,1),...
            'YData', captureData(:, 1 + ii))
    end
    xlim(hGui.Axes2, [captureData(1,1), captureData(end,1)]);
    
    set(hGui.CaptureButton, 'Value', 0);
    
    %save captured data in the base WS.
    varName = get(hGui.VarName, 'String');
    varCell{captNum} = captureData;
    %captured data is shown in the base workspace 
    assignin('base', varName, varCell);
    
    %save captured data in the DISK (as a single .mat file)
    fname = [varName, '_', num2str(captNum), '.mat'];
    save(fname, 'captureData');
    
    set(hGui.txtCaptNum, 'String', ['#=:' num2str(captNum)]);
    
elseif captureRequested && trigActive && ((dataBuffer(end,1)-trigMoment) < c.TimeSpan)
    %Wait for sufficient number of data points are stored.
    set(hGui.CaptureButton, 'String', 'Triggered', 'BackgroundColor', 'b');
    
elseif ~captureRequested
    trigActive = false;
    set(hGui.CaptureButton, 'String', 'Capture', 'BackgroundColor', 'g')
    
end
drawnow;
end

%% Detect triger event
function [trigDetected, trigMoment] = detectTrig(prevData, latestData, trigConfig)
%check signal level
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