function [direct_traj_n, return_traj_n] = legTrajectory(legs, step_length, theta_a, N_points, leg_index)
% returning the direct and return trajectory normalized (0 to 1) and in the robot angle

load angle.mat

% legs -> array of leg objects
% theta_a -> angle of robot motion, 0: moving forward 
% N_points -> number of points to use for inverse kinematics
% step_length -> length of the leg step in cm
% leg_index -> index of the leg to determine the inverse kinematics for

% determination of the stable point
prism_start = 2; % starting point of the prismatic joint (vertical degree of freedom)
direction = [sind(theta_a) cosd(theta_a) 0]';
q_stable = [prism_start deg2rad(180-angles(leg_index).a) deg2rad(180-angles(leg_index).b)]; % stable configuration, trasformation 
% from simulation angle to robot angle is always -> sim_angle = 180-robot_angle
stable_point = legs(leg_index).fkine(q_stable);
P = stable_point.t;

% starting point and end point
P0 = +step_length/2*direction + P;    
P1 = -step_length/2*direction + P;
Ps = SE3(P0);
Pe = SE3(P1);

% Inverse kinematic trajectory
M = [1 1 1 0 0 0];
tj_points = ctraj(Ps, Pe, N_points);
direct_traj_sim = legs(leg_index).ikine(tj_points, 'mask', M, 'q0', q_stable, 'tol', 0.2);

% Return trajectory
max_height = pi/8; % [rad] return angle of joint 2
return_traj_sim(1:N_points/2, :) = jtraj(direct_traj_sim(end,:), ...
    [direct_traj_sim(N_points/2,1) direct_traj_sim(N_points/2,2) max_height], N_points/2);
return_traj_sim(N_points/2+1:N_points, :) = jtraj([direct_traj_sim(N_points/2,1) direct_traj_sim(N_points/2,2) max_height], ...
    direct_traj_sim(1, :), N_points/2);
% return_traj_sim

% Plot results
plot_leg(legs(leg_index), direct_traj_sim, return_traj_sim, P0, P1, 0, leg_index);

% Normalization and return
direct_traj_sim = direct_traj_sim(:, 2:3);
direct_traj_n = normalize_angle(rad2deg(direct_traj_sim), 'deg');
return_traj_sim = return_traj_sim(:, 2:3);
return_traj_n = normalize_angle(rad2deg(return_traj_sim), 'deg');
end