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

more_x=[];
more_y=[];

fig = figure(1);
hold on;

% 使用深绿色绘制QAC路径，避免与其他颜色相近
% scatter(-X_plot, Y_plot, 40, [0.0, 0.26, 0.15], 'filled');  % 深绿色 (RGB: [0, 128, 0])


%%
x = X_plot;  % X坐标数组
y = Y_plot;  % Y坐标数组

%%
% 每4个点保留一个
step = 4;
% 保留的点的索引
selected_idx = 1:step:length(x);

%%
selected_idx = [];
% x1=10;x2=2500;%%v6
x1=10;x2=1000;%%v5
% 遍历所有点
% [x, idx] = sort(x);  % 对 x 升序排列，并获得排序索引
% y = y(idx);  % 按照 x 排序后的索引重新排列 y

step1=20;
step2=1;
for i = 1:length(x)
    if x(i) >= x1 && x(i) <= x2
        % 如果x在区间[x1, x2]之间，每10个点保留一个
        if mod(sum(x >= x1 & x <= x2) - sum(x(1:i) >= x1 & x(1:i) <= x2), step1) == 0
            selected_idx = [selected_idx, i];
        end
    else
        % 如果x不在区间[x1, x2]之间，每2个点保留一个
        if mod(sum(x < x1 | x > x2) - sum(x(1:i) < x1 | x(1:i) > x2), step2) == 0
            selected_idx = [selected_idx, i];
        end
    end
end

% selected_idx=load('selected_idx.mat').selected_idx;

%%

% 筛选后的 x 和 y
x_filtered = x(selected_idx);
y_filtered = y(selected_idx);

% 输出筛选后的点
disp('筛选后的 x 坐标:');
disp(x_filtered);
disp('筛选后的 y 坐标:');
disp(y_filtered);

% 计算点的数量
n = length(x_filtered);

% 计算所有点之间的距离矩阵
dist_matrix = sqrt((x_filtered - x_filtered').^2 + (y_filtered - y_filtered').^2);

% 设定一个距离阈值，将距离较远的点视为不同的图形
distance_threshold = 1;  % 根据数据调整这个阈值

% 创建一个邻接矩阵，用于标记点是否属于同一连通块
adj_matrix = dist_matrix < distance_threshold;

% 将邻接矩阵对角线置为0（避免一个点与自己连接）
adj_matrix = adj_matrix - diag(diag(adj_matrix));

% 使用图论方法找到所有的连通分量
G = graph(adj_matrix);
[bin, binsize] = conncomp(G);

% 对每个连通分量（闭合图形）进行处理
% figure;
hold on;
for k = 1:max(bin)
    % 获取属于第k个连通分量的点的索引
    cluster_idx = find(bin == k);
    
    % 获取这些点的x和y坐标
    cluster_x = x_filtered(cluster_idx);
    cluster_y = y_filtered(cluster_idx);
    
    % 初始化一个空的数组，用于存储连接顺序
    order = zeros(1, length(cluster_x));
    
    % 从第一个点开始
    order(1) = 1;  % 假设从第一个点开始
    
    % 创建一个未访问的点集
    unvisited = 2:length(cluster_x);
    
    % 当前点的索引
    current_idx = 1;
    
    % 使用最近邻算法连接点
    for i = 2:length(cluster_x)
        % 计算当前点到未访问点的距离
        dist = sqrt((cluster_x(unvisited) - cluster_x(current_idx)).^2 + (cluster_y(unvisited) - cluster_y(current_idx)).^2);
        
        % 找到最近的点
        [~, closest_idx] = min(dist);
        
        % 更新顺序
        order(i) = unvisited(closest_idx);
        
        % 更新当前点为最近点
        current_idx = order(i);
        
        % 从未访问点集中移除当前点
        unvisited(closest_idx) = [];
    end
    
    % 为了闭合曲线，最后将第一个点加入顺序
    order = [order, order(1)];
    
    para=1.5;
    % 绘制每个闭合图形
    plot(-cluster_x(order), cluster_y(order), 'Color', 'k', 'LineWidth', 6*para, ...
    'LineStyle', '-');
    plot(-cluster_x(order), cluster_y(order), 'Color',   [0.0, 176, 80]/255, 'LineWidth', 4*para, ...
    'LineStyle', '-');
    plot(-cluster_x(order), cluster_y(order), 'Color', 'w', 'LineWidth', 2*para, 'LineStyle', ':');  
end
%%
% 设置坐标轴，增强对比度，保持简洁
axis square;
grid on;
set(gca, 'GridAlpha', 0.4, 'FontSize', 18, 'FontName', 'Times New Roman', 'LineWidth', 1.5);

% 使用深红色绘制追捕者的初始位置
scatter(-R_1_0(1), R_1_0(2), 150, [192/255, 0, 0], 'filled','MarkerEdgeColor', 'k',...
        'LineWidth', 1.5);  % 深红色 (RGB: [192, 0, 0])

% 使用深蓝色绘制逃逸者的初始位置
scatter(-R_2_0(1), R_2_0(2), 150, [70/255, 113/255, 196/255], 'filled','MarkerEdgeColor', 'k',...
        'LineWidth', 1.5);  % 深蓝色 (RGB: [70, 113, 196])

% 设置坐标轴标签，使用斜体，符合期刊要求
xlabel('x', 'FontSize', 20, 'FontName', 'Times New Roman', 'Color', 'k', 'FontAngle', 'italic');
ylabel('y', 'FontSize', 20, 'FontName', 'Times New Roman', 'Color', 'k', 'FontAngle', 'italic');

% 不使用图例，保持简洁
% legend('Location', 'northeast', 'FontSize', 12, 'Box', 'off');

% 去掉坐标轴的边框，使其更现代
set(gca, 'Box', 'on', 'TickLength', [0.015 0.015],'GridColor', [0.85 0.85 0.85]);

% 设置图形尺寸，确保图像不失真
set(fig, 'Position', [-115,1283,634.6666666666666,611.3333333333333]);
% 获取当前图形的 TightInset
fig_pos = get(fig, 'Position');
tightInset = get(gca, 'TightInset');

% 调整图形位置和大小，减少空隙
set(fig, 'Position', [fig_pos(1), fig_pos(2), fig_pos(3) - tightInset(1) - tightInset(3), fig_pos(4) - tightInset(2) - tightInset(4)]);

% 设置图形尺寸，确保图像不失真
set(gcf, 'Renderer', 'painters');  % 矢量渲染器
% 可选：保存为矢量格式的EPS文件
% saveas(gcf, 'QAC_v_Optimized.eps');
