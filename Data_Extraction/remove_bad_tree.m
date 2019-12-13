clc
clear
close all
start_trees
file_ID=1;
foldername=sprintf('skeleton_swc_checked');

for loopi=1:1369
    str_original=sprintf('job%04d.swc',loopi);
    A1=load_tree(str_original);
    A1=sort_tree (A1,'s');
   
    % xplore_tree(A1);
    branch_1=[];
    branch_1=[branch_1,A1.X([5:9])];
    branch_1=[branch_1,A1.Y([5:9])];
    branch_1=[branch_1,A1.Z([5:9])];
    branch_2=[];
    branch_2=[branch_2,A1.X([5,10:13])];
    branch_2=[branch_2,A1.Y([5,10:13])];
    branch_2=[branch_2,A1.Z([5,10:13])];

    if sum(sqrt(sum((branch_1-branch_2).^2,2))>0.2)==4
         A1.R(:)=2;
           str=sprintf('%04d',file_ID);
            dirname=[foldername,'/job_checked_',str,'.swc'];
            swc_tree (A1, dirname);
            file_ID=file_ID+1;
    end
end