%% Par�metros de entrada
clear all
clc
% Do transdutor
transdutor.freq = 4e4; %frequencia [Hz]
transdutor.c = 340; % velocidade do som [m/s]
transdutor.A = 4; %Amplitude [Pa]
transdutor.rho0 = 1.2; %Massa espec�fica do ar [kg/m^3]
transdutor.lambda = transdutor.c/transdutor.freq; %Comprimento de onda [m]
transdutor.omega = 2*pi*transdutor.freq; %frequ�ncia angular [rad/s]
transdutor.k = transdutor.omega/transdutor.c; %n�mero de onda [1/m]
transdutor.a = 4.9e-3; %raio do pist�o circular [m]
transdutor.disc = 1e-5; %Discretiza��o [m]

% Posi��o e dire��o dos transdutores
[x0_v, y0_v] = meshgrid(-10.16*3.5:10.16:10.16*3.5,-10.16*3.5:10.16:10.16*3.5);
x0_v = 1e-3*reshape(x0_v,[64,1]);
y0_v = 1e-3*reshape(y0_v,[64,1]);
z0_v = zeros(64,1);
transdutor.posx = x0_v;
transdutor.posy = y0_v;
transdutor.posz = z0_v;

transdutor.normal = [0 0 1];
% Da esfera
bolinha.rho = 30; %Densidade da bolinha [kg/m^3]
bolinha.R = 0.75e-3; %Raio da esfera [m]
pos_i = [0; 0; 0.04607 ]; %Posi��o inicial da bolinha [m]
v_i = [0; 0; 0]; %Velocidade inicial da bolinha [m/s]
% Da simula��o din�mica
h = 1e-3; %Discretiza��o do tempo (passo de integra��o)
ti = 0;
tf = 2.5; %Tempo final
t_v = ti:h:tf;

%% Vari�veis calculadas
% dist = sqrt((x0_v-transdutor.foco(1)).^2 + (y0_v-transdutor.foco(2)).^2 + (z0_v-transdutor.foco(3)).^2);
% phase_v = 2*pi*dist/transdutor.lambda;
% f = find(y0_v>0);
% phase_v(f) = phase_v(f)+pi;
% transdutor.phase = phase_v;
% 
% clear dist phase_v f x0_v y0_v z0_v

%% Simula��o din�mica
n = length(t_v);
bolinha.x = zeros(1,n); bolinha.y = zeros(1,n); bolinha.z = zeros(1,n);

bolinha.vx = zeros(1,n); bolinha.vy = zeros(1,n); bolinha.vz = zeros(1,n);

bolinha.ax = zeros(1,n); bolinha.ay = zeros(1,n); bolinha.az = zeros(1,n);

i = 1;

bolinha.x(i) = pos_i(1); bolinha.y(i) = pos_i(2); bolinha.z(i) = pos_i(3);

bolinha.vx(i) = v_i(1); bolinha.vy(i) = v_i(2); bolinha.vz(i) = v_i(3);

disc = transdutor.disc;
m = bolinha.rho*4/3*pi*bolinha.R^3;
transdutor.R = bolinha.R;
transdutor.nu = 17.2e-6;
t1 =0;

% Teste inicial com integra��o de Euler Explicito
while i <= n-1
    if mod(t_v(i),0.2) == 0
        transdutor.foco = [0; 0; 0.05+t_v(i)*0.0005]; %posi��o focal [m]
        dist = sqrt((x0_v-transdutor.foco(1)).^2 + (y0_v-transdutor.foco(2)).^2 + (z0_v-transdutor.foco(3)).^2);
        phase_v = 2*pi*dist/transdutor.lambda;
        f = find(y0_v>0);
        phase_v(f) = phase_v(f)+pi;
        transdutor.phase = phase_v;

%         clear dist phase_v f x0_v y0_v z0_v
    end
    x = bolinha.x(i); y = bolinha.y(i); z = bolinha.z(i);
    vx = bolinha.vx(i); vy = bolinha.vy(i); vz = bolinha.vz(i);
    v = [vx; vy; vz];
    Fd = calc_Drag(v, bolinha, transdutor);
%     Fd = [0;0;0];
    Fgx = -(Calc_Gorkov_Simulacao_Dinamica(x+disc/2, y, z, transdutor) - ...
        Calc_Gorkov_Simulacao_Dinamica(x-disc/2, y, z, transdutor))/disc;
    Fgy = -(Calc_Gorkov_Simulacao_Dinamica(x, y+disc/2, z, transdutor) - ...
        Calc_Gorkov_Simulacao_Dinamica(x, y-disc/2, z, transdutor))/disc;
    Fgz = -(Calc_Gorkov_Simulacao_Dinamica(x, y, z+disc/2, transdutor) - ...
        Calc_Gorkov_Simulacao_Dinamica(x, y, z-disc/2, transdutor))/disc;
    
    axi = (Fgx+Fd(1))/m; ayi = (Fgy + Fd(2))/m; azi = (Fgz + Fd(3))/m;
    
    vxi = vx + (Fgx+Fd(1))/m*h; vyi = vy + (Fgy+Fd(2))/m*h; vzi = vz + (Fgz+Fd(3))/m*h;
    
    xi = x + vxi*h; yi = y + vyi*h; zi = z + vzi*h;
    
    bolinha.x(i+1) = xi; bolinha.y(i+1) = yi; bolinha.z(i+1) = zi;
    
    bolinha.vx(i+1) = vxi; bolinha.vy(i+1) = vyi; bolinha.vz(i+1) = vzi;
    i = i+1;
end
% K1 = fd(i); L1 = fdd(i); M1 = fddd(i);
% K2 = fd(i)+L1*h/2; L2 = fdd(i)+M1*h/2; M2 = -.5*(f(i)+K1*h/2)*L2;
% K3 = fd(i)+L2*h/2; L3 = fdd(i)+M2*h/2; M3 = -.5*(f(i)+K2*h/2)*L3;
% K4 = fd(i)+L3*h; L4 = fdd(i)+M3*h; M4 = -.5*(f(i)+K3*h)*L4;
% f(i+1) = f(i)+h/6*(K1+2*K2+2*K3+K4);
% fd(i+1) = fd(i)+h/6*(L1+2*L2+2*L3+L4);
% fdd(i+1) = fdd(i)+h/6*(M1+2*M2+2*M3+M4);
% fddd(i+1) = -.5*f(i+1)*fdd(i+1);
% diff = abs(fd(i+1)-fd(i));