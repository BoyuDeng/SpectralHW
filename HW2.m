close all; clear; clc;

% Parameters
L = 1000;      % Domain length (meters)
lambda0 = 30;  % Lengthscale (meters)
s = 1/25;      % Scaling factor
C = 1;         % Velocity (m/s)
x0 = 500;      % Initial center (meters)
T = L / C;     % Time for one cycle




% Parameters        % Length of the domain
M = 5;         % Number of elements
N = 4;         % Number of nodes per element
C = 1;         % Constant advection velocity
total_time = 1; % Total time for simulation
dt = 0.01;     % Timestep
num_steps = total_time / dt;

% Generate the nodes and weights for each element
[xi, w] = lglnodes(N+1); % Gauss-Legendre nodes and weights on [-1, 1]

% Map nodes from [-1, 1] to each element in [0, L]
xi = flipud(xi);
%w = w*(L/M)/2;
% Initial Condition (Gaussian bump)


% Differentiation matrix for Legendre-Gauss-Lobatto points
D = derv(N,xi);

bD = createBlockDiag(D, M, w, L);
Ase = createShiftedBlockDiag(D,M, w, L);
%Ase = (2*M/L).*Ase;
DMass = DGmass(w,M,L);
SMass = SEmass(w,M,L);


x = map_gll(N,L,M);
xse = map_gllse(N,L,M);

%%
% Initial Condition: Gaussian bump
u0_gaussian = exp(-0.5 * ((x - x0).^2) / lambda0^2);

% Initial Condition: Cone
u0_cone = max(0, 1 - s * abs(x - x0));

% Define initial conditions
U = u0_gaussian;   % Initial state vector
t = 0;             % Initial time
t_final = 100;      % Final time for simulation
h = 0.001;           % Time step size


% Time-stepping loop with RK4 and animation
while t < t_final
    % Calculate k1
    k1 = h * (DMass \ (bD * U));

    % Calculate k2
    k2 = h * (DMass \ (bD * (U + 0.5 * k1)));

    % Calculate k3
    k3 = h * (DMass \ (bD * (U + 0.5 * k2)));

    % Calculate k4
    k4 = h * (DMass \ (bD * (U + k3)));

    % Update U
    U = U + (1/6) * (k1 + 2 * k2 + 2 * k3 + k4);              
         

    % Update time
    t = t + h;
end

hold on
plot(x, u0_gaussian);
plot(x, U);

hold off



%%

% Define the spatial grid and initial Gaussian condition
u0_gaussian = exp(-0.5 * ((xse - x0).^2) / lambda0^2);

% Initialize other parameters
U = u0_gaussian;              % Initial state vector
t = 0;                        % Initial time
t_final = 100;                % Final time for simulation
h = 0.01;                     % Time step size

% Precompute the implicit update matrix

% For Backward Euler: (I - h * SMass \ Ase)
%implicitMatrix = (SMass - h * Ase);


% Time-stepping loop with animation
I = size(Ase);
while t < t_final
    % Solve for U_new using the implicit time-stepping formula
    % (SMass - h * Ase) * U_new = SMass * U
    %U = implicitMatrix \ (SMass * U);
    U = (h*inv(SMass)*Ase+eye(I(1)))*U;
    t = t + h;
end

hold on
plot(xse, u0_gaussian);
plot(xse, U);
hold off












