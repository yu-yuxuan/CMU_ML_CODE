clc
clear
close all
A1=clean_tree (sample2_tree, 20);
A1=delete_tree (A1, [8]);

X_add(1)=(A1.X(1)+A1.X(2))/2;
X_add(2)=(A1.Y(1)+A1.Y(2))/2;
X_add(3)=(A1.Z(1)+A1.Z(2))/2;
X_add_2(1)=(A1.X(3)+A1.X(2))/2;
X_add_2(2)=(A1.Y(3)+A1.Y(2))/2;
X_add_2(3)=(A1.Z(3)+A1.Z(2))/2;
% A1=insert_tree (A1,[1 2 X_add 1 1]);
% A1=insert_tree (A1,[1 2 X_add_2 1 2]);
A1=root_tree (A1);
A1=root_tree (A1);

A1.X(3)=A1.X(4);
A1.Y(3)=A1.Y(4);
A1.Z(3)=A1.Z(4);
A1.X(2)=X_add(1); 
A1.Y(2)=X_add(2); 
A1.Z(2)=X_add(3);
A1.X(4)=X_add_2(1);
A1.Y(4)=X_add_2(2);
A1.Z(4)=X_add_2(3);
A1.Z(:)=0;
A1=scale_tree (A1, [1/25 1/20 1]);
A1=sort_tree (A1,'s');
A1.R(:)=2;
A1.D(:)=0.1;
% repair_tree (A1);
xplore_tree(A1);
% swc_tree (A1, 'test.swc');
% 
% 
% %%%rotation
% vz=[0,0,1];
% %parameter
% branch_1=[];
% branch_1=[branch_1,A1.X([5:9])];
% branch_1=[branch_1,A1.Y([5:9])];
% branch_1=[branch_1,A1.Z([5:9])];
% branch_1_vector=branch_1-branch_1(1,:);
% branch_2=[];
% branch_2=[branch_2,A1.X([5,10:13])];
% branch_2=[branch_2,A1.Y([5,10:13])];
% branch_2=[branch_2,A1.Z([5,10:13])];
% branch_2_vector=branch_2-branch_2(1,:);
% 
% 
alpha=-pi/2:pi/36:pi/2;
[alpha1,alpha2]=meshgrid(alpha,alpha);
file_ID=1;
foldername=sprintf('skeleton_swc');
mkdir(foldername)
for loopi=1:size(alpha1,1)
    for loopj=1:size(alpha1,2)
        M1 = compute_rotation(vz,alpha1(loopi,loopj));
        branch_1_new=M1*branch_1_vector';
        branch_1_new=branch_1_new';
        branch_1_new=branch_1_new+branch_1(1,:);
        M2 = compute_rotation(vz,alpha2(loopi,loopj));
        branch_2_new=M2*branch_2_vector';
        branch_2_new=branch_2_new';
        bp888msecaranch_2_new=branch_2_new+branch_2(1,:);
k-fold
        A1_new=A1;

        A1_new.X([5:9])=branch_1_new(:,1);
        A1_new.Y([5:9])=branch_1_new(:,2);
        A1_new.Z([5:9])=branch_1_new(:,3);

        A1_new.X([5,10:13])=branch_2_new(:,1);
        A1_new.Y([5,10:13])=branch_2_new(:,2);
        A1_new.Z([5,10:13])=branch_2_new(:,3);
%         xplore_tree(A1_new)
        
        str=sprintf('%04d',file_ID);
        dirname=[foldername,'/job',str,'.swc'];
        swc_tree (A1_new, dirname);
        file_ID=file_ID+1;
    end
end