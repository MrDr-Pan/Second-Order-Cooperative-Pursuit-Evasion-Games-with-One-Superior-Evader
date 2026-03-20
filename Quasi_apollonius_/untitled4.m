clc;
clear;

close all;
load(".\data_v\data_1.mat");
v = data.v; 
a_2 = data.aE; 
a_1 = data.aP;
L = data.L;
theta = data.theta; 
R_1_0 = data.R_1_0;
R_2_0 = data.R_2_0;
X_plot = data.X_plot;
Y_plot = data.Y_plot;


axis equal;
title('多个闭合图形（每4个点保留一个）');
xlabel('X');
ylabel('Y');
hold off;