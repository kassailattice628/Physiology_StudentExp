function PlotRaw(var, n, select_range, t_length, weight, savef)
%Plot raw data
%var: saved variable (cell)
%n: # of var's row which you wnat to see the trace
%select_range: select time range for showing in the figure or PS file
%([start, end]) (sec):
%t_length: time length for single row trace. (sec)
%savef: save flag. save multi-page PS file when savef=1)

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

%select range
if isempty(select_range)
    s_i = 1;
    e_i = length(t);
elseif length(select_range) == 2
    s_i = find(t < select_range(1), 1, 'last')+1;
    e_i = find(t < select_range(2), 1, 'last');
elseif length(select_range) == 1
    s_i = select_range;
    e_i = length(t);
end

t = t(s_i:e_i);
d = d(s_i:e_i);


%%
sampf =  1/(t(2)-t(1));
range1 = t_length*sampf;

range_p = range1*4;


%%

n_page = ceil((t(end) - t(1))/t_length/4);

figh = zeros(1, n_page);
for ii = 1:n_page %n_page
    
    figh(ii) = figure;
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
        range_plot = round(range_p*(ii-1) + (range1*(i-1)) + 1: range_p*(ii-1) + range1*i);
        if range_plot(end) > length(t)
            break
        end
        
        subplot(4,1,i);
        plot(t(range_plot), d(range_plot))
        ax = gca;
        xlim([t(range_plot(1)), t(range_plot(end))])
        ylim([min(d(range_plot)), max(d(range_plot))])
        
        setax(ax)%(i, ii, ax);
        
        
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
    
    fig = figure(figh(ii));
    fig.PaperPositionMode = 'auto';
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    
    if savef == 1
        if isnumeric(weight)
            weight = num2str(weight);
        end
        if ii == 1
            fname = ['Rawtrace_', weight, '_', num2str(t_length)];
            mkdir(fname);
        end
        %print(['./', fname, '/pdf', num2str(ii)], '-dpdf', '-fillpage');
        print(fname, '-dps2', '-append', '-fillpage')
        close;
    end
end

%% set x label
    function setax(ax1)%(i, ii, ax1)
        ax1.XTickMode = 'manual';
        t_range = t(range_plot);
        tickpos = round(1:sampf*0.1:range1); % every 100 ms
        ax1.XTick =t_range(tickpos);
        ax1.XTickLabel = [0:0.1:0.9]+(i-1) + (ii-1)*4;
    end



end


