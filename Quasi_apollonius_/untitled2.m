clc
clear
a_1=0.4;
a_2=0.3;
V_0=5;
L=10;
% alpha=98/180*pi;
% alpha=atan(-1.133886303355413);
% alpha=atan(1.056268185329295+0.077625233695);
% alpha=atan(1.056268185329295)+pi/2-0.0547147;
% alpha=atan2(-1.056268185329295,-1);%2右
% alpha=atan2(-1.133893409485676,-1);%4右
% alpha=atan(1.133893205873571);%4左
% alpha=atan2(1.133893415238483,-1)%5右
% alpha=acos(sqrt((a_1^2-a_2^2)/a_1^2))+0.1;
% alpha=-atan(0.411649417652864);%钩子，左
% alpha=atan2(-0.647270378211541,-1);
% alpha=atan2(-0.64727040956,-1);%钩子，右
% alpha=5/180*pi;
% alpha=0.737361024150051;
alpha=0/180*pi;
theta=90/180*pi;
syms t;
F=1/4*(a_1^2-a_2^2)*t^4+V_0*a_1*cos(alpha+theta)*t^3+(V_0^2-a_1*L*cos(alpha))*t^2-2*V_0*L*cos(theta)*t+L^2;
% x=solve(F,t);
p=sym2poly(F);
X=roots(p)
a=p(1);
b=p(2);
c=p(3);
d=p(4);
e=p(5);
D=3*b^2-8*a*c;
E=-b^3+4*a*b*c-8*a^2*d;
F=3*b^4+16*a^2*c^2-16*a*b^2*c+16*a^2*b*d-64*a^3*e;
A=D^2-3*F;
B=D*F-9*E^2;
C=F^2-3*D*E^2;
DELTA=B^2-4*A*C;

% (-b-2*A*E/B)/4/a