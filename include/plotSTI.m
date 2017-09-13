function plotSTI(xSTI,handles)
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

global RecPosition_00 IDFuente RoomDimensions_00 IDRec_00

% Obtener el nombre de la variable enviada
Nombre = inputname(1);
% Segun el nombre se asignan unos textos para utilizar en el titulo y la leyenda
if strcmp(Nombre,'Rasti')
    TextxSTI = 'RASTI';
    Titulo = ['RASTI ', handles.LWITHOUTNOISE];
elseif strcmp(Nombre,'RastiWithNoise')
    TextxSTI = 'RASTI';
    Titulo = ['RASTI ', handles.LWITHNOISE];
elseif strcmp(Nombre,'STI')
    TextxSTI = 'STI';
    Titulo = ['STI ', handles.LWITHOUTNOISE];
elseif strcmp(Nombre,'STIWithNoise')
    TextxSTI = 'STI';
    Titulo = ['STI ', handles.LWITHNOISE];
end

% Obtener las posiciones en X e Y de los receptores
Posx = RecPosition_00(:,1);
Posy = RecPosition_00(:,2);

% Ejes donde representar
axes(handles.plotfig)

% Resolucion de la malla
Resolucion = 200;

% Crea una resolucion de 200x200 lineas en el plano X,Y
xlin = linspace(min(Posx),max(Posx),Resolucion);
ylin = linspace(min(Posy),max(Posy),Resolucion);
% Genera la malla
[X,Y] = meshgrid(xlin,ylin);
Z = griddata(Posx,Posy,xSTI,X,Y,'cubic');
% Extrapolacion/Iterpolacion
F = scatteredInterpolant(X(:),Y(:),Z(:));
% Genera la malla para obtener niveles desde 0 metros a las dimensiones de la
% sala mas 0.5 metros
[Xi,Yi] = ndgrid(...
    0:0.1:max(max(RoomDimensions_00(1),Posx(:)))+0.5,...
    0:0.1:max(max(RoomDimensions_00(2),Posy(:)))+0.5...
    );
% Obtencion de los niveles para los puntos elegidos Xi, Yi
Zi = F(Xi,Yi);

% Representar el mapa
contourf(Xi,Yi,Zi,'LevelStep',0.5,'LineStyle','none')
colormap(parula)

% Ejes ajustados a los puntos de los extremos
axis 'tight'; hold on
% Limite de los ejes
Lx = max(max(Posx),RoomDimensions_00(1));
Ly = max(max(Posy),RoomDimensions_00(2));
% Establecer limite de ejes para respetar el factor de forma
LimEje = max(Lx,Ly);
axis([0,LimEje,0,LimEje]);

% Marcar las posiciones de los receptores en el mapa
Recep = gobjects(1,size(IDRec_00,1));
for k=1:size(IDRec_00,1)
    Recep(k) = plot3(Posx(k),Posy(k),xSTI(k),'.','MarkerSize',15);
end
% Texto con la ID de cada receptor en la marca de cada receptor
text(Posx,Posy+0.05,xSTI*1.005,...
    strcat('\bf\color{red}',num2str(IDRec_00)),...
    'VerticalAlignment','bottom','HorizontalAlignment','center')

% Titulo y ejes
title({Titulo;...
    ['\color{blue} ',handles.LSUBTITLE,sprintf(': %s',IDFuente)]});
xlabel(handles.LLENGTHX)
ylabel(handles.LLENGTHY)

% Generar vector de string para la leyenda
for k=1:size(IDRec_00,1)
    leyenda{k}=sprintf('%2d (%4.1f)',...
        IDRec_00(k),xSTI(k));
end

% Crea la leyenda para los marcadores
lgdw=legend(Recep,leyenda);
% Si se utiliza Matlab 2014b o anterior no añade el titulo a la leyenda ya
% que no es compatible
if ~verLessThan('matlab','8.7')
    title(lgdw,[handles.LTITLELEGEND,sprintf('\n'),...
        '\color{blue}ID (',TextxSTI,')'])
end
lgdw.FontSize = 10;
lgdw.Location = 'bestoutside';
