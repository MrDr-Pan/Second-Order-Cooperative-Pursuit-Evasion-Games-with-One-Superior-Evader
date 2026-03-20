clear 
clc
close all

v=0.5;
theta=15/180*pi; 

R_1_0=[-10,0]';
a_1=0.03;


V_2_0=[-0,-0]';
R_2_0=[0,0]';
a_2=0.04;

%%
V_1_0=v*[cos(theta),sin(theta)]';
% R_1_0=[-10,0]';
% a_1=0.03;
% 
% 
% V_2_0=[-0,-0]';
% R_2_0=[0,0]';
% a_2=0.4;


step_num=2000;
time_step=0.01;

X_plot=[];
Y_plot=[];

X_relative_plot=[];
Y_relative_plot=[];

tic
for i=1:step_num
    syms x y
    t=time_step*(i-1);
    r_1=0.5*a_1*t^2;
    r_2=0.5*a_2*t^2;
    R_1=R_1_0+V_1_0*t;
    R_2=R_2_0+V_2_0*t;
    if norm(R_1-R_2)<=r_1+r_2 && norm(R_1-R_2)>=r_1-r_2 && norm(R_1-R_2)>=r_2-r_1
        a1=R_1(1);b1=R_1(2);r1=r_1;
        a2=R_2(1);b2=R_2(2);r2=r_2;
%         [x,y]=solve((x-a1)^2+(y-b1)^2-r1^2,(x-a2)^2+(y-b2)^2-r2^2);
        
        
        [x,y]=cross_points_of_two_circles(a1, b1, r1, a2, b2, r2);
        X_plot=[X_plot;x];
        Y_plot=[Y_plot;y];
        X_relative_plot=[X_relative_plot;x-a2];
        Y_relative_plot=[Y_relative_plot;y-b2];
    end
    

end
X_plot=reshape(X_plot,[length(X_plot)*2,1]);
Y_plot=reshape(Y_plot,[length(Y_plot)*2,1]);
X_relative_plot=reshape(X_relative_plot,[length(X_relative_plot)*2,1]);
Y_relative_plot=reshape(Y_relative_plot,[length(Y_relative_plot)*2,1]);

toc

% close all
figure(1)
scatter(X_plot,Y_plot,'DisplayName','ApolloniusXY','Marker','.','MarkerEdgeColor','g');
hold on
scatter(R_1_0(1),R_1_0(2),'DisplayName','追击星初始位置','MarkerEdgeColor','r');
scatter(R_2_0(1),R_2_0(2),'DisplayName','逃逸星初始位置','MarkerEdgeColor','b');
legend
axis square

figure(2)
scatter(X_relative_plot,Y_relative_plot,'DisplayName','ApolloniusXY','Marker','.','MarkerEdgeColor','g');
hold on
scatter(R_1_0(1),R_1_0(2),'DisplayName','追击星初始位置','MarkerEdgeColor','r');
scatter(R_2_0(1),R_2_0(2),'DisplayName','逃逸星初始位置','MarkerEdgeColor','b');
legend
axis square

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

V_1_0=v*[0,sin(theta)]';
% R_1_0=[-10,0]';
% a_1=0.3;
% 
% 
% V_2_0=[-0,-0]';
% R_2_0=[0,0]';
% a_2=0.4;


step_num=8000;
time_step=0.01;

X_plot=[];
Y_plot=[];

X_relative_plot=[];
Y_relative_plot=[];

tic
for i=1:step_num
    syms x y
    t=time_step*(i-1);
    r_1=0.5*a_1*t^2;
    r_2=0.5*a_2*t^2;
    R_1=R_1_0+V_1_0*t;
    R_2=R_2_0+V_2_0*t;
    if norm(R_1-R_2)<=r_1+r_2 && norm(R_1-R_2)>=r_1-r_2 && norm(R_1-R_2)>=r_2-r_1
        a1=R_1(1);b1=R_1(2);r1=r_1;
        a2=R_2(1);b2=R_2(2);r2=r_2;
%         [x,y]=solve((x-a1)^2+(y-b1)^2-r1^2,(x-a2)^2+(y-b2)^2-r2^2);
        
        
        [x,y]=cross_points_of_two_circles(a1, b1, r1, a2, b2, r2);
        X_plot=[X_plot;x];
        Y_plot=[Y_plot;y];
        X_relative_plot=[X_relative_plot;x-a2];
        Y_relative_plot=[Y_relative_plot;y-b2];
    end
    

end
X_plot=reshape(X_plot,[length(X_plot)*2,1]);
Y_plot=reshape(Y_plot,[length(Y_plot)*2,1]);
X_relative_plot=reshape(X_relative_plot,[length(X_relative_plot)*2,1]);
Y_relative_plot=reshape(Y_relative_plot,[length(Y_relative_plot)*2,1]);

toc

% close all
figure(1)
scatter(X_plot,Y_plot,'DisplayName','ApolloniusY','Marker','.','MarkerEdgeColor','r');
hold on

legend
axis square

figure(2)
scatter(X_relative_plot,Y_relative_plot,'DisplayName','ApolloniusY','Marker','.','MarkerEdgeColor','r');
hold on

legend
axis square

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

V_1_0=v*[cos(theta),0]';
% R_1_0=[-10,0]';
% a_1=0.3;
% 
% 
% V_2_0=[-0,-0]';
% R_2_0=[0,0]';
% a_2=0.4;


step_num=2000;
time_step=0.01;

X_plot=[];
Y_plot=[];

X_relative_plot=[];
Y_relative_plot=[];

tic
for i=1:step_num
    syms x y
    t=time_step*(i-1);
    r_1=0.5*a_1*t^2;
    r_2=0.5*a_2*t^2;
    R_1=R_1_0+V_1_0*t;
    R_2=R_2_0+V_2_0*t;
    if norm(R_1-R_2)<=r_1+r_2 && norm(R_1-R_2)>=r_1-r_2 && norm(R_1-R_2)>=r_2-r_1
        a1=R_1(1);b1=R_1(2);r1=r_1;
        a2=R_2(1);b2=R_2(2);r2=r_2;
%         [x,y]=solve((x-a1)^2+(y-b1)^2-r1^2,(x-a2)^2+(y-b2)^2-r2^2);
        
        
        [x,y]=cross_points_of_two_circles(a1, b1, r1, a2, b2, r2);
        X_plot=[X_plot;x];
        Y_plot=[Y_plot;y];
        X_relative_plot=[X_relative_plot;x-a2];
        Y_relative_plot=[Y_relative_plot;y-b2];
    end
    

end
X_plot=reshape(X_plot,[length(X_plot)*2,1]);
Y_plot=reshape(Y_plot,[length(Y_plot)*2,1]);
X_relative_plot=reshape(X_relative_plot,[length(X_relative_plot)*2,1]);
Y_relative_plot=reshape(Y_relative_plot,[length(Y_relative_plot)*2,1]);

toc

% close all
figure(1)
scatter(X_plot,Y_plot,'DisplayName','ApolloniusX','Marker','.','MarkerEdgeColor','b');
hold on

legend
axis square

figure(2)
scatter(X_relative_plot,Y_relative_plot,'DisplayName','ApolloniusX','Marker','.','MarkerEdgeColor','b');
hold on

legend
axis square