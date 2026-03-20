clc
clear 
close all
a_1=0.004;
a_2=0.003;
lambda=(a_2/a_1);
num_pursuer=round(pi/atan(sqrt(lambda^2/(1-lambda^2))));

max_num=100000;
para={};
Angle_set={}; 
counter=1;

for i=1:max_num
    V_0=rand()*15;
    L=rand()*50;
    theta=rand()*pi;

    [final_result,angle_set,usable]=find_angle(a_1,a_2,V_0,L,theta);
    [a_a,b_a]=size(angle_set);
    if a_a>1
        test=1;
        a=1+test;
    end
    if usable==1
        para{counter}=[a_1,a_2,V_0,L,theta];
        Angle_set{counter}=angle_set;
        
        counter=counter+1;
    end

    if mod(counter,100)==0
        save('para_0322.mat','para');
        save('Angle_set_0322.mat','Angle_set');
    end

end

