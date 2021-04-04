clc 

clear
close all
%%
idc = [0.229 0.464 0.698 0.934 1.175 1.42 1.662 1.912 2.164 2.422 2.675 2.938 3.206 3.475 3.75];
ploss_measure = [0.41 0.57 0.69 0.77 1.12 1.27 1.72 1.8 2.2 2.3 2.9 3.8 4.1 4.9 5.2];
v2 = [20 20 20 20 30 30 40 40 45 45 52 60 60 70 70];
plos = zeros(2,length(idc));
var_c2 = 0% turn on auto scale of vc2


for i = 1:1:length(idc)
    plos (:,i) = buffer_loss(80e-6, 68e-6*3, idc(i), v2(i), var_c2,0);
end

figure
plot (idc, ploss_measure)
hold ons
plot(idc, plos(1,:))
hold on
plot(idc, plos(2,:))

%%
idc = 1500/400
L = [4.70E-05	0.0407	19.23	98.48	0.00872	2.213	1.173]

[p_loss, sw_loss, cond_loss, ind_loss] = Buffer_Loss(80e-6, 68e-6, idc, 0, 1, 1,L,150e3)

%%
v = ploss_measure./idc*4

%%
rs = 10;
b = idc*rs
v_new = (-b+sqrt(b.^2+8*ploss_measure*rs))

%%
C1 = 340e-6;
C2 = 150e-6;
L_s = 4.4e-6;
idc = 6600/800;
[uni, bi] = findPeak_iL (C1, C2,L_s, idc)