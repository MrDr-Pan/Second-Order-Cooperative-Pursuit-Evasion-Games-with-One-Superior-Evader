clc
clear
a_1=0.4;
a_2=0.3;
V_0=2;
L=10;
% alpha=98/180*pi;
% alpha=atan(-1.133886303355413);


% alpha=atan(1.056268185329295+0.077625233695);
% alpha=atan(1.056268185329295)+pi/2-0.0547147;
% alpha=atan2(-1.056268185329295,-1);
% alpha=atan2(-1.133893237296502,-1);
% alpha=atan(1.133893205873571);
% alpha=acos(sqrt((a_1^2-a_2^2)/a_1^2))+0.1;
% alpha=-atan(0.411649417652864);%钩子，左
% alpha=atan2(-0.647270378211541,-1);
% alpha=atan2(-0.64727040956,-1);%钩子，右
% alpha=5/180*pi;
theta=0/180*pi;
% syms t;
% F=1/4*(a_1^2-a_2^2)*t^4+V_0*a_1*cos(alpha+theta)*t^3+(V_0^2-a_1*L*cos(alpha))*t^2-2*V_0*L*cos(theta)*t+L^2;
% x=solve(F,t);
% p=sym2poly(F);
% X=roots(p)
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
A=D^2-3*F;
B=D*F-9*E^2;
C=F^2-3*D*E^2;
DELTA=B^2-4*A*C;
% alpha_E=double(solve(E));
% alpha_F=double(solve(F));
[~,~,~,alpha_E] = GlobalSolve(matlabFunction(E),1,-pi,pi);
[~,~,~,alpha_F] = GlobalSolve(matlabFunction(F),1,-pi,pi);

res = intersect(roundn(alpha_E,-5) ,roundn(alpha_F,-5));
final_result=[];
for i=1:length(res)
    alpha_answer=res(i);
    a=1/4*(a_1^2-a_2^2);
    b=V_0*a_1*cos(alpha_answer+theta);
    c=(V_0^2-a_1*L*cos(alpha_answer));
    d=-2*V_0*L*cos(theta);
    e=L^2;
    D=3*b^2-8*a*c;
    if D>0
        final_result=[final_result,res(i)];
    end
end