clear
close 
clc
format compact

% Lista degli stati
% - wait for input

% - steady          (stabilizzato)

% - walk_forward
%   - right_legs
%   - left_legs

% - walk_backward
%   - right_legs
%   - left_legs

% - rotate_left
%   - right_legs
%   - left_legs

% - rotate_right
%   - right_legs
%   - left_legs
%% Connection and setup
load angle.mat
com_port = 'com11';
a = arduino(com_port, 'uno',...
    'Libraries', {'Servo' 'Ultrasonic' 'I2C'},...
    'BaudRate', 128000);
s1_1 = servo(a, 'D3');
s1_2 = servo(a, 'D2');
s2_1 = servo(a, 'D5');
s2_2 = servo(a, 'D4');
s3_1 = servo(a, 'D7');
s3_2 = servo(a, 'D6');
s4_1 = servo(a, 'D13');
s4_2 = servo(a, 'D12');
s5_1 = servo(a, 'D11');
s5_2 = servo(a, 'D10');
s6_1 = servo(a, 'D9');
s6_2 = servo(a, 'D8');
servomotors = [s1_1, s1_2, s2_1, s2_2, s3_1, s3_2, s4_1, s4_2, s5_1, s5_2, s6_1, s6_2]';
stable_position(servomotors)
%% Robot's leg creation
legs = [createLeg(1) createLeg(2) createLeg(3) createLeg(4) createLeg(5) createLeg(6)]';
%% State machine
current_state = 'wait_for_input';
next_state = '';
N_points = 8;      % points in the leg trajectory
visualize = 0;
tj_forward = zeros(6, N_points, 2); % allocation for speed
tj_return = zeros(6, N_points, 2);

% State machine
while true
    stable_position(servomotors);
    switch current_state
        
        % ----- State wait_for_input -------
        case'wait_for_input'
            user_input = input("Insert command\n1 -> Walk forward" + ...
                "\n2 -> Walk backward" + ...
                "\n3 -> Rotate rigth" + ...
                "\n4 -> Rotate left" + ...
                "\n5 -> Steady\n");
            user_input = int8(user_input);
            switch user_input
                case 1
                    next_state = 'walk_forward';
                case 2
                    next_state = 'walk_backward';
                case 3
                    next_state = 'rotate_right';
                case 4
                    next_state = 'rotate_left';
                case 5
                    next_state = 'steady';
                otherwise
                    next_state = 'wait_for_input';
            end

        % ----- state walk_forward -----
        case 'walk_forward'
            step = 4; % step length
            theta_a = 0; % direction of the hexapod [deg] (0 -> forward, 90 -> right)
            
            % Creation of trajectories
            for i=1:6
                % Doing the kinematics for each leg
                [tj_f_tmp, tj_b_tmp] = legTrajectory(legs, step, theta_a, N_points, i, visualize);
                tj_forward(i, :, :) = tj_f_tmp;
                tj_return(i, :, :) = tj_b_tmp;
            end

            % Triangle gait phase one -> Move legs 2,4,6 forward and others
            % back
            execute_trajectory(servomotors, tj_forward, tj_return, 1, N_points);
            % Triangle gait phase one -> Move legs 1,3,5 forward and others
            % back
            execute_trajectory(servomotors, tj_forward, tj_return, 2, N_points);
            
            % Next state evaluation
            next_state = 'wait_for_input';
            disp("Walking forward yee")
        
        % ----- state walk_backward -------
        case 'walk_backward'
        
        % ----- state rotate_left ---------
        case 'rotate_left'
        

        % ----- state rotate_right --------
        case 'rotate_right'

        % ----- state steady --------------
        case 'steady'
        
            
        % ----- Default case --------------
        otherwise
            next_state = 'wait_for_input';
        
        
    
    end

    current_state = next_state;
end




