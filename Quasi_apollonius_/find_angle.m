function [final_result,new_set,usable]=find_angle(a_1,a_2,V_0,L,theta)
% a_1=0.04;
% a_2=0.03;
% V_0=0.5;
% L=10;
% theta=70/180*pi;

syms alphas;
a=1/4*(a_1^2-a_2^2);
b=V_0*a_1*cos(alphas+theta);
c=(V_0^2-a_1*L*cos(alphas));
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

% figure()
% xx=-pi:0.001:pi;
% yy=f(xx);
% para=max(abs(yy));
% plot(xx,yy)
% hold on
% 
% for i=1:length(alpha_E)
%     f(alpha_E(i))
%     b(alpha_E(i))
% end
% figure()
% plot(alpha_E)

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
    %     [x,y]=find(abs_M==min_value);
    if i==10
        1;
    end
    if min_value<4e-2
%         final_result=[final_result,alpha_E(i)];
        
        [x,y]=find(abs_M==min_value);
        for j=1:length(x)
            if length(X)==0
                continue;
            end
            X(X==X(x(j)))=[];
        end
        len_X=length(X);

        
        if len_X==0
            final_result=[final_result,alpha_E(i)];
        elseif len_X==1 
            if isreal_almost(X) && real(X)>0
                continue;
            else
                final_result=[final_result,alpha_E(i)]
            end
        elseif len_X==2 
            if isreal_almost(X(1)) && real(X(1))>0 && isreal_almost(X(2)) && real(X(2))>0 
                if abs(X(1)-X(2))<1e-4 || (abs(theta)<0.1 && abs(X(1)-X(2))<0.4)
                    final_result=[final_result,alpha_E(i)];
                else
                    continue;
                end
            elseif (isreal_almost(X(1)) && real(X(1))>0) || (isreal_almost(X(2)) && real(X(2))>0 )
                continue;
            elseif ~(isreal_almost(X(1)) && real(X(1))>0) && ~(isreal_almost(X(2)) && real(X(2))>0 )
                final_result=[final_result,alpha_E(i)];
            end

        end
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
usable=1;
angle_set_origin=angle_set;
[a,b]=size(angle_set);
angle_set=reshape(angle_set',a*b,1);
% angle_set=unique(angle_set);
chongfu_set=[];
for i=1:length(angle_set)-1
     if angle_set(i)==angle_set(i+1)
        chongfu_set=[chongfu_set,angle_set(i)];
        usable=0;
     end
end
for i=1:length(chongfu_set)
     angle_set(angle_set==chongfu_set(i))=[];
end
new_set=[];
for i=1:length(angle_set)/2
%     new_set(i,:)=[2*i-1,2*i];
    new_set(i,:)=[angle_set(2*i-1),angle_set(2*i)];
end

end

function bool=isreal_almost(x)
im=imag(x);
bool=0;
if abs(im)<1e-5*abs(real(x))
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