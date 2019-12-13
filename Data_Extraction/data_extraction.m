clc
clear
close all
Matrix_total=[];
for loopi=1:100
    id=sprintf('%04d/skeleton_smooth.swc',loopi);
    if isfile(id)
        M = dlmread(id,'',6,0);
        branch_1=M([1,5:M(2,7),2],3:4);
        branch_2=M([2,M(2,7)+1:M(3,7),3],3:4);
        branch_3=M([2,M(3,7)+1:M(4,7),4],3:4);
       
        [pt_1,dpt_1] = interparc(5,branch_1(:,1),branch_1(:,2),'spline');
        [pt_2,dpt_2] = interparc(5,branch_2(:,1),branch_2(:,2),'spline');
        [pt_3,dpt_3] = interparc(5,branch_3(:,1),branch_3(:,2),'spline');

        dpt_1_normal=[dpt_1(:,2),-dpt_1(:,1)]./repmat(vecnorm(dpt_1,2,2),[1,2]);
        pt_1_up=pt_1+0.05*dpt_1_normal;
        pt_1_down=pt_1-0.05*dpt_1_normal;
		
		dpt_2_normal=[dpt_2(:,2),-dpt_2(:,1)]./repmat(vecnorm(dpt_2,2,2),[1,2]);
        pt_2_up=pt_2+0.05*dpt_2_normal;
        pt_2_down=pt_2-0.05*dpt_2_normal;

		
		dpt_3_normal=[dpt_3(:,2),-dpt_3(:,1)]./repmat(vecnorm(dpt_3,2,2),[1,2]);
        pt_3_up=pt_3+0.05*dpt_3_normal;
        pt_3_down=pt_3-0.05*dpt_3_normal;

     point_observed=[];

        point_observed=[point_observed;[pt_1(:,1),pt_1(:,2) ]                          ]  ;
        point_observed=[point_observed;[pt_3(2:end,1),pt_3(2:end,2) ]                          ]  ;
        point_observed=[point_observed;[pt_2(2:end,1),pt_2(2:end,2) ]                          ]  ;
        point_observed=[point_observed;[pt_1_up(1:end-1,1),pt_1_up(1:end-1,2)      ]   ]  ;
        point_observed=[point_observed;[pt_1_down(1:end-1,1),pt_1_down(1:end-1,2)  ]   ]  ;
        point_observed=[point_observed;[pt_2_up(2:end,1),pt_2_up(2:end,2)          ]   ]  ;
        point_observed=[point_observed;[pt_2_down(2:end,1),pt_2_down(2:end,2)      ]   ]  ;
        point_observed=[point_observed;[pt_3_up(2:end,1),pt_3_up(2:end,2)          ]   ]  ;
        point_observed=[point_observed;[pt_3_down(2:end,1),pt_3_down(2:end,2)      ]   ]  ;

        temp_add=point_observed(:)';

        for loopj=0:90

            
            id_sub_vtk=sprintf("%04d/D10_vplus5_vminus-0_kplus1_kminus0_k'plus0.5_k'minus0_dt0.1_nstep100_N0bc1_Nplusbc2_Nminusbc0/controlmesh_allparticle_%d.vtk",loopi,loopj);
            
             if isfile(id_sub_vtk)
                [vertex,face,concentration] = read_vtk_quad_3d_data(id_sub_vtk);
                temp_add_sub=temp_add;
                for loopk=1:size(point_observed,1)

                    temp=[point_observed(loopk,:),0];
                    temp_matrix=repmat(temp,[size(vertex,1),1]);
                    [u,v]=min(sum((temp_matrix-vertex).^2,2));
                    temp_add_sub=[temp_add_sub,concentration(v)];
                end
                temp_add_sub=[temp_add_sub,[loopj*0.1,10,1]];
                Matrix_total=[Matrix_total;temp_add_sub];
             end
        end


%         % Plot the result     
%         %      f
%             figure
%                 L1=load_tree(id)
%                 xplore_tree(L1)     
%                 hold on
%                 plot(point_observed([2:4,6:end],1),point_observed([2:4,6:end],2),'bo','MarkerSize', 10,'LineWidth',2)


        
        % % Plot the result     
        % %         
        %         L1=load_tree(id)
        %         xplore_tree(L1)     
        %         hold on
        %         plot(pt_1(:,1),pt_1(:,2),'b-o','MarkerSize', 20)
        % 		hold on
        %         plot(pt_3(:,1),pt_3(:,2),'b-o','MarkerSize', 20)
        %         hold on
        %         plot(pt_2(:,1),pt_2(:,2),'b-o','MarkerSize', 20)
        %         hold on
        %         plot(pt_1_up(1:end-1,1),pt_1_up(1:end-1,2),'b-o','MarkerSize', 20)
        %         hold on
        %         plot(pt_1_down(1:end-1,1),pt_1_down(1:end-1,2),'b-o','MarkerSize', 20)
        % 		hold on
        %         plot(pt_2_up(2:end,1),pt_2_up(2:end,2),'b-o','MarkerSize', 20)
        %         hold on
        %         plot(pt_2_down(2:end,1),pt_2_down(2:end,2),'b-o','MarkerSize', 20)
        % 		hold on
        %         plot(pt_3_up(2:end,1),pt_3_up(2:end,2),'b-o','MarkerSize', 20)
        %         hold on
        %         plot(pt_3_down(2:end,1),pt_3_down(2:end,2),'b-o','MarkerSize', 20)



    end
    
    
end