clc;
clear;
close all;

d = 0.508e-3;          % Wire diameter (m)
L = 0.25;              % Wire length (m)

I = 1.5;               % Selected current (A)

T_ambient = 25;        % Ambient temperature (deg C)


%% 2. SMA TRANSFORMATION TEMPERATURES

% Heating transformation: Martensite -> Austenite

As = 50;               % Austenite start temperature (deg C)
Af = 70;               % Austenite finish temperature (deg C)

% Cooling transformation: Austenite -> Martensite

Ms = 40;               % Martensite start temperature (deg C)
Mf = 30;               % Martensite finish temperature (deg C)

eps_max = 0.04;        % Maximum recoverable strain


%% 3. SMA ACTUATOR STRESS

% Selected actuator stress within the recommended
% application stress range for Nitinol actuator wire

sigma_act = 150e6;     % Actuator stress (Pa)


%% 4. MATERIAL PROPERTIES

rho_e = 8e-7;          % Electrical resistivity (Ohm-m)

rho = 6450;            % Density (kg/m^3)

Cp = 320;              % Specific heat (J/kg-K)

h = 20;                % Convective heat transfer coefficient
                       % (W/m^2-K)


%% 5. BEAM PARAMETERS

E_beam = 200e9;        % Young's modulus (Pa)

b = 10e-3;             % Beam width (m)

t = 2e-3;              % Beam thickness (m)

L_beam = 100e-3;       % Beam length (m)


%% 6. WIRE GEOMETRY

A_wire = pi*d^2/4;

Volume = A_wire*L;

A_surface = pi*d*L;

mass = rho*Volume;


%% 7. ELECTRICAL RESISTANCE

R = rho_e*L/A_wire;


%% 8. TIME SETTINGS

dt = 0.01;             % Time step (s)

t_max_heat = 60;       % Maximum heating time (s)

t_max_cool = 120;      % Maximum cooling time (s)



% 9. HEATING PHASE
%
% Current ON
%
% m Cp dT/dt =
% I^2 R - h A (T - T_ambient)
%
% Heating stops when Af is reached.


T = T_ambient;

time = 0;

T_heat = T;
time_heat = time;


while T < Af && time < t_max_heat

    % Joule heating
    Q_gen = I^2*R;

    % Convective heat loss
    Q_loss = h*A_surface*(T-T_ambient);

    % Net heat input
    Q_net = Q_gen-Q_loss;

    % Temperature rate
    dTdt = Q_net/(mass*Cp);

    % Temperature update
    T = T+dTdt*dt;

    % Time update
    time = time+dt;

    % Store results
    T_heat(end+1) = T;
    time_heat(end+1) = time;

end


%% 10. ACTIVATION RESULTS

T_activation = T;

activation_time = time;



% 11. HEATING PHASE TRANSFORMATION
%
% Austenite fraction increases between As and Af.


if T_activation <= As

    austenite_activation = 0;

elseif T_activation >= Af

    austenite_activation = 1;

else

    austenite_activation = ...
        (T_activation-As)/(Af-As);

end


%% 12. HEATING RECOVERY STRAIN

recovery_strain_activation = ...
    eps_max*austenite_activation;


%% 13. ACTUATION FORCE

F_max = sigma_act*A_wire;

F_activation = ...
    F_max*austenite_activation;


%% 14. BEAM DEFLECTION

I_beam = b*t^3/12;

deflection_activation = ...
    F_activation*L_beam^3/(3*E_beam*I_beam);



% 15. COOLING PHASE
%
% Current OFF
%
% m Cp dT/dt =
% -h A (T - T_ambient)


T_cool = T;

time_cool = 0;

T_cooling = T_cool;
time_cooling = time_cool;


while T_cool > T_ambient+0.5 && time_cool < t_max_cool

    % Electrical heating OFF
    Q_gen = 0;

    % Convective heat loss
    Q_loss = h*A_surface*(T_cool-T_ambient);

    % Net heat input
    Q_net = Q_gen-Q_loss;

    % Temperature rate
    dTdt = Q_net/(mass*Cp);

    % Temperature update
    T_cool = T_cool+dTdt*dt;

    % Time update
    time_cool = time_cool+dt;

    % Store results
    T_cooling(end+1) = T_cool;
    time_cooling(end+1) = time_cool;

