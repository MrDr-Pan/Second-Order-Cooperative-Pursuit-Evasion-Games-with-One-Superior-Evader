clear
clc
close all

k_save_max=[];
k_save_min=[];
for u=4

    V_1_0=[u,0]';
    R_1_0=[-10,0]';
    a_1=0.3;


    V_2_0=[-0,0]';
    R_2_0=[0,0]';
    a_2=0.4;


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
    
    x_save=[];
    y_save=[];
    k_save=[];
    for i=1:length(Y_relative_plot)
        if Y_relative_plot(i)>0
            k=Y_relative_plot(i)/X_relative_plot(i);
            k_save=[k_save,k];
            x_save=[x_save,X_relative_plot(i)];
            y_save=[y_save,Y_relative_plot(i)];
        end
 
    end
    [min_k,min_k_index]=min(k_save);
    [max_k,max_k_index]=max(k_save);
    k_save_max=[k_save_max,max(k_save)];
    k_save_min=[k_save_min,min(k_save)];
%     x_=x_save(min_k_index);
    toc
    figure(1)
    hold on
    scatter(X_relative_plot,Y_relative_plot,'DisplayName','Apollonius','Marker','.','MarkerEdgeColor','g');
end

%% figurePlot
% close all
u=0:0.01:2;

figure(1)
x_=-25;
x_plot=0:x_/1000:x_;
y_plot=x_plot*min_k;
scatter(x_plot,y_plot,'Marker','.','MarkerEdgeColor','k');
scatter(R_1_0(1),R_1_0(2),'DisplayName','追击星初始位置','MarkerEdgeColor','r');
scatter(R_2_0(1),R_2_0(2),'DisplayName','逃逸星初始位置','MarkerEdgeColor','b');
X_=600;
x_plot_2=0:X_/1000:X_;
y_plot_2=x_plot_2*max_k;
scatter(x_plot_2,y_plot_2,'Marker','.','MarkerEdgeColor','k');

figure(2)
hold on
plot(k_save_max);
plot(k_save_min);

figure(3)
plot(k_save_min);