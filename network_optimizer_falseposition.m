function network_optimizer_gui()
    % Create the user interface window
    f = figure('Name', 'Network Optimizer', 'NumberTitle', 'off', 'Position', [100, 100, 600, 500]);

    % Add input fields for nodes and traffic demands
    uicontrol('Style', 'text', 'String', 'Nodes (x,y)', 'Position', [50, 420, 100, 20]);
    nodes_input = uicontrol('Style', 'edit', 'String', '0 0; 1 2; 3 4', 'Position', [150, 420, 200, 30]);

    uicontrol('Style', 'text', 'String', 'Traffic Demand', 'Position', [50, 370, 100, 20]);
    traffic_input = uicontrol('Style', 'edit', 'String', '5 3; 3 4', 'Position', [150, 370, 200, 30]);

    % Add input fields for False Position method parameters
    uicontrol('Style', 'text', 'String', 'xl', 'Position', [50, 320, 100, 20]);
    xl_input = uicontrol('Style', 'edit', 'String', '1', 'Position', [150, 320, 200, 30]);

    uicontrol('Style', 'text', 'String', 'xu', 'Position', [50, 280, 100, 20]);
    xu_input = uicontrol('Style', 'edit', 'String', '2', 'Position', [150, 280, 200, 30]);

    uicontrol('Style', 'text', 'String', 'Tolerance', 'Position', [50, 240, 100, 20]);
    tol_input = uicontrol('Style', 'edit', 'String', '0.01', 'Position', [150, 240, 200, 30]);

    % Add input field for function f
    uicontrol('Style', 'text', 'String', 'Function f(x)', 'Position', [50, 200, 100, 20]);
    f_input = uicontrol('Style', 'edit', 'String', 'x^2 - 2', 'Position', [150, 200, 200, 30]);

    % Add button to trigger network optimization
    uicontrol('Style', 'pushbutton', 'String', 'Optimize Network', 'Position', [150, 150, 200, 30], 'Callback', @optimize_network);

    % Create axes for network plotting
    ax = axes('Parent', f, 'Position', [0.4, 0.2, 0.55, 0.6]);

    % Callback function for optimization button
    function optimize_network(~, ~)
        % Get input values from user
        nodes_str = get(nodes_input, 'String');
        traffic_str = get(traffic_input, 'String');
        xl = str2double(get(xl_input, 'String'));
        xu = str2double(get(xu_input, 'String'));
        tol = str2double(get(tol_input, 'String'));
        f_str = get(f_input, 'String');  % Read function f from inputs

        % Convert inputs to numerical matrices
        nodes = str2num(nodes_str);
        trafficDemand = str2num(traffic_str);

        if isempty(nodes) || isempty(trafficDemand)
            errordlg('Invalid input for nodes or traffic demand!', 'Input Error');
            return;
        end

        % Optimize the network
        optimizedNodes = optimizeNetwork(nodes, trafficDemand);

        % Convert input text to a usable function
        try
            f = str2func(['@(x) ' f_str]);  % Convert text to function
        catch
            errordlg('Invalid function format for f(x)', 'Function Error');
            return;
        end

        % Calculate root using False Position method
        try
            root = false(f, xl, xu, tol);
        catch ME
            errordlg(ME.message, 'False Position Error');
            return;
        end

        % Display the result in the command window
        fprintf('Root found using False Position: %.4f\n', root);

        % Plot the original and optimized network with calculated root
        plotNetwork(ax, nodes, optimizedNodes, root);
    end
end
%nodes represent the network locations for example (router,server)
%Traffic diamond load associated with those nodes.
%f(x) represents the difference between incoming(downloading) and outing(uploading) traffic in aparticular nodes
%root indicate the point where the traffic load is perfectally balanced
function optimizedNodes = optimizeNetwork(nodes, trafficDemand)
    % Ensure trafficDemand matches nodes dimensions
    if size(trafficDemand, 1) < size(nodes, 1)
        % Pad trafficDemand with zeros to match nodes rows
        paddedTrafficDemand = zeros(size(nodes, 1), size(trafficDemand, 2));
        paddedTrafficDemand(1:size(trafficDemand, 1), :) = trafficDemand;
        trafficDemand = paddedTrafficDemand;
    end

    % Calculate traffic shift
    trafficShift = sum(trafficDemand, 2) * 0.1;

    % Ensure trafficShift is a column vector
    trafficShift = trafficShift(:);

    % Create shift matrix with same dimensions as nodes
    trafficShiftMatrix = repmat(trafficShift, 1, size(nodes, 2));

    % Add shift to points
    optimizedNodes = nodes + trafficShiftMatrix;
end

function plotNetwork(ax, nodes, optimizedNodes, root)
    % Plot the network before and after optimization
    axes(ax);
    clf; % Clear current figure

    hold on;
    % Plot original nodes
    scatter(nodes(:,1), nodes(:,2), 'filled', 'DisplayName', 'Original Nodes');
    for i = 1:size(nodes, 1)-1
        plot([nodes(i, 1), nodes(i+1, 1)], [nodes(i, 2), nodes(i+1, 2)], 'k--');
    end

    % Plot optimized nodes
    scatter(optimizedNodes(:,1), optimizedNodes(:,2), 'r', 'filled', 'DisplayName', 'Optimized Nodes');

    % Plot the root point from False Position method
    scatter(root, 0, 100, 'b', 'filled', 'DisplayName', 'Root (False Position)');
    line([root, root], ylim, 'Color', 'b', 'LineStyle', '--', 'DisplayName', 'Root Line');

    % Label axes
    title('Network Optimization with False Position');
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    legend('show');
    hold off;
end

% False Position method function
function root = false(f, xl, xu, tol)
    % Validate initial values
    if f(xl) * f(xu) >= 0
        error('f(xl) and f(xu) must have opposite signs.');
    end
    root = 0;
    % Set initial error
    error = 10000;

    % Apply False Position method
    while error > tol
        xr = xl - (f(xl) * (xu - xl)) / (f(xu) - f(xl));
        error = abs((xr - root) / xr) * 100; % Calculate relative error
        root = xr;

        % Update values based on sign
        if f(xr) == 0
            break;
        elseif f(xl) * f(xr) < 0
            xu = xr;
        else
            xl = xr;
        end
    end

    % Print final relative error
    fprintf('Final Error = %.4f%%\n', error);

    % Final result
    root = xr;
end
