file_name ='sensorlog_20250507_135912'; % Base name of the .mat file (without extension)
load('sensorlog_20250507_135912.mat'); % Load the sensor data
%sensorlog_20250507_135912 -tel aviv
%sensorlog_20250510_191134 (1) - yokneam
%sensorlog_20250525_182737
% Align orientation data with the GPS timestamps by interpolating
commonTimestamps = Position.Timestamp; % Reference time vector from GPS

% Strip date and keep only time for formatting and time series plotting
timeOnly = datetime(commonTimestamps, 'Format', 'HH:mm:ss.SSS');
timeOnlyStr = datestr(timeOnly, 'HH:MM:SS.FFF'); % Convert to string to suppress date

% Compute elapsed time from start for x-axis in plots
%exp_time = seconds(timeOnly - timeOnly(1));

% Extract ship position in geodetic format
target_lat = Position.latitude;
target_lon = Position.longitude;
target_alt = Position.altitude;

% Create a WGS84 reference ellipsoid with units in meters 
wgs84 = wgs84Ellipsoid("meter");

% Convert from geodetic to Earth-Centered, Earth-Fixed (ECEF) coordinates
[X_e_target, Y_e_target, Z_e_target] = geodetic2ecef(wgs84, target_lat, target_lon, target_alt); 

% Translate from ECEF to local East-North-Up (ENU) system with the first point as origin
[X_target, Y_target, Z_target] = ecef2enu(X_e_target, Y_e_target, Z_e_target, target_lat(1), target_lon(1), target_alt(1), wgs84);

% Prepare individual time series tables for X, Y positions and bearing (in radians)
T_X_target = table(X_target, 'VariableNames', {'X'});
T_Y_target= table(Y_target, 'VariableNames', {'Y'});

% Convert tables to regularly sampled timetables for time-aligned analysis
TT_X_target = table2timetable(T_X_target, 'SampleRate', 1);
TT_Y_target = table2timetable(T_Y_target, 'SampleRate', 1);

X_vals_target = repmat(TT_X_target.X, 1000, 1);
Y_vals_target = repmat(TT_Y_target.Y, 1000, 1);
dt = seconds(1); % Since SampleRate = 1Hz
newTime_target = (0:length(X_vals_target)-1)' * dt;

% Create timetables
TT_X_inf_target = timetable(newTime_target, X_vals_target, 'VariableNames', {'X'});
TT_Y_inf_target= timetable(newTime_target, Y_vals_target, 'VariableNames', {'Y'});
TT_X_inf_target.X = 1*(TT_X_inf_target.X+5);
TT_Y_inf_target.Y = -1*(TT_Y_inf_target.Y-3.4);
% Plot ship's path in local ENU frame with target and endpoints
figure
plot(X_target, Y_target);
hold on;
scatter(X_target(1), Y_target(1), 'g','filled');     % Start position
scatter(X_target(end), Y_target(end), 'r','filled'); % End position
%scatter(target_X, target_Y, 'p','filled'); % Target location
title('Static Target Trajectory in ENU Coordinates');
xlabel('East (meters)');
ylabel('North (meters)');
legend('path','start','end','target','FontSize',12);
grid on;
xlim([-40 40]);
ylim([-10 50]);
hold off;








