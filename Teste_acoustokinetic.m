%% Par�metros de entrada
clear
clc
close
% Do transdutor
transdutor.freq = 4e4; %frequencia [Hz]
transdutor.c = 340; % velocidade do som [m/s]
transdutor.A = 7*.462; %Amplitude [Pa]
transdutor.rho0 = 1.2; %Massa espec�fica do ar [kg/m^3]
transdutor.lambda = transdutor.c/transdutor.freq; %Comprimento de onda [m]
transdutor.omega = 2*pi*transdutor.freq; %frequ�ncia angular [rad/s]
transdutor.k = transdutor.omega/transdutor.c; %n�mero de onda [1/m]
transdutor.a = 4.9e-3; %raio do pist�o circular [m]
transdutor.disc = transdutor.lambda/1000*2; %Discretiza��o [m]

% Posi��o e dire��o dos transdutores
[x0_v, y0_v] = meshgrid(-10.16*3.5:10.16:10.16*3.5,-10.16*3.5:10.16:10.16*3.5);
x0_v = 1e-3*reshape(x0_v,[64,1]);
y0_v = 1e-3*reshape(y0_v,[64,1]);
z0_v = zeros(64,1);
transdutor.posx = x0_v;
transdutor.posy = y0_v;
transdutor.posz = z0_v;

transdutor.normal = [0 0 1];
transdutor.foco = [0e-3; 0; 30e-3]; %posi��o focal [m]
% Da esfera
bolinha.rho = 30; %Densidade da bolinha [kg/m^3]
bolinha.R = 1.35e-3; %Raio da esfera [m]
pos_i = [0.97278e-3; 0; 29.235e-3 ]; %Posi��o inicial da bolinha [m]
v_i = [0; 0; 0]; %Velocidade inicial da bolinha [m/s]
% Da simula��o din�mica
% h = 0.5e-3; %Discretiza��o do tempo (passo de integra��o)
% ti = 0;
% tf = 5; %Tempo final
% t_v = ti:h:tf;

%% Vari�veis calculadas
dist = sqrt((x0_v-transdutor.foco(1)).^2 + (y0_v-transdutor.foco(2)).^2 + (z0_v-transdutor.foco(3)).^2);
phase_v = 2*pi*dist/transdutor.lambda;
f = find(x0_v>0);
phase_v(f) = phase_v(f)+pi;
transdutor.phase = phase_v;

clear dist phase_v f x0_v y0_v z0_v

%% Simula��o din�mica
i = 1;
bolinha.z = 0e-3:0.1e-3:70e-3;
n = length(bolinha.z);
bolinha.x = 30e-3*zeros(1,n); bolinha.y = zeros(1,n);
bolinha.vx = zeros(1,n); bolinha.vy = zeros(1,n); bolinha.vz = zeros(1,n);
disc = transdutor.disc;
m = bolinha.rho*4/3*pi*bolinha.R^3;
transdutor.R = bolinha.R;
transdutor.nu = 17.2e-6;
% Teste inicial com integra��o de Euler Explicito
while i <= n
    x = bolinha.x(i); y = bolinha.y(i); z = bolinha.z(i);
    vx = bolinha.vx(i); vy = bolinha.vy(i); vz = bolinha.vz(i);
    v = [vx; vy; vz];
%     Fd = [0;0;0];
    Fgxg = -(Calc_Gorkov_Simulacao_Dinamica(x+disc/2, y, z, transdutor) - Calc_Gorkov_Simulacao_Dinamica(x-disc/2, y, z, transdutor))/disc;
    Fgyg = -(Calc_Gorkov_Simulacao_Dinamica(x, y+disc/2, z, transdutor) - Calc_Gorkov_Simulacao_Dinamica(x, y-disc/2, z, transdutor))/disc;
    Fgzg = -(Calc_Gorkov_Simulacao_Dinamica(x, y, z+disc/2, transdutor) - Calc_Gorkov_Simulacao_Dinamica(x, y, z-disc/2, transdutor))/disc;
    bolinha.Fgxg(i) = Fgxg;
    bolinha.Fgyg(i) = Fgyg;
    bolinha.Fgzg(i) = Fgzg;
    [F] = Acoustokinetics_2(x, y, z, transdutor);
    Fgx = F(1); Fgy = F(2); Fgz = F(3);
    bolinha.Fgx(i) = Fgx;
    bolinha.Fgy(i) = Fgy;
    bolinha.Fgz(i) = Fgz;
    i = i+1;
end
% U = Calc_Gorkov(bolinha.x,bolinha.y,bolinha.z,transdutor);
% figure(1)
% surf(xs,zs, U);
% colormap(jet) 
% shading interp
% view(2)
% % caxis([-2000 2000])
% axis equal
% colorbar
% 
% figure(1)
% plot(bolinha.z, bolinha.Fgx)
% hold on
% plot(bolinha.z, bolinha.Fgxg)

figure(3);
plot(bolinha.z*1e3, bolinha.Fgz*1e6,'LineWidth', 1.5);
hold on;
plot(bolinha.z*1e3, bolinha.Fgzg*1e6,'LineWidth', 1.5);
grid on;
xlabel('Eixo z [mm]');
ylabel('For�a no eixo z [\muN]');
legend('Ac�stica cin�tica', 'Gor''kov');
saveas(3,'D:\Usuarios\IC\Relat�rio final FAPESP\Imagens\Grafico_Fz_z.png');