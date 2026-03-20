clc
clear
f = @(x)(cos(x)-0.25); %目标函数

a_1=0.4;
a_2=0.3;
V_0=4;
L=10;
theta=0/180*pi;

syms alpha;
% alpha=-2.293530578782939;
a=1/4*(a_1^2-a_2^2);
b=V_0*a_1*cos(alpha+theta);
c=(V_0^2-a_1*L*cos(alpha));
d=-2*V_0*L*cos(theta);
e=L^2;
D=3*b^2-8*a*c;
E=-b^3+4*a*b*c-8*a^2*d;
F=3*b^4+16*a^2*c^2-16*a*b^2*c+16*a^2*b*d-64*a^3*e;
[x,fval,exitFlag,multiSol] = GlobalSolve(matlabFunction(E),1,-pi,pi);