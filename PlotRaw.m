function PlotRaw(var, n, t1, t_length)
%Plot raw data
%var: saved variable (cell)
%n: # of var's row which you wnat to see the trace
%



t = var{n}(:,1);
d = var{n}(:,2);

sampf =  30000;
range1 = t_length*sampf;

%paper settings
figure;

width = 1024;
height = 768;
set(gcf, 'PaperPositionMode', 'auto')
pos = get(gcf, 'Position');
pos(3) = width-1;
pos(4) = height;
set(gcf, 'Position', pos, 'PaperOrientation','landscape');
%
for i = 1:4
    subplot(4,1,i);
    range = range1*(i-1)+t1 : range1*i;
    plot(t(range), d(range))
    ax = gca;
    xlim([t(range(1)), t(range(end))])
    ylim([min(d(range)), max(d(range))])
    
    setax(i, ax);
    
    
    %pos
    if i == 1
        outerpos = ax.OuterPosition;
        ti = ax.TightInset;
        left = outerpos(1) + ti(1);
        bottom = outerpos(2) + ti(2);
        ax_width = outerpos(3) - ti(1) - ti(3);
        ax_height = outerpos(4) - ti(2) - ti(4);
        ax.Position = [left bottom ax_width ax_height];
    else
        outerpos = ax.OuterPosition;
        bottom = outerpos(2) + ti(2);
        ax_height = outerpos(4) - ti(2) - ti(4);
        ax.Position = [left bottom ax_width ax_height];
    end
end
    
    %% set x label
    function setax(ii, ax1)
    ax1.XTickMode = 'manual';
    t_range = t(range);
    tickpos = 1:sampf*0.1:range1; % every 100 ms
    ax1.XTick =t_range(tickpos);
    ax1.XTickLabel = [0:0.1:0.9]+(ii-1);
    end
end