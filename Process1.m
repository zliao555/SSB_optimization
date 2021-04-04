 %-------------------------------------------------------------------------%
%                        Process Results
%-------------------------------------------------------------------------%

%-----------------------%
figure(1)
load('SW_7_C1_1_C2_1_Ind_1.mat');
scatter(OBJs(:,1),OBJs(:,2)); hold on

load('SW_7_C1_1_C2_1_Ind_2.mat');
scatter(OBJs(:,1),OBJs(:,2)); 

load('SW_7_C1_1_C2_1_Ind_3.mat');
scatter(OBJs(:,1),OBJs(:,2)); 

load('SW_7_C1_1_C2_2_Ind_1.mat');
scatter(OBJs(:,1),OBJs(:,2)); 

load('SW_7_C1_1_C2_2_Ind_2.mat');
scatter(OBJs(:,1),OBJs(:,2)); 

load('SW_7_C1_1_C2_2_Ind_3.mat');
scatter(OBJs(:,1),OBJs(:,2)); hold off

legend('C1:450, C2:450, L:1', 'C1:450, C2:450, L:2','C1:450, C2:450, L:3','C1:450, C2:100, L:1','C1:450, C2:100, L:2','C1:450, C2:100, L:3')

%------------------------%
figure(2)

load('SW_7_C1_1_C2_2_Ind_1.mat');
%scatter(OBJs(:,1),OBJs(:,2)); hold on
plot(OBJs(:,1),OBJs(:,2),'LineStyle','--','Marker','.','MarkerSize',20); hold on
load('SW_7_C1_1_C2_2_Ind_2.mat');
%scatter(OBJs(:,1),OBJs(:,2)); 
plot(OBJs(:,1),OBJs(:,2),'LineStyle','--','Marker','.','MarkerSize',20); hold on
load('SW_7_C1_1_C2_2_Ind_3.mat');
%scatter(OBJs(:,1),OBJs(:,2)); hold off
plot(OBJs(:,1),OBJs(:,2),'LineStyle','--','Marker','.','MarkerSize',20); hold on
legend('Inductor 1', 'Inductor 2', 'Inductor 3')

ylim([0 11]);
xlabel('Volume [cm$^3$]');
ylabel('Loss [W]'); 
set_figure_style(2)
resize_figure(2,0.75)