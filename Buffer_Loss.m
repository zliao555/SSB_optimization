%buffer converter switching loss
function [ploss_out,p_sw_loss,p_cond_avg,ploss_ind] = Buffer_Loss(C1, C2, idc, v2, var_vc2, pie, ind, fs)
    Rgon = 15+10;       % Rgate external and internal driver mosfet resistance
    Rgoff = 10;
    Qgsw = 12e-9;		% equivalent input charge to move through plateua region
    Vth = 2.0;			% [V] gate-source threshold voltage
    Vdrv = 5.0;			% [V] gate driver voltage 
    Igon = (Vdrv-Vth)/Rgon;
    Igoff = Vth/Rgoff;

    ton  = Qgsw/Igon;
    toff = Qgsw/Igoff;
    rds_on = 15e-3;
    f_L = 60;
    T_L = 1/f_L;
    L_s = ind(1)*2;
    omega = 2*pi*f_L;

    dcr = ind(2);
    et100 = ind(3);
    k0 = ind(4);
    k1 = ind(5);
    kb = ind(6);
    kf = ind(7);
    
    
    %coss = 1000e-12;
    %esr_cap need information
    if var_vc2 == 1
        vc2dc = idc/(C1*2*omega)*sqrt(1+C1/(2*C2))*1.01;
    else
        vc2dc = v2;
    end

    N_stamp = fs/f_L; %to calculate numbers of switching instances
    t = linspace(0,T_L, N_stamp);
    vab = -idc/(C1*2*omega).*cos(2*omega*t);
    v2sw = sqrt(vc2dc.^2-0.5*idc^2/(4*omega.^2.*C1.*C2).*cos(4*omega.*t));%corresponse numbers of switching instances
    ibuf_sw = -idc*sin(2*omega.*t);%corresponse numbers of switching instances
   % ibuf = -idc*sin(2*omega.*t2);

    iL_ripple = (v2sw-abs(vab)).*0.5.*(abs(vab)./v2sw)/(fs*L_s);
    iL_ripple_bi = (v2sw-abs(vab)).*0.5.*(1+vab./v2sw)/(fs*L_s);
   % iL_sw = (sawtooth(2*pi*fs.*t2));
   % iL_real = iL_ripple.*iL_sw + ibuf;
    subplot (3,1,1) 
    plot (1e3*t, ibuf_sw);
    xlim([0 1e3/f_L])
    title('$i_{buf}$')
    ylabel('Current [A]')
 
    subplot (3,1,2) 
    plot (1e3*t, iL_ripple_bi);
     xlim([0 1e3/f_L])
    title('$\Delta I_{L,\ bi}$')
    ylabel('Current [A]')
    subplot (3,1,3) 
    plot (1e3*t, iL_ripple);
     xlim([0 1e3/f_L])
    ylabel('Current [A]')
    title('$\Delta I_{L,\ uni}$')
    xlabel('Time [ms]'); ylabel('Current [A]');
    
    set_figure_style(2)
    resize_figure(2,0.75)
   

    %2*coss*v2sw.*v2sw;
    E_sw = v2sw.*abs(ibuf_sw)*(ton+toff);
    p_coss = 4*coss(v2sw)*f_L;
    p_sw_loss = sum(E_sw)*f_L + p_coss; %2 direction switches
    %p_cond_avg = rms(iL_real)^2*(rds_on*2+2*rdcr);
    p_cond_avg = (idc^2/2+mean(iL_ripple.^2)./12)*(rds_on*2);

    
    fs_l = 2*fs;
    %svolt_ms = (abs(v2-vab).*d_s/fs)*1e6;
    %d_m = 0.5.*(1+abs(vab./v2sw));%instant duty ratio 
%svolt_ms = (abs(v2-vab).*d_s/fs)*1e6;
    d_s = abs(vab./v2sw);
    
    bpk =0.5*((v2sw-abs(vab)).*d_s/fs_l*1e6)/et100*100;%shared voltage stress
    fe = fs_l./(2*pi*d_s.*(1-d_s));
    p_core_ins = k0.*fe.^(kf-1).*bpk.^kb.*fs_l*10^-14;
    p_core = 2*mean(p_core_ins); %two inductors;
    p_ac_ins = dcr*(274.5+50)/(259.5)*k1*iL_ripple.^2*sqrt(fs_l);
    k_f = 1.2;%scaler for fitting experimental results
    p_ac = 2*mean(p_ac_ins); %two inductors;;
    p_dc = (idc^2/2+mean(iL_ripple.^2)./12)*2*dcr;
    ploss_ind = (p_ac+p_core+p_dc)*k_f;
    ploss_out = p_sw_loss+p_cond_avg+ploss_ind;
   

    if pie == 1 
        figure
        loss_dis = [p_sw_loss p_cond_avg ploss_ind];
        pie3(loss_dis)
        legend('Switching loss', 'Conduction loss', 'Inductor')
        set_figure_style(2)
        resize_figure(2.25,0.75)
    end 

end

function E_coss = coss(vds)
    E_coss_sum = 0;
    Coss_c = [1863.64	1848.78	1813.71	1733.31	1642.8	1541.97	1436.05	1249.33	1102.96	936.437	830.406	739.73	709.744	679.932	635.633	576.788	533.181	509.863	481.465	483.485	474.683]*1e-12; 
    Coss_v = [0 2.87875 5.7409 9.75238 13.7653 15.494	16.9377	18.393 19.271	20.7234	21.0242	23.3229	26.47 31.3314 42.7663	60.2033	78.4953	97.6414	116.503	136.502	151];
    dv = [0 (Coss_v(2:end)-Coss_v(1:(end-1)))];
    Coss_e = cumsum(Coss_v .* Coss_c.*dv); %perform piece-wise integration to determine energy at a given voltage.
    for i=1:length(vds)
        E_coss_sw = interp1(Coss_v, Coss_e, vds(i), 'linear', 'extrap');
        E_coss_sum = E_coss_sum + E_coss_sw;
    end
    E_coss = E_coss_sum;
end