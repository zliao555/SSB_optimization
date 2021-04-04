%-------------------------------------------------------------------------%
%    This function calculates all operational constraints for buffer
%-------------------------------------------------------------------------%


function [c, ceq] = nonlcon(x, Cap1, Cap2, Ind, Switch, p)

%Extract design vector
C1 = x(1)*500E-6;
C2 = x(2)*1000E-6;
VC2 = p.delta_q1max/C1/sqrt(2*C2/(2*C2+C1))*1.01;

%VC2 = p.VC2; uncomment to assume fixed!
Vswlimit = Switch(1);
Vc2RippleLimit = 0.2*Cap2(1); %20 of rated capacitor voltage
Vc1RippleLimit = Cap1(1) - 400; %20 of rated capacitor voltage
vab_RippleLimit = 1; % [v]
I_sat = Ind(8);
L_test = Ind(1);
fsw = 150e3;
C_f = 4e-6;

%operational constraint 
c1 = p.delta_q1max - C1*VC2*sqrt(2*C2/(2*C2+C1));

%component constraints
%full-bridge switching stress
c2 = sqrt(VC2^2+p.IDC^2/(2*p.omega^2*C1*C2)) - Vswlimit;
%vc1 ripple limit
c3 = p.IDC/(C1*p.omega) - Vc1RippleLimit;
%vc2 ripple limit
c4 = (VC2^2+p.IDC^2/(2*p.omega^2*C1*C2)) - (VC2^2-p.IDC^2/(2*p.omega^2*C1*C2)) - Vc2RippleLimit^2;
%vc2 max voltage limit
c5 = sqrt(VC2^2+p.IDC^2/(2*p.omega^2*C1*C2)) - Cap2(1);
%inductor ripple limit
c6 = sqrt(VC2^2+p.IDC^2/(2*p.omega^2*C1*C2))*0.5/(94e-6*fsw)/(8*fsw*C_f) - vab_RippleLimit ; %Limit is 3 A
% inductor current limit
%c7 = sqrt(VC2^2 + p.IDC^2/(2*p.omega^2*C1*C2))*0.25/(2*L_test*fsw) + p.IDC - I_sat;
Ipeak = findPeak_iL(C1, C2, VC2, L_test, p);
c7 = Ipeak - I_sat ;
% Add new ripple constraint based on power loss
% This constraint makes optimization nonlinear. However, not necessary yet
% c6 = 2*Plos/IDC

c = [c3, c5, c7]; %These 3 are the only constraints that matter. [Monotonicity] 
ceq = [];

end