%-------------------------------------------------------------------------%
%    This function calculates capacitor bank volume using nonlinear 
%    voltage de-rated capacitance values
%-------------------------------------------------------------------------%

function [obj,Volume_C1,Volume_C2, N_C1, N_C2] = Volume_Function(C1, C2, VC2_DC, Capacitor1, Capacitor2, Ind, p)

%Capacitor Structure: [Voltage, Resr,v1,v2,v3,v4,c1,c2,c3,c4,Area,Volume]

%Calculate derated capacitance value
%C1_derated = interp1(Capacitor1(3:6), Capacitor1(7:10), p.VDC, 'spline');
C1_derated = 4.31E-07; % In this case, this is constant!
C2_derated = interp1(Capacitor2(3:6), Capacitor2(7:10), VC2_DC, 'spline');

% specify capacitor number based on rated efficiency
% Note this is non-interger to smooth optimizaiton space
N_C1 = C1/C1_derated; % #caps necessary
N_C2 = C2/C2_derated; % #caps necessary

% Uncomment here for true capacitor count (GA case)
% N_C1 = ceil(C1/C1_derated);
% N_C2 = ceil(C2/C2_derated);

% Calculate volume based on required number of capacitors
Volume_C1 = Capacitor1(12)*N_C1*1E-3; % [cm^3]
Volume_C2 = Capacitor2(12)*N_C2*1E-3; % [cm^3]
Volume.L2 = 2*Ind(10)*1E-3; % [cm^3]

Volume_Buffer = Volume_C1 + Volume_C2 + Volume.L2;

obj = Volume_Buffer;
end