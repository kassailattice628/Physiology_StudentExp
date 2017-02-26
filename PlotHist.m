function PlotHist(var, n, th, rectime, weight)

switch nargin
    case 5
        if isnumeric(weight)
            weight = num2str(weight);
        end
    case 4
        weight =  '' ;
end
%data
t = var{n}(:,1);
y = var{n}(:,2);

%find spikes
[~,ind] = findpeaks(y,'MinPeakHeight',th, 'MinPeakDistance',20);


%% paper settings
figure;

width = 1024;
height = 768;
set(gcf, 'PaperPositionMode', 'auto')
pos = get(gcf, 'Position');
pos(3) = width-1;
pos(4) = height;
set(gcf, 'Position', pos, 'PaperOrientation','landscape');

%% plot raw data
subplot(2,1,1)
plot(t, y);
xlim([t(1), t(end)]);
hold on;
plot(t(ind), th, 'm*');
hold off

ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

%% histogram
subplot(2,1,2)
histogram(t(ind), rectime);
xlim([t(1), t(end)]);
ax = gca;
outerpos = ax.OuterPosition;
bottom = outerpos(2) + ti(2);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

%% savefig
fig = gcf;


fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

if nargin ==  5
print(fig,['Histogram_',weight],'-dpdf')
end

end