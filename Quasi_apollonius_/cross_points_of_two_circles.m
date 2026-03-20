

% # 计算两个圆的交点
function [x,y]=cross_points_of_two_circles(x1, y1, r1, x2, y2, r2)
dx = x2 - x1;
dy = y2 - y1;
dis2 = dx^2 + dy^2;

%     # 两个圆相离或包含
if dis2 > (r1 + r2) ^ 2 || dis2 < (r1 - r2) ^ 2
%     result=[];
    x=[];
    y=[];
else
    %     # 计算两个圆心的连线与x轴的角度t
    t = atan2(dy, dx);
    %     # 计算两个圆心的连线与圆心与交点之间的夹角a
    a = acos((r1 * r1 - r2 * r2 + dis2) / (2 * r1 * sqrt(dis2)));

    %     # 计算交点
    x3 = x1 + r1 * cos(t + a);
    y3 =  y1 + r1 * sin(t + a);
    x4 = x1 + r1 * cos(t - a);
    y4 =  y1 + r1 * sin(t - a);
    if sgn(a) == 0  %# 两个圆相切，返回1个点
%         result=[x3, y3];
        x=[x3,x3];
        y=[y3,y3];
    else  %# 两个圆相交，返回2个点
%         result =[x3, y3, x4, y4];
        x=[x3,x4];
        y=[y3,y4];
    end


end
end

% # 精度处理
% # 返回x经过eps处理的符号，负数返回-1，正数返回1，x的绝对值如果足够小，就返回0。
function result=sgn(x)
    if x < -eps
        result= -1;
    elseif x > eps
        result= 1;
    else
        result= 0;
    end
end