end


% 16. COMPLETE HEATING + COOLING HISTORY


time_total = [time_heat, ...
              activation_time + time_cooling(2:end)];

T_total = [T_heat, ...
           T_cooling(2:end)];



% 17. PHASE TRANSFORMATION DURING COMPLETE CYCLE
%
% Heating:
% As -> Af : Austenite fraction increases
%
% Cooling:
% Ms -> Mf : Austenite fraction decreases


austenite_total = zeros(size(T_total));


for k = 1:length(T_total)

    % Heating transformation

    if T_total(k) <= As

        austenite_total(k) = 0;

    elseif T_total(k) >= Af

        austenite_total(k) = 1;

    else

        austenite_total(k) = ...
            (T_total(k)-As)/(Af-As);

    end

end



% 18. CORRECT COOLING TRANSFORMATION
%
% After activation, use Ms and Mf for
% Austenite -> Martensite transformation.


cooling_start_index = length(T_heat) + 1;


for k = cooling_start_index:length(T_total)

    T_current = T_total(k);

    if T_current >= Ms

        austenite_total(k) = 1;

    elseif T_current <= Mf

        austenite_total(k) = 0;

    else

        % Linear transformation between Ms and Mf

        austenite_total(k) = ...
            (T_current-Mf)/(Ms-Mf);

    end

end



% 19. RECOVERY STRAIN DURING COMPLETE CYCLE


strain_total = ...
    eps_max*austenite_total;

% 20. ACTUATION FORCE DURING COMPLETE CYCLE

force_total = ...
    F_max*austenite_total;



% 21. BEAM DEFLECTION DURING COMPLETE CYCLE


deflection_total = ...
    force_total*L_beam^3/(3*E_beam*I_beam);


% 22. VOLTAGE AND POWER


V = I*R;

Power = I^2*R;



% 23 RESULTS


fprintf('\n');
fprintf('====================================================\n');
fprintf('          NITINOL SMA ACTUATOR RESULTS\n');
fprintf('====================================================\n');

fprintf('Input Current          = %.2f A\n',I);

fprintf('Wire diameter          = %.3f mm\n',d*1000);

fprintf('Wire length            = %.0f mm\n',L*1000);

fprintf('Electrical resistance  = %.4f Ohm\n',R);

fprintf('\n');

fprintf('Voltage                = %.3f V\n',V);

fprintf('Electrical power       = %.3f W\n',Power);

fprintf('\n');

fprintf('As                      = %.1f deg C\n',As);

fprintf('Af                      = %.1f deg C\n',Af);

fprintf('Ms                      = %.1f deg C\n',Ms);

fprintf('Mf                      = %.1f deg C\n',Mf);

fprintf('\n');

fprintf('Activation temperature = %.2f deg C\n',...
    T_activation);

fprintf('Activation time        = %.2f s\n',...
    activation_time);

fprintf('\n');

fprintf('Austenite fraction     = %.2f %%\n',...
    austenite_activation*100);

fprintf('Recovery strain        = %.2f %%\n',...
    recovery_strain_activation*100);

fprintf('Actuator stress        = %.2f MPa\n',...
    sigma_act/1e6);

fprintf('Maximum actuator force = %.2f N\n',...
    F_max);

fprintf('Actuation force        = %.2f N\n',...
    F_activation);

fprintf('Beam tip deflection    = %.2f mm\n',...
    deflection_activation*1000);

fprintf('\n');

fprintf('Cooling time           = %.2f s\n',...
    time_cool);

fprintf('Final cooling temp.    = %.2f deg C\n',...
    T_cool);

fprintf('====================================================\n');



% 24. TEMPERATURE VS TIME


figure;

plot(time_total,T_total,'LineWidth',2);

hold on;

yline(As,'--','As = 50 deg C');

yline(Af,'--','Af = 70 deg C');

yline(Ms,'--','Ms = 40 deg C');

yline(Mf,'--','Mf = 30 deg C');

xline(activation_time,'--','Current OFF');

xlabel('Time (s)');
ylabel('Temperature (deg C)');

title('Nitinol SMA Heating and Cooling Cycle');

grid on;



% 25. AUSTENITE FRACTION VS TIME


figure;

