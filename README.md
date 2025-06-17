# Target Location Estimation Using Self-Coordinates and Measured Angle – EE Final Project

## **Project Overview:**

This project focuses on estimating the location of a target based on the observer’s own position (self-coordinates) and the measured angle to the target. The goal is to determine the target's position using sensor data, both in simulated environments and in real-world scenarios. The system was developed using MATLAB and Simulink to model and test different cases, and to evaluate how accurately the target's location can be estimated.

## **Project Components:**

The project includes three raw sensor logs collected using MATLAB Mobile: one for a static target with a ship moving in an arc (sensorlog_20250501_160808.mat), one for a dynamic target (sensorlog_20250507_135912.mat), and one for a ship moving in a circle as a part of the dynamic target scenario (sensorlog_20250507_134451.mat). These logs are processed using three MATLAB scripts (sensorlog_to_simulink_arc.m, sensorlog_to_simulink_target.m and sensorlog_to_simulink_ship.m) that convert the data into a format suitable for input into a Simulink model. The simulation model Ship_location_model_simulation_final.slx is used to test different movement scenarios. Two additional Simulink models (ship_location_measurements_model_dynamic_arc.slx and ship_location_measurements_model_dynamic.slx) are used to test different movement scenarios using real sensor data. A README file is included with full instructions for running all components.

## **How to Use:**

1. **Select Sensor Log Data:** Save all the provided files in your MATLAB working directory, including the sensorlog files. Do not rename the files, as the scripts rely on their original names. Choose the sensor log file corresponding to the scenario you wish to test (static or dynamic target).

2. **Run Data Preprocessing:** After saving the mat files, run sensorlog_to_simulink_arc.m for the static scenario, or sensorlog_to_simulink_target.m and sensorlog_to_simulink_ship.m for the dynamic scenario, to convert the selected sensor log into a Simulink-compatible timetable format.

3. **Run the Measurement Simulink Model:** Use ship_location_measurements_model_dynamic_arc.slx (for the static scenario) or ship_location_measurements_model_dynamic.slx (for the dynamic scenario) to process the prepared timetable and perform target location estimation using real measurement data.

4. **Simulation Model:** Optionally, run Ship_location_model_simulation_final.slx for simulated scenarios before working with real data. In the model, set the parameters target_x and target_y to the actual coordinates of the target and set the switches to the desired movement modes for both the ship and the target.

## **Requirements:**

1. MATLAB with Simulink.  
2. Sensor data files (provided in this repository).
