% syms x y;
% z=x^2*y+y;
% diff(z,x) 

syms alpha lambda theta
F=sin(theta)/sin(alpha+theta)+lambda^2*sin(alpha)^2/(sin(alpha+theta)*(sin(alpha+theta)-lambda*sin(theta)));
dF=diff(F,theta);
% matlabFunction(dF,theta)

y1=subs(dF,theta,0)
simplify(y1)

x=0.5:0.01:10;
syms x
y=(1+x.^3)./(2*x.^2);
z=double(solve(y-1))
% plot(x,y)

a_1=0.04;
a_2=0.03;
syms alpha V0 L theta
% F=*t^4+*t^3+*t^2*t+L^2;
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
rDrV=diff(DELTA,V0);
rDrL=diff(DELTA,L);
rDrTheta=diff(DELTA,theta);
rDrAlpha=diff(DELTA,alpha);


dV0=a_1+a_2;
dTheta=0;
dL=V0;
dAlpha=-(rDrV*dV0+rDrL*dL+rDrTheta*dTheta)/rDrAlpha;
var=[alpha V0 L theta];
value=[-0.8481,1,10,0];
result=double(subs(dAlpha,var,value))
