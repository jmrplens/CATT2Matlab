
function NumBandas = plotMapaCruce(handles,Tipo)
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

global RecPosition_00 SPLxRec_00 IDFuente Rango RoomDimensions_00 IDRec_00
Posx = RecPosition_00(:,1);
Posy = RecPosition_00(:,2);
% Devuelve el numero de fila donde empieza la fuente
Ini = find(strcmp(SPLxRec_00, IDFuente)==1,1);
Fin = find(strcmp(SPLxRec_00, IDFuente)==1,1,'last');
SPLm = SPLxRec_00(Ini:Fin,3:end);
% Numero de bandas de octava
NumBandas = size(SPLm{1},2)-1;
if NumBandas == 6
    Bandas = {'125 Hz','250 Hz','500 Hz','1 KHz','2 KHz','4 KHz'};
elseif NumBandas == 8
    Bandas = {'125 Hz','250 Hz','500 Hz','1 KHz','2 KHz','4 KHz','8 KHz','16 KHz'};
end

% Si es una representacion por octavas
if Tipo==1
    % Obtiene los valores de SPL para todos los rangos de tiempo para la fuente
    % actual y todos los receptores
    % Separacion e integracion de los niveles antes y despues del rango por octavas
    SPL0toValM = zeros(numel(SPLm),NumBandas);
    SPLValtoInfM = zeros(numel(SPLm),NumBandas);
    for i=1:numel(SPLm)
        % En primer lugar agrupa los niveles en bloques de 1 milisegundo, ya que hay
        % varios niveles por milisegundo, y promedia los valores de cada bloque
        for j=1:max(ceil(SPLm{i}(:,1)))
            Ini = find(SPLm{i}(:,1)>=j-1,1); % Inicio del bloque de 'j' milisegundos
            Fin = find(SPLm{i}(:,1)>j,1)-1; % Fin del bloque de 'j' milisegundos
            % Si ha llegado al final del vector, fin estara vacio y inicio y fin
            % seran iguales para obtener el valor ultimo del vector
            if isempty(find(SPLm{i}(:,1)>j,1)); Fin=Ini; end
            % Si el bloque del milisegundo 'j' existe, ini sera menor o igual a fin,
            % si no existe ini sera mayor a fin y no habra valor en ese milisegundo.
            if Ini<=Fin
                Valores = SPLm{i}(Ini:Fin,2:end);
                % Suma el bloque por octavas
                ValMS(j,:) = 10*log10(sum(10.^(Valores/10),1));
            else
                ValMS(j,:)=NaN;
            end
            
        end
        % Si se utiliza matlab 2014b o anterior realiza la interpolacion
        % manualmente, sino utiliza la funcion fillmising
        if verLessThan('matlab','8.7')
            % Interpolacion manual
            bd=isnan(ValMS);
            gd=find(~bd);
            bd([1:(min(gd)-1) (max(gd)+1):end])=0;
            ValMS(bd)=interp1(gd,ValMS(gd),find(bd));
        else
            % Interpolar valores en los milisegundos que haya valor 0, desde el inicio
            % al final del vector
            ValMS = fillmissing(ValMS,'linear','EndValues','extrap');
        end
        
        SPL0toVal = ValMS(1:Rango,:);
        SPLValtoInf = ValMS(Rango:end,:);
        
        SPL0toValM(i,:) = 10*log10(sum(10.^(SPL0toVal/10)));
        SPLValtoInfM(i,:) = 10*log10(sum(10.^(SPLValtoInf/10)));
        clearvars ValMS
    end
    
    % Representacion de cada octava en un plot diferente
    for band=1:NumBandas
        eval(sprintf('axes(handles.subplot%d)',band))
        Representar(band,SPL0toValM,SPLValtoInfM,Bandas,RoomDimensions_00,Rango,Posx,Posy,IDFuente,handles)
    end
    % Si es una representacion de nivel global
