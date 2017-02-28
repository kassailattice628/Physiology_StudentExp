function PlotRaw(var, n, t1, t_length, savef)
%Plot raw data
%var: saved variable (cell)
%n: # of var's row which you wnat to see the trace
%
%%
switch nargin
    case 4
        savef = 0;
    case 5
        if savef ~= 1
            savef =  0;
        end
end

if iscell(var)
    t = var{n}(:,1);
    d = var{n}(:,2);
else
    t=var(:,1);
    d=var(:,2);
end

%%
%sampf =  30000;
sampf =  1/(t(2)-t(1));
range1 = t_length*sampf;

range_p = range1*4;


%%

n_page = ceil((t(end) - t(1))/4);

for ii = 1:n_page %n_page
    figure;
    %paper settings-------------------------------------------
    width = 1024;
    height = 768;
    set(gcf, 'PaperPositionMode', 'auto')
    pos = get(gcf, 'Position');
    pos(3) = width-1;
    pos(4) = height;
    set(gcf, 'Position', pos, 'PaperOrientation','landscape');
    %---------------------------------------------------------
    
    for i = 1:4 %4 subplots are shown in a page pf PDF file.
        range_plot = round(range_p*(ii-1) + (range1*(i-1))+t1 : range_p*(ii-1) + range1*i);
        if range_plot(end) > length(t)
            break
        end
        
        subplot(4,1,i);
        plot(t(range_plot), d(range_plot))
        ax = gca;
        xlim([t(range_plot(1)), t(range_plot(end))])
        ylim([min(d(range_plot)), max(d(range_plot))])
        
        setax%(i, ii, ax);
        
        
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
    
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    
    if savef == 1
        fname = 'trace';
        print(fname, '-dps2', '-append')
        close;
    end
end
%% set x label
    function setax%(i, ii, ax1)
        ax1.XTickMode = 'manual';
        t_range = t(range_plot);
        tickpos = round(1:sampf*0.1:range1); % every 100 ms
        ax1.XTick =t_range(tickpos);
        ax1.XTickLabel = [0:0.1:0.9]+(i-1) + (ii-1)*4;
    end



end


