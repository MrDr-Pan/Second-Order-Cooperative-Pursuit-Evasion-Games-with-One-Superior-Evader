clc
clear

syms x y


a1=1;b1=0;r1=1;
a2=-1,b2=0,r2=1; 
[x,y]=solve((x-a1)^2+(y-b1)^2-r1^2,(x-a2)^2+(y-b2)^2-r2^2);



a1=1;b1=0;r1=1;
a2=-1,b2=0,r2=1; 
result=cross_points_of_two_circles(a1, b1, r1, a2, b2, r2);

fprintf('两个圆的交点坐标:\n');
for i = 1:length(x)
    fprintf('(%f，%f)\n',x(i),y(i));
end


eps = 1e-8;


