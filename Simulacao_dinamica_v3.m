%% Par�metros de entrada

% Do transdutor
transdutor.freq=2e4; %frequencia [Hz]
transdutor.c=340; % velocidade do som [m/s]
transdutor.A=10; %Amplitude [Pa]
transdutor.rho0 = 1.2; %Massa espec�fica do ar [kg/m^3]
transdutor.lambda = transdutor.c/transdutor.freq; %Comprimento de onda [m]
transdutor.omega=2*pi*transdutor.freq; %frequ�ncia angular [rad/s]
transdutor.k = transdutor.omega/transdutor.c; %n�mero de onda [1/m]
transdutor.a = 4.9e-3; %raio do pist�o circular [m]
transdutor.disc = .5e-5; %Discretiza��o [m]

% Posi��o e dire��o dos transdutores
[x0_v, y0_v] = meshgrid(-10.16*3.5:10.16:10.16*3.5,-10.16*3.5:10.16:10.16*3.5);
x0_v = 1e-3*reshape(x0_v,[64,1]);
y0_v = 1e-3*reshape(y0_v,[64,1]);
z0_v = zeros(64,1);
transdutor.posx = x0_v;
transdutor.posy = y0_v;
transdutor.posz = z0_v;

transdutor.normal = [1 0 0];
transdutor.foco = [0; 0; 0.05]; %posi��o focal [m]
% Da esfera
bolinha.rho = 30; %Densidade da bolinha [kg/m^3]
bolinha.R = 0.25e-3; %Raio da esfera [m]
bolinha.pos_i = [0; 0.0005; 0.03 ]; %Posi��o inicial da bolinha [m]
bolinha.v_i = [0; 0; 0]; %Velocidade inicial da bolinha [m/s]
% Da simula��o din�mica
bolinha.h = 1e-4; %Discretiza��o do tempo (passo de integra��o)
ti = 0;
tf = .50; %Tempo final
bolinha.t_v = ti:bolinha.h:tf;

%% Vari�veis calculadas
dist = sqrt((x0_v-transdutor.foco(1)).^2 + (y0_v-transdutor.foco(2)).^2 + (z0_v-transdutor.foco(3)).^2);
phase_v = 2*pi*dist/transdutor.lambda;
f = find(y0_v>0);
phase_v(f) = phase_v(f)+pi;
transdutor.phase = phase_v;

clear dist phase_v f x0_v y0_v z0_v
%% Simula��o din�mica
transdutor.R = bolinha.R;
[R] = f_Simulacao_dinamica_v3_mex(transdutor,bolinha);