elseif Tipo==2
    % Obtiene los valores de SPL para todos los rangos de tiempo para la fuente
    % actual y todos los receptores
    % Separacion e integracion de los niveles antes y despues del rango por octavas
    SPL0toValM = zeros(1,numel(SPLm));
    SPLValtoInfM = zeros(1,numel(SPLm));
    for i=1:numel(SPLm)
        % En primer lugar agrupa los niveles en bloques de 1 milisegundo, ya que hay
        % varios niveles por milisegundo, y promedia los valores de cada bloque
        for j=1:max(ceil(SPLm{i}(:,1)))
            Ini = find(SPLm{i}(:,1)>=j-1,1); % Inicio del bloque de 'j' milisegundos
            Fin = find(SPLm{i}(:,1)>j,1)-1; % Fin del bloque de 'j' milisegundos
            % Si ha llegado al final del vector, fin estara vacio y inicio y fin
            % seran iguales para obtener el valor ultimo del vector
            if isempty(find(SPLm{i}(:,1)>j,1)); Fin=Ini; end
            % Si el bloque del milisegundo 'j' existe, ini sera menor o igual a fin,
            % si no existe ini sera mayor a fin y no habra valor en ese milisegundo.
            if Ini<=Fin
                Valores = SPLm{i}(Ini:Fin,2:end);
                % Suma el bloque por octavas y vuelve a sumar para obtener un valor
                ValMS(j) = 10*log10(sum(sum(10.^(Valores/10),1)));
            else
                ValMS(j)=0;
            end
            
        end
        % Todos los valores 0 y menores a 0 se dejan vacios
        ValMS(ValMS<=0) = NaN;
        % Si se utiliza matlab 2014b o anterior realiza la interpolacion
        % manualmente, sino utiliza la funcion fillmising
        if verLessThan('matlab','8.7')
            % Interpolacion manual
            bd=isnan(ValMS);
            gd=find(~bd);
            bd([1:(min(gd)-1) (max(gd)+1):end])=0;
            ValMS(bd)=interp1(gd,ValMS(gd),find(bd));
        else
            % Interpolar valores en los milisegundos que haya valor 0, desde el inicio
            % al final del vector
            ValMS = fillmissing(ValMS,'linear','EndValues','extrap');
        end
        
        SPL0toVal = ValMS(1:Rango);
        SPLValtoInf = ValMS(Rango:end);
        
        SPL0toValM(i) = 10*log10(sum(10.^(SPL0toVal/10)));
        SPLValtoInfM(i) = 10*log10(sum(10.^(SPLValtoInf/10)));
        clearvars ValMS
    end
    
    % Ejes donde representar
    axes(handles.plotfig)
    
    Resolucion = 200;
    
    %% De 0 a Xms y de Xms a infinito
    % Crea una resolucion de 200x200 lineas en el plano X,Y
    xlin = linspace(min(Posx),max(Posx),Resolucion);
    ylin = linspace(min(Posy),max(Posy),Resolucion);
    % Genera la malla
    [X,Y] = meshgrid(xlin,ylin);
    Z = griddata(Posx,Posy,SPL0toValM,X,Y,'cubic');
    % Extrapolacion/Iterpolacion
    F = scatteredInterpolant(X(:),Y(:),Z(:),'linear');
    % Genera la malla para obtener niveles desde 0 metros a las dimensiones de la
    % sala mas 0.5 metros
    [Xi,Yi] = ndgrid(...
        0:0.1:max(max(RoomDimensions_00(1),Posx(:)))+0.5,...
        0:0.1:max(max(RoomDimensions_00(2),Posy(:)))+0.5...
        );
    % Obtencion de los niveles para los puntos elegidos Xi, Yi
    Zi1 = F(Xi,Yi);
    
    surf(Xi,Yi,Zi1,'FaceColor','b','FaceAlpha',1,'EdgeAlpha', 0);
    % Ejes ajustados a los puntos de los extremos
    axis 'tight'; hold on
    % Puntos para los valores del rango inicial
    plot3(Posx,Posy,SPL0toValM,'.black','MarkerSize',15);
    
    text(Posx,Posy+0.05,SPL0toValM*1.005,...
        strcat('\bf\color{black}',num2str(IDRec_00)),...
        'VerticalAlignment','bottom','HorizontalAlignment','center')
    
    % Lo mismo que lo anterior para lo valores del rango final
    Z = griddata(Posx,Posy,SPLValtoInfM,X,Y,'cubic');
    
    % Extrapolacion/Iterpolacion
    F = scatteredInterpolant(X(:),Y(:),Z(:),'linear');
    
    % Obtencion de los niveles para los puntos elegidos Xi, Yi
    Zi2 = F(Xi,Yi);
    
    surf(Xi,Yi,Zi2,'FaceColor','r','FaceAlpha',1,'EdgeAlpha', 0);
    
    plot3(Posx,Posy,SPLValtoInfM,'.black','MarkerSize',15)
    text(Posx,Posy+0.05,SPLValtoInfM*1.005,...
        strcat('\bf\color{black}',num2str(IDRec_00)),...
        'VerticalAlignment','bottom','HorizontalAlignment','center')
    
    % Añadir el punto que representa a la fuente
    eval(sprintf('global SRCPosition_%s',IDFuente))
    eval(sprintf('SRCPosition = SRCPosition_%s;',IDFuente))
    z=max(max(Zi1(:),Zi2(:)))+1;
    plot3(SRCPosition(1),SRCPosition(2),z,'hk','LineWidth',5)
    text(SRCPosition(1),SRCPosition(2)+0.05,z,...
        ['\bf\color{black} ',handles.LSOURCE,sprintf(': %s',IDFuente)],...
        'VerticalAlignment','bottom','HorizontalAlignment','center')
    hold off
    view(0,90)
    % Limite de los ejes
    Lx = max(max(RecPosition_00(:,1)),RoomDimensions_00(1));
    Ly = max(max(RecPosition_00(:,2)),RoomDimensions_00(2));
    % Establecer limite de ejes para respetar el factor de forma
    LimEje = max(Lx,Ly);
    axis([0,LimEje,0,LimEje]);
    grid off
    % Añade los ejes
    title({[handles.LTITLECROSSRANK,sprintf(' - %d ms',Rango)];...
        ['\color{blue} ',handles.LSUBTITLE,sprintf(': %s',IDFuente)]});
    xlabel(handles.LLENGTHX)
    ylabel(handles.LLENGTHY)
    zlabel(handles.LLEVELDB)
    
end

%% Representacion grafica del mapa en cualquier banda
function Representar(band,SPL0toValM,SPLValtoInfM,Bandas,RoomDimensions_00,Rango,Posx,Posy,IDFuente,handles)

% Crea una resolucion de 200x200 lineas en el plano X,Y
Resolucion = 200;
xlin = linspace(min(Posx),max(Posx),Resolucion);
ylin = linspace(min(Posy),max(Posy),Resolucion);
% Genera la malla
[X,Y] = ndgrid(xlin,ylin);
% Incluye para cada posicion su valor de nivel
Z = griddata(Posx,Posy,SPL0toValM(:,band),X,Y,'cubic');

% Extrapolacion/Iterpolacion
F = scatteredInterpolant(X(:),Y(:),Z(:),'linear');
% Genera la malla para obtener niveles desde 0 metros a las dimensiones de la
% sala mas 0.5 metros
[Xi,Yi] = ndgrid(...
    0:0.1:max(max(RoomDimensions_00(1),Posx(:)))+0.5,...
    0:0.1:max(max(RoomDimensions_00(2),Posy(:)))+0.5...
    );
% Obtencion de los niveles para los puntos elegidos Xi, Yi
Zi1 = F(Xi,Yi);

% Representacion
surf(Xi,Yi,Zi1,'FaceColor','b','FaceAlpha',1,'EdgeAlpha', 0)

% Ejes ajustados a los puntos de los extremos
axis tight
hold on

% Lo mismo que lo anterior para lo valores del rango final
Z = griddata(Posx,Posy,SPLValtoInfM(:,band),X,Y,'cubic');
% Extrapolacion/Iterpolacion
F = scatteredInterpolant(X(:),Y(:),Z(:),'linear');
% Obtencion de los niveles para los puntos elegidos Xi, Yi
Zi2 = F(Xi,Yi);
% Representacion
surf(Xi,Yi,Zi2,'FaceColor','r','FaceAlpha',1,'EdgeAlpha', 0)

% Añadir el punto que representa a la fuente
eval(sprintf('global SRCPosition_%s',IDFuente))
eval(sprintf('SRCPosition = SRCPosition_%s;',IDFuente))
z=max(max(Zi1(:),Zi2(:)))+1;
plot3(SRCPosition(1),SRCPosition(2),z,'hk','LineWidth',5)
text(SRCPosition(1)+0.1,SRCPosition(2),z,...
    ['\bf\color{black} ',handles.LSOURCE,sprintf(': %s',IDFuente)],...
    'VerticalAlignment','middle','HorizontalAlignment','left')
hold off

view(0,90)
% Limite de los ejes
Lx = max(max(Posx),RoomDimensions_00(1));
Ly = max(max(Posy),RoomDimensions_00(2));
% Establecer limite de ejes para respetar el factor de forma
LimEje = max(Lx,Ly);
axis([0,LimEje,0,LimEje]);
grid off
box on
% Añade los ejes
title([sprintf('\\color{black}%s \\color{blue}[0-%d \\color{red}%d-Inf]\\color{black} '...
    ,char(Bandas(band)),Rango,Rango),handles.LSOURCE,sprintf(': %s',IDFuente)]);
xlabel(handles.LLENGTHX)
ylabel(handles.LLENGTHY)
zlabel(handles.LLEVELDB)
% Modifica la posicion del XLabel para posicionarlo un poco mas arriba
xlabh = get(gca,'XLabel');
set(xlabh,'Position',get(xlabh,'Position') + [0 .2 0])