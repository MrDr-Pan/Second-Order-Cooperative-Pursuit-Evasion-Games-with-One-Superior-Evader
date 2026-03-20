clc
clear 

for i=1:6
    name=num2str(i);
    close all
    loadname=['.\data_v\data_',name,'.mat'];
    load(loadname)
    v=data.v;
    a_2=data.aE;
    a_1=data.aP;
    L=data.L;
    theta=data.theta;
    R_1_0=data.R_1_0;
    R_2_0=data.R_2_0;
    X_plot=data.X_plot;
    Y_plot=data.Y_plot;

    close all
    fig=figure(1) ;
    scatter(-X_plot,Y_plot,'DisplayName','QAC','Marker','.','MarkerEdgeColor','g');
    hold on
    scatter(-R_1_0(1),R_1_0(2),'DisplayName','Initial postion of the pursuer','MarkerEdgeColor','r');
    scatter(-R_2_0(1),R_2_0(2),'DisplayName','Initial postion of the evader','MarkerEdgeColor','b');
    legend
    axis square
    % 完全去除间隔, 可能会去除掉边界的一些信息, 请检查后使用
    set(gca,'LooseInset', get(gca,'TightInset'))
    % set(gcf,'unit','normalized','position',[0.2,0.2,0.64,0.32])
    % get(gca,'position')
    % set(fig,'position', [left bottom ax_width ax_height]);
    get(fig,'position')
    set(fig,'position', [573.0000  438.0000  468.6667  420.0000]);
    
    savename=['QAC_v_',name,'.png'];
    saveas(gcf, savename);
end