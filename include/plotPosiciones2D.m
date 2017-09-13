%% Plot de posiciones 2D
function plotPosiciones2D(handles)
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

global RecPosition_00 IDFuente IDRec_00 RoomDimensions_00
% Ejes donde representar
axes(handles.plotfig)

cla reset; % Borrar el plot
eval(sprintf('global SRCPosition_%s',IDFuente))
eval(sprintf('SRCPosition = SRCPosition_%s;',IDFuente))
% Plot de posiciones visto desde arriba
hold on;
% Añade al plot cada posicion de receptor
Vplot = gobjects(1,size(RecPosition_00,1)+1);
for k=1:size(RecPosition_00,1)
    Vplot(k)=plot(RecPosition_00(k,1),RecPosition_00(k,2),'.');
end
% Añadir punto de la fuente
Vplot(k+1)=plot(SRCPosition(1),SRCPosition(2),'p'); %#ok<NODEF>

DatLey = cat(2,IDRec_00,RecPosition_00(:,1:2));
for k=1:size(IDRec_00,1)
    % Imprime en la leyenda la posicion en metros
    leyenda{k}=sprintf('%2d (%4.1f,%4.1f)',...
        DatLey(k,1),DatLey(k,2),DatLey(k,3));
end

% Limite de los ejes
Lx = max(max(RecPosition_00(:,1)),RoomDimensions_00(1));
Ly = max(max(RecPosition_00(:,2)),RoomDimensions_00(2));
% Añadir lineas que delimitan las dimensiones de la sala
X = [0,0,Lx,Lx,0];
Y = [0,Ly,Ly,0,0];
plot(X,Y,'-b','LineWidth',1.5)
hold off;
% Establecer limite de ejes para respetar el factor de forma
LimEje = max(Lx,Ly);
axis([0,LimEje,0,LimEje]);
% Añadir info de la fuente en la leyenda
leyenda{k+1}=[handles.LSOURCE,sprintf(' (%4.1f,%4.1f)',...
    SRCPosition(1),SRCPosition(2))];
lgdw=legend(Vplot,leyenda);
% Si se utiliza Matlab 2014b o anterior no añade el titulo a la leyenda ya
% que no es compatible
if ~verLessThan('matlab','8.7')
    title(lgdw,[handles.LTITLELEGEND,sprintf('\n'),'\color{blue}ID (X,Y)(m)'])
end
lgdw.FontSize = 11;
lgdw.Location = 'northeastoutside';
text(RecPosition_00(:,1),RecPosition_00(:,2),num2str(IDRec_00),...
    'VerticalAlignment','bottom','HorizontalAlignment','right')
text(SRCPosition(:,1),SRCPosition(:,2),[handles.LSOURCE,sprintf(': %s',IDFuente)],...
    'VerticalAlignment','top','HorizontalAlignment','left')
title({handles.LTITLEMAPPOS;...
    ['\color{blue} ',handles.LSUBTITLE,sprintf(': %s',IDFuente)]});
xlabel(handles.LLENGTHX)
ylabel(handles.LLENGTHY)
