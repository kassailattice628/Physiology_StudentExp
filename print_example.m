sampf = 30000;  %sampling rate 30K
trange = 40; % show first 40 sec 

%%
time = savedata{1,5}(:,1);
y = savedata{1,5}(:,2);

total_p = length(time);
%%
%open figure;
figure;

width = 1024;
height = 768;
set(gcf, 'PaperPositionMode', 'auto')
pos = get(gcf, 'Position');
pos(3) = width-1;
pos(4) = height;
set(gcf, 'Position', pos, 'PaperOrientation','landscape');

%%

N = 3;
for i=1:N
    subplot(N, 1, i)
    plot(time((total_p*(i-1)/N+1): total_p*i/N), y(total_p*(i-1)/N +1: total_p*i/N));
    ax = gca;
    ax.XGrid = 'on';
    %ax.XMinorTick = 'on';
    ax.XTick = time(total_p*(i-1)/N+1: sampf/10: total_p*i/N);
    %ax.XTickLabel = (total_p*(i-1)/N+1:total_p*i/N);
    
    outerpos = ax.OuterPosition;
    ti = ax.TightInset;
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];
end

%% save fig %%
fig = gcf;


fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

print(fig,'MySavedFile','-dpdf')