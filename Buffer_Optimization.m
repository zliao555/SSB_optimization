%-------------------------------------------------------------------------%
%                    Buffer sizing using Enumeration
%      This program will find the best switch, Cap1, Cap2 Combination
%-------------------------------------------------------------------------%
clc 
close all
clear
%%
%Specify system characteristics
p.Pin = 1500; %Input power
p.f_line = 60; %Line frequency
p.VDC = 400; % DC Voltage
p.fs = 150e3; % buffer switching frequency

%----------------- Specify algorithm characteristics here ----------------%
p.OPT = 2; % 1 - GA, 2 - weighted sums, 3 - compromise programming

Total_evaluations = 900;
 
%GA - Spefications
Generations = 10;
Population = Total_evaluations/Generations+1;

% Weight Sums Option
Points = 30; %Number of designs on Pareto front
p.Points = Points;
Iter = ceil(Total_evaluations/Points); %Hard coded for fun!

% Compromise programming
p.Power = 2; %For compromise programming
%-------------------------------------------------------------------------%

%Preprocessing
p.IDC = p.Pin/p.VDC;
p.omega = 2*pi * 2*p.f_line;
p.delta_q1max = p.IDC/p.omega;
%%
%Read excel file to get components information
ProcessComponents

%Initialize range of devices to use here
switches = [7]; %EPC 2016-only
capacitors = [1:p.numCapacitors]; %Test all capacitors
inductors = [1:p.numInductors]; %Test all inductors

%Create enumeration matrix
X = {switches, capacitors, capacitors, inductors};
[T{1:length(X)}] = ndgrid(X{:});
DESIGNS = [T{1}(:) T{2}(:) T{3}(:) T{4}(:)];

%Enumeration Optimization!
OBJ = zeros(length(DESIGNS),1);

% Optimization
for i = 1:length(DESIGNS)

    Switch = Switches(DESIGNS(i,1),:);
    Cap1 = Capacitors(DESIGNS(i,2),:);
    Cap2 = Capacitors(DESIGNS(i,3),:);
    Ind = Inductors(DESIGNS(i,4),:);

    if Cap1(1) < p.VDC
        OBJ(i) = NaN;
    else

        if p.OPT == 1  % GA
            options = optimoptions('gamultiobj','PlotFcn',@gaplotpareto, 'PopulationSize', Population, 'MaxGenerations', Generations, 'Display', 'iter');
            [OptX, OBJ] = gamultiobj(@(x)evaluate(x, Cap1, Cap2, Ind, p),2,[],[],[],[],[0.01 0.01],[1 0.9],@(x)nonlcon(x, Cap1, Cap2, Ind, Switch, p),options);
            % Extract parameters of interest
            for j = 1:length(OBJ)
                [~, OBJs(j,:)] = evaluate(OptX(j,:), Cap1, Cap2, Ind, p);
            end
        else %Weighted sums or compromise programming
            x0 = [0.5 0.5];
            options = optimoptions('fmincon', 'Display', 'none', 'MaxIter', Iter); 
            
            %Normalize objectives!
            p.Loss_0 = 1;
            p.Volume_0 = 1;
            p.alpha = 1;
            [~, p.Loss_0, ~, ~] = fmincon(@(x)evaluate(x, Cap1, Cap2, Ind, p),x0,[],[],[],[],[0.01 0.01],[0.9 0.9 ],@(x)Buffer_Constraints(x, Cap1, Cap2, Ind, Switch, p),options);
            p.alpha = 0;
            [~, p.Volume_0, ~, ~] = fmincon(@(x)evaluate(x, Cap1, Cap2, Ind, p),x0,[],[],[],[],[0.01 0.01],[0.9 0.9 ],@(x)Buffer_Constraints(x, Cap1, Cap2, Ind, Switch, p),options);

            %Calculate Pareto Set
            for j = 1:Points
                p.alpha = (j/Points-1/Points);
                [OptX(j,:), OBJ(j)] = fmincon(@(x)evaluate(x, Cap1, Cap2, Ind, p),x0,[],[],[],[],[0.01 0.01],[1 0.9 ],@(x)Buffer_Constraints(x, Cap1, Cap2, Ind, Switch, p),options);
                [~, OBJs(j,:)] = evaluate(OptX(j,:), Cap1, Cap2, Ind, p);
            end
        end
        
    % Save objective functions [Need to manually name here based on selection
    filename = sprintf("SW_%d_C1_%d_C2_%d_Ind_%d", DESIGNS(i,1), DESIGNS(i,2), DESIGNS(i,3), DESIGNS(i,4));
    save(filename, 'OBJs');   
    end
    
end


function [obj, OUTPUT] = evaluate(x, Cap1, Cap2, Ind, p)

%Extract design vector
C1 = x(1)*500E-6;
C2 = x(2)*1000E-6;

VC2_DC = p.delta_q1max/C1/sqrt(2*C2/(2*C2+C1))*1.01;

% Obtain volume information
[Volume, VolC1, VolC2, N_C1, N_C2] = Buffer_Volume(C1, C2, VC2_DC, Cap1, Cap2, Ind, p);

% Obtain loss information                         (C1, C2,   idc,     v2, var_vc2, pie, ind, fs)
[Loss, loss_sw, loss_cond, loss_ind] = Buffer_Loss(C1, C2, p.IDC,  VC2_DC,     0,    0, Ind, p.fs);

if p.OPT == 1 % Genetic algorithm optimization
    obj = [Volume, Loss];
elseif p.OPT == 2 % Weighted sums optimizations
    obj = (1-p.alpha)*Volume/p.Volume_0 + (p.alpha)*Loss/p.Loss_0;
elseif p.OPT == 3 % Compromise programming
    obj = (1-p.alpha)*(Volume)^p.Power/p.Volume_0 + (p.alpha)*(Loss)^p.Power/p.Loss_0;
end
    
% Save data into single structure
OUTPUT = [Volume, Loss, C1,C2, VolC1, VolC2, loss_sw, loss_cond,loss_ind, N_C1, N_C2];

end



