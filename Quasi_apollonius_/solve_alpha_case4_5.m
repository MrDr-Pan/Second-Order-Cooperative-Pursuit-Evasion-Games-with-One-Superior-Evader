clc
clear
close all
a_1=0.04;
a_2=0.03;
V_0=0.5;
L=10;
theta=70/180*pi;

% alpha=98/180*pi;
% alpha=atan(-1.133886303355413);


% alpha=atan(1.056268185329295+0.077625233695);
% alpha=atan(1.056268185329295)+pi/2-0.0547147;
% alpha=atan2(-1.056268185329295,-1);
% alpha=atan2(-1.133893237296502,-1);
% alpha=atan(1.133893205873571);
% alpha=acos(sqrt((a_1^2-a_2^2)/a_1^2))+0.1;
% alpha=-atan(0.411649417652864);%钩子，右
% alpha=atan2(-0.647270378211541,-1);
% alpha=atan2(-0.64727040956,-1);%钩子，左
% alpha=5/180*pi;

% syms t;
% F=1/4*(a_1^2-a_2^2)*t^4+V_0*a_1*cos(alpha+theta)*t^3+(V_0^2-a_1*L*cos(alpha))*t^2-2*V_0*L*cos(theta)*t+L^2;
% x=solve(F,t);
% p=sym2poly(F);
% X=roots(p)
syms alpha;
% alpha=-0.3905;
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
DELTA=(B^2-4*A*C);

f=matlabFunction(DELTA);
b=matlabFunction(B);


% figure()
xx=-pi:0.001:pi;
yy=f(xx);
para=max(abs(yy));
% plot(xx,yy)
% hold on


% yy=b(xx);
% plot(xx,yy)
% legend('delta','b')

DELTA=(B^2-4*A*C)/para;

% alpha_E=double(solve(E));
% alpha_F=double(solve(F));
% alpha_delta=solve(DELTA,alpha);
[~,~,~,alpha_E] = GlobalSolve(matlabFunction(DELTA),1,-pi,pi);
% [~,~,~,alpha_F] = GlobalSolve(matlabFunction(F),1,-pi,pi);
% fun=matlabFunction(A*B);
% fun(alpha_E)
% res = intersect(roundn(alpha_E,-5) ,roundn(alpha_F,-5));
% final_result=[];

f=matlabFunction(DELTA);
b=matlabFunction(B);

figure()
xx=-pi:0.001:pi;
yy=f(xx);
para=max(abs(yy));
plot(xx,yy)
hold on

for i=1:length(alpha_E)
    f(alpha_E(i))
    b(alpha_E(i))
end
figure()
plot(alpha_E)

syms t
%%
final_result=[];



% alpha_E(1)=atan2(-0.64727040956,-1)
for i=1:length(alpha_E)
    alpha_answer=alpha_E(i);
    F=1/4*(a_1^2-a_2^2)*t^4+V_0*a_1*cos(alpha_answer+theta)*t^3+(V_0^2-a_1*L*cos(alpha_answer))*t^2-2*V_0*L*cos(theta)*t+L^2;
    p=sym2poly(F);
    X_old=roots(p);
    X=[];
    for j=1:4
        if isreal_almost(X_old(j)) && real(X_old(j))>0
            X=[X,X_old(j)];
        end
    end
    if isempty(X)
        continue;
    end
    
    M=X-X.';
    M=M+10000^eye(length(X));
    abs_M=abs(M);
    min_value=min(min(abs_M));
    [x,y]=find(abs_M==min_value);
    if min_value<4e-2
        final_result=[final_result,alpha_E(i)];
    end
    

end


n=length(final_result);
for i=1:n
    if final_result(i)<0
        final_result(i)=2*pi+final_result(i);
    end

end
final_result=sort(final_result);

angle_set=[];
for i=1:n
    left=final_result(i);
    if i==n
        right=final_result(1)+2*pi;
    else
        right=final_result(i+1);
    end
    middle=0.5*(right+left);
    alpha_answer=middle;
    F=1/4*(a_1^2-a_2^2)*t^4+V_0*a_1*cos(alpha_answer+theta)*t^3+(V_0^2-a_1*L*cos(alpha_answer))*t^2-2*V_0*L*cos(theta)*t+L^2;
    p=sym2poly(F);
    X_old=roots(p);
    
    for j=1:4
        if isreal_almost(X_old(j)) && real(X_old(j))>0
            angle_set=[angle_set;[left,right]];
            break
        end
    end
    

end



function bool=isreal_almost(x)
    im=imag(x);
    bool=0;
    if abs(im)<1e-2*abs(real(x))
        bool=1;
    end
end
% for i=1:length(res)
%     alpha_answer=res(i);
%     a=1/4*(a_1^2-a_2^2);
%     b=V_0*a_1*cos(alpha_answer+theta);
%     c=(V_0^2-a_1*L*cos(alpha_answer));
%     d=-2*V_0*L*cos(theta);
%     e=L^2;
%     D=3*b^2-8*a*c;
%     if D>0
%         final_result=[final_result,res(i)];
%     end
% end