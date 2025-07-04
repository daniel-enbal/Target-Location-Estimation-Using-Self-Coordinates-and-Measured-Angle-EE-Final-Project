file_name ='sensorlog_20250501_160808'; % Base name of the .mat file (without extension)
load('sensorlog_20250501_160808.mat'); % Load the sensor data
%sensorlog_20250501_155058-8 
%sensorlog_20250501_160808-arch 
% Align orientation data with the GPS timestamps by interpolating
commonTimestamps = Position.Timestamp; % Reference time vector from GPS

% Interpolate orientation values to match the GPS time base
bearing_resampled = interp1(Orientation.Timestamp, Orientation.X, commonTimestamps, 'linear', 'extrap');

% Transform orientation from bearing to east-relative angle (0° = East)
bearing_resampled_east = 90 - bearing_resampled;

% Strip date and keep only time for formatting and time series plotting
timeOnly = datetime(commonTimestamps, 'Format', 'HH:mm:ss.SSS');
timeOnlyStr = datestr(timeOnly, 'HH:MM:SS.FFF'); % Convert to string to suppress date

% Compute elapsed time from start for x-axis in plots
exp_time = seconds(timeOnly - timeOnly(1));

% Extract ship position in geodetic format
ship_lat = Position.latitude;
ship_lon = Position.longitude;
ship_alt = Position.altitude;

% Create a WGS84 reference ellipsoid with units in meters 
wgs84 = wgs84Ellipsoid("meter");

% Convert from geodetic to Earth-Centered, Earth-Fixed (ECEF) coordinates
[X_e, Y_e, Z_e] = geodetic2ecef(wgs84, ship_lat, ship_lon, ship_alt); 

% Translate from ECEF to local East-North-Up (ENU) system with the first point as origin
[X, Y, Z] = ecef2enu(X_e, Y_e, Z_e, ship_lat(1), ship_lon(1), ship_alt(1), wgs84);

% Prepare individual time series tables for X, Y positions and bearing (in radians)
T_X = table(X, 'VariableNames', {'X'});
T_Y = table(Y, 'VariableNames', {'Y'});
T_Bearing = table((bearing_resampled_east) * pi / 180, 'VariableNames', {'Relative Bearing'});

% Convert to timetable with consistent time base
TT_Bearing = table2timetable(T_Bearing, 'SampleRate', 1);

numRepeats = 25;

% Replicate bearing values to create long series
bearingVals = repmat(TT_Bearing.("Relative Bearing"), numRepeats, 1);

% Create new table
T_Bearing_Inf = table(bearingVals, 'VariableNames', {'Relative Bearing'});

% Create timetable with 1Hz sample rate
TT_Bearing_Inf = table2timetable(T_Bearing_Inf, 'SampleRate', 1);

% Convert tables to regularly sampled timetables for time-aligned analysis
TT_X = table2timetable(T_X, 'SampleRate', 1);
TT_Y = table2timetable(T_Y, 'SampleRate', 1);

X_vals = repmat(TT_X.X, 1000, 1);
Y_vals = repmat(TT_Y.Y, 1000, 1);
dt = seconds(1); % Since SampleRate = 1Hz
newTime = (0:length(X_vals)-1)' * dt;

% Create timetables
TT_X_inf = timetable(newTime, X_vals, 'VariableNames', {'X'});
TT_Y_inf = timetable(newTime, Y_vals, 'VariableNames', {'Y'});

% Define static target's location in latitude, longitude, and altitude
%target_lat = 32.7491188; 
%target_long = 35.0710946;
target_lat = 32.7485083;
target_long = 35.0688066;

target_alt = 0; % Assumes sea level or user-defined height

% Convert target geodetic coordinates to ECEF frame
[target_X_e, target_Y_e, target_Z_e] = geodetic2ecef(wgs84, target_lat, target_long, target_alt);

% Convert target ECEF coordinates to local ENU relative to initial ship position
[target_X, target_Y, target_Z] = ecef2enu(target_X_e, target_Y_e, target_Z_e, ship_lat(1), ship_lon(1), ship_alt(1), wgs84);
target_dist = sqrt(target_X^2 + target_Y^2); % Horizontal distance from ship to target

% Target position vector
target_vec = [target_X, target_Y];

% Compute beta (bearing to target) from each ship position
delta_X = target_X - X;
delta_Y = target_Y - Y;

% Theoretical: angle between ship position and target (ENU)
beta_theoretical = atan2(delta_Y, delta_X);  % In radians

% Measured: ship bearing from orientation
beta_measured = TT_Bearing.("Relative Bearing"); 

beta_theoretical_unwrapped = unwrap(beta_theoretical);

% Calculate angle ranges 
range_theo = max(beta_theoretical_unwrapped) - min(beta_theoretical_unwrapped);
range_mes = max(beta_measured) - min(beta_measured);

%  Scale adjustment 
mes_centered = beta_measured - mean(beta_measured);
%mes_centered = (beta_theoretical) - (beta_measured);
%mes_centered = movmean(beta_theoretical - beta_measured, 5);
mes_scaled = mes_centered * (range_theo / range_mes);
mes_scaled_1 = mes_scaled + mean(beta_theoretical_unwrapped);


%  Replicate for infinite Simulink series 
bearing_scaled_inf = repmat(mes_scaled_1, 1000, 1);

% Time axis 
dt = seconds(1);
t_scaled = (0:length(bearing_scaled_inf)-1)' * dt;

% Create Timetable for Simulink 
TT_Bearing_Inf_Scaled = timetable(t_scaled, bearing_scaled_inf, 'VariableNames', {'Relative_Bearing'});

% Plot ship's path in local ENU frame with target and endpoints
figure
plot(X, Y);
hold on;
scatter(X(1), Y(1), 'g','filled');     % Start position
scatter(X(end), Y(end), 'r','filled'); % End position
scatter(target_X, target_Y, 300, 'p','MarkerEdgeColor',[0.2 0.6 0.9], 'MarkerFaceColor','b', 'LineWidth', 1.5); % Target location
title('Static Target Trajectory in ENU Coordinates');
xlabel('East (meters)');
ylabel('North (meters)');
legend('path','start','end','target','FontSize',12);
grid on;
xlim([-5 45]);
ylim([-10 10]);
hold off;

% Plot time-series of bearing relative to east
figure
plot(TT_Bearing_Inf.Time, rad2deg(TT_Bearing_Inf.("Relative Bearing")));
title('Infinite Relative Bearing Timetable (Wrapped)');
xlabel('Time');
ylabel('Relative Bearing (deg)');
grid on;

% Print the target's relative location and range in ENU frame
disp(['Target X: ', num2str(target_X)]);
disp(['Target Y: ', num2str(target_Y)]);
disp(['Target Distance: ', num2str(target_dist)]);
disp('Data collection complete. Data saved to workspace as .mat files.');