plot(time_total,austenite_total*100,'LineWidth',2);

xlabel('Time (s)');
ylabel('Austenite Fraction (%)');

title('Austenite Fraction During SMA Cycle');

grid on;



% 26. RECOVERY STRAIN VS TIME


figure;

plot(time_total,strain_total*100,'LineWidth',2);

xlabel('Time (s)');
ylabel('Recovery Strain (%)');

title('Recovery Strain During SMA Cycle');

grid on;



% 27. ACTUATION FORCE VS TIME

figure;

plot(time_total,force_total,'LineWidth',2);

xlabel('Time (s)');
ylabel('Actuation Force (N)');

title('Actuation Force During SMA Cycle');

grid on;



% 28. BEAM DEFLECTION VS TIME


figure;

plot(time_total,deflection_total*1000,'LineWidth',2);

xlabel('Time (s)');
ylabel('Beam Tip Deflection (mm)');

title('Beam Deflection During SMA Cycle');

grid on;



% 29. CURRENT SWEEP


I_test = 0.5:0.1:5;

T_sweep = zeros(size(I_test));

activation_time_sweep = zeros(size(I_test));


for j = 1:length(I_test)

    I_sweep = I_test(j);

    T_temp = T_ambient;

    time_temp = 0;


    while T_temp < Af && time_temp < t_max_heat

        Q_gen = I_sweep^2*R;

        Q_loss = h*A_surface*...
            (T_temp-T_ambient);

        dTdt = ...
            (Q_gen-Q_loss)/(mass*Cp);

        T_temp = T_temp+dTdt*dt;

        time_temp = time_temp+dt;

    end

    T_sweep(j) = T_temp;

    activation_time_sweep(j) = time_temp;

end



% 30. CURRENT VS ACTIVATION TIME


figure;

plot(I_test,activation_time_sweep,'LineWidth',2);

hold on;

xline(I,'--','Selected Current');

xlabel('Current (A)');
ylabel('Activation Time (s)');

title('Current vs SMA Activation Time');

grid on;


% 31. CURRENT VS ACTIVATION TEMPERATURE


figure;

plot(I_test,T_sweep,'LineWidth',2);

hold on;

yline(As,'--','As = 50 deg C');

yline(Af,'--','Af = 70 deg C');

xline(I,'--','Selected Current');

xlabel('Current (A)');
ylabel('Activation Temperature (deg C)');

title('Current vs SMA Activation Temperature');

grid on;



% 32. CURRENT VS PHASE TRANSFORMATION


austenite_sweep = zeros(size(T_sweep));


for j = 1:length(T_sweep)

    if T_sweep(j) <= As

        austenite_sweep(j) = 0;

    elseif T_sweep(j) >= Af

        austenite_sweep(j) = 1;

    else

        austenite_sweep(j) = ...
            (T_sweep(j)-As)/(Af-As);

    end

end


figure;

plot(I_test,austenite_sweep*100,'LineWidth',2);

hold on;

xline(I,'--','Selected Current');

xlabel('Current (A)');
ylabel('Austenite Fraction (%)');

title('Current vs Phase Transformation');

grid on;



% 33. CURRENT VS RECOVERY STRAIN


strain_sweep = ...
    eps_max*austenite_sweep;


figure;

plot(I_test,strain_sweep*100,'LineWidth',2);

hold on;

xline(I,'--','Selected Current');

xlabel('Current (A)');
ylabel('Recovery Strain (%)');

title('Current vs Recovery Strain');

grid on;



% 34. CURRENT VS ACTUATION FORCE


force_sweep = ...
    sigma_act*A_wire*austenite_sweep;


figure;

plot(I_test,force_sweep,'LineWidth',2);

hold on;

xline(I,'--','Selected Current');

xlabel('Current (A)');
ylabel('Actuation Force (N)');

title('Current vs Actuation Force');

grid on;


% 35. CURRENT VS BEAM DEFLECTION


deflection_sweep = ...
    force_sweep*L_beam^3/(3*E_beam*I_beam);


figure;

plot(I_test,deflection_sweep*1000,'LineWidth',2);

hold on;

xline(I,'--','Selected Current');

xlabel('Current (A)');
ylabel('Beam Tip Deflection (mm)');

title('Current vs Beam Deflection');

grid on;
