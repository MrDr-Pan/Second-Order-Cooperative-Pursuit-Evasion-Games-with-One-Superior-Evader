clc
clear 

close all
load(".\data_v\data_6.mat");
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
fig=figure(1);
scatter(-X_plot,Y_plot,'DisplayName','QAC','Marker','.','MarkerEdgeColor','g');
hold on
scatter(-R_1_0(1),R_1_0(2),'DisplayName','Initial postion of the pursuer','MarkerEdgeColor','r');
scatter(-R_2_0(1),R_2_0(2),'DisplayName','Initial postion of the evader','MarkerEdgeColor','b');
legend
axis square

set(gca,'LooseInset', get(gca,'TightInset'))
% set(gcf,'unit','normalized','position',[0.2,0.2,0.64,0.32])
% get(gca,'position')
% set(fig,'position', [left bottom ax_width ax_height]);
get(fig,'position')
set(fig,'position', [573.0000  438.0000  468.6667  420.0000]);
xlabel('x');
ylabel('y');
box on
% set(gca,'position', [573,438,383.3333333333333,430]);
% set(gca,'position', [left bottom ax_width ax_height]);
% set(gca,'unit','centimeters','position',[2,2,10,10]);

% saveas(gcf, 'QAC_v_2.eps');