%% Plot de posiciones 3D
function plotPosiciones3D(handles)
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

global RecPosition_00 IDFuente IDRec_00 RoomDimensions_00

% Ejes donde representar
axes(handles.plotfig)

eval(sprintf('global SRCPosition_%s',IDFuente))
eval(sprintf('SRCPosition = SRCPosition_%s;',IDFuente))
% Crear los puntos para poder formar un cubo cerrado
% {0,0,0}{X,0,0}{X,Y,0}{0,Y,0}{0,0,0}
% La sala debe haber sido modelada desde el Origen a valores positivos
% de los ejes, sino se representará mal ya que catt no devuelve las
% dimensiones de la sala respecto al origen sino el total
Lx = max(max(RecPosition_00(:,1)),RoomDimensions_00(1));
Ly = max(max(RecPosition_00(:,2)),RoomDimensions_00(2));
Lz = max(max(RecPosition_00(:,3)),RoomDimensions_00(3));
X = [0;Lx;Lx;0;0];
Y = [0;0;Ly;Ly;0];
Z = [0;0;0;0;0];
hold on;
plot3(X,Y,Z); % Dibuja un cuadrado en xy sobre el minimo del eje Z
plot3(X,Y,Z+Lz); % Dibuja un cuadrado en xy sobre el maximo del eje Z
set(gca,'View',[-28,35]); % Configura la vista del plot
% Unir las esquinas para crear un cubo
for k=1:length(X)-1
    plot3([X(k);X(k)],[Y(k);Y(k)],[0;RoomDimensions_00(3)]);
end
% Añade al plot cada posicion de receptor
Vplot = gobjects(1,size(RecPosition_00,1)+1);
for k=1:size(RecPosition_00,1)
    Vplot(k)=plot3(RecPosition_00(k,1),...
        RecPosition_00(k,2),...
        RecPosition_00(k,3),'.');
end
% Añade al plot la posicion de la fuente
Vplot(k+1)=plot3(SRCPosition(1),SRCPosition(2),SRCPosition(3),'p');
hold off;
% Establecer limite de ejes para respetar el factor de forma
LimEje = max(Lx,Ly);
axis([0,LimEje,0,LimEje,0,LimEje]);

DatLey = cat(2,IDRec_00,RecPosition_00);
for k=1:size(IDRec_00,1)
    % Imprime en la leyenda la posicion en metros
    leyenda{k}=sprintf('%2d (%4.1f,%4.1f,%4.1f)',...
        DatLey(k,1),DatLey(k,2),DatLey(k,3),DatLey(k,4));
end
leyenda{k+1}=[handles.LSOURCE,sprintf(' (%4.1f,%4.1f,%4.1f)',...
    SRCPosition(1),SRCPosition(2),SRCPosition(3))];
lgdw=legend(Vplot,leyenda);
% Si se utiliza Matlab 2014b o anterior no añade el titulo a la leyenda ya
% que no es compatible
if ~verLessThan('matlab','8.7')
    title(lgdw,[handles.LTITLELEGEND,sprintf('\n'),'\color{blue}ID (X,Y,Z)(m)'])
end
lgdw.FontSize = 11;

% Añadir la ID de los receptores
text(RecPosition_00(:,1),RecPosition_00(:,2),RecPosition_00(:,3),...
    num2str(IDRec_00),...
    'VerticalAlignment','bottom','HorizontalAlignment','right')
text(SRCPosition(1),SRCPosition(2),SRCPosition(3),...
    [handles.LSOURCE,sprintf(': %s',IDFuente)],...
    'VerticalAlignment','top','HorizontalAlignment','left')
title({handles.LTITLEMAPPOS;...
    ['\color{blue} ',handles.LSUBTITLE,sprintf(': %s',IDFuente)]});
xlabel(handles.LLENGTHX)
ylabel(handles.LLENGTHY)
zlabel(handles.LLENGTHZ)