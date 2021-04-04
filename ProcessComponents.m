%-------------------------------------------------------------------------%
%                       Import devices from excel 
%-------------------------------------------------------------------------%

Data = importdata('DeviceCatalog.xlsx');

%FCML Switches
% Structure: [Vds, I, R, Coss, Area, Volume]
p.numSwitches = length(Data.data.FCMLSwitches(:,1));
switchNames = Data.textdata.FCMLSwitches(4:3+p.numSwitches,1);
Switches = Data.data.FCMLSwitches(:,[1,2,3,5,9,10]);

%Capacitors
% Structure: [Voltage, Resr, v0,v1,v2,v3,v4,c1,c2,c3,c4,Area,Volume]
p.numCapacitors = length(Data.data.Capacitors(:,1));
capacitorNames = Data.textdata.Capacitors(4:3+p.numCapacitors,1);
Capacitors = Data.data.Capacitors(:,[1,3,5,6,7,8,9,10,11,12,16,17]);

%Inductors
%Structure: [inductance, dcr, et100, k0, k1, kb, kf, saturation current, thermal resistance, volume]
p.numInductors = length(Data.data.Inductors(:,1));
inductorNames = Data.textdata.Inductors(4:3+p.numInductors,1);
Inductors = Data.data.Inductors(:,[1,2,3,4,5,6,7,8,9,14]);

%Unfolder Switches
% Structure: [Vds, I, R, Coss, Area, Volume]
p.numunfolderSwitches = length(Data.data.UnfolderSwitches(:,1));
unfolderswitchNames = Data.textdata.UnfolderSwitches(4:3+p.numunfolderSwitches,1);
unfolderSwitches = Data.data.UnfolderSwitches(:,[1,2,3,5,9,10]);