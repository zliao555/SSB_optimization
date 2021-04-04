function [I_peak I_peak_bi] = findPeak_iL (C1, C2,L_s, IDC)
f_L = 60;
T_L = 1/f_L;
fs = 150e3;
omega = 2*pi*f_L;
vc2dc = IDC/(C1*2*omega)*sqrt(1+C1/(2*C2))*1.01;
N_stamp = fs/f_L; %to calculate numbers of switching instances
t2 = linspace(0,T_L, N_stamp);
vab2 = -IDC/(C1*2*omega).*cos(2*omega*t2);
v2 = sqrt(vc2dc.^2-0.5*IDC^2/(4*omega.^2.*C1.*C2).*cos(4*omega.*t2));
ibuf = -IDC*sin(2*omega.*t2);
iL_ripple = (v2-abs(vab2)).*0.5.*(abs(vab2)./v2)/(fs*L_s);
iL_ripple_bi = (v2-abs(vab2)).*0.5.*(1+vab2./v2)/(fs*L_s);
%iL_sw = (sawtooth(2*pi*fs.*t2));
iL_real_bi = iL_ripple_bi*0.5+ibuf;
iL_real = iL_ripple*0.5 + ibuf;
I_peak = max(iL_real);
I_peak_bi = max(iL_real_bi)

end