clc
clear 
close all
addpath('npy-matlab\');
% Angle_set=load('Angle_set_0717.mat');
% para=load('para_0717.mat');
% [Angle_matrix_1,para_matrix_1]=get_data(Angle_set,para);
% Angle_set=load('Angle_set_0718.mat');
% para=load('para_0718.mat');
% [Angle_matrix_2,para_matrix_2]=get_data(Angle_set,para);


% Angle_matrix=[Angle_matrix_1;Angle_matrix_2];
% para_matrix=[para_matrix_1;para_matrix_2];

Angle_set=load('Angle_set_0322.mat');
para=load('para_0322.mat');
[Angle_matrix,para_matrix]=get_data(Angle_set,para);

writeNPY(Angle_matrix,'Angle_matrix.npy');
writeNPY(para_matrix,'para_matrix.npy');


function [Angle_matrix,para_matrix]=get_data(Angle_set,para)
Angle_matrix=[];
para_matrix=[];
counter_1=0;
counter_0=0;
counter_multi=0;

for i=1:length(Angle_set.Angle_set)
    a=Angle_set.Angle_set(i);
    b=para.para(i);

    [a_a,b_a]=size(a{1});
    if a_a==0
        counter_0=counter_0+1;
    elseif a_a==1
        counter_1=counter_1+1;
        Angle_matrix=[Angle_matrix;a{1}];
        para_matrix=[para_matrix;b{1}];


        %         [a_A,b_A]=size(Angle_matrix);
        %         [a_P,b_P]=size(para_matrix);

    elseif a_a>1
        counter_multi=counter_multi+1;

        if a{1}(2,2)>2*pi
            Angle_matrix=[Angle_matrix;a{1}(2,:)];
        else
            if a{1}(1,1)>abs(a{1}(2,2)-2*pi)
                Angle_matrix=[Angle_matrix;a{1}(2,:)];
            else
                Angle_matrix=[Angle_matrix;a{1}(1,:)];
            end
        end

        para_matrix=[para_matrix;b{1}];
        %         disp(a_a)
    end
end
end


