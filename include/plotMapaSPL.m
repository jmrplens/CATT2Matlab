%% Plot de Mapa de SPL (3D)
function plotMapaSPL(handles)
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

global RecPosition_00 SPLxRec_00 IDFuente Rango IDRec_00 RoomDimensions_00 GenVideo
global LimVideoMin LimVideoMax PrimFotograma

Resolucion = 200; % Resolucion de linea de la malla

% Posiciones X e Y de los receptores
Posx = RecPosition_00(:,1);
Posy = RecPosition_00(:,2);

% Obtencion del SPL a cada receptor segun la posicion de fuente recibida
Ini = find(strcmp(SPLxRec_00, IDFuente)==1,1);
Fin = find(strcmp(SPLxRec_00, IDFuente)==1,1,'last');
SPLm = SPLxRec_00(Ini:Fin,3:end);

% Obtiene los valores de SPL para todos los rangos de tiempo para la fuente
% actual y todos los receptores
% Separacion e integracion de los niveles antes y despues del rango
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
            ValMS(j)=NaN;
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
    
    SPL0toVal = ValMS(1:Rango);
    SPLValtoInf = ValMS(Rango:end);
    
    SPL0toValM(i) = 10*log10(sum(10.^(SPL0toVal/10)));
    SPLValtoInfM(i) = 10*log10(sum(10.^(SPLValtoInf/10)));
    clearvars ValMS
end

% Ejes donde representar
axes(handles.plotfig)

%% Mapa de 0 a Xms
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
Vplot = gobjects(1,size(IDRec_00,1)+2);
Vplot(1) = surf(Xi,Yi,Zi1);
% Ejes ajustados a los puntos de los extremos
axis 'tight'; hold on
% Puntos para los valores del rango inicial
for k=1:size(IDRec_00,1)
    Vplot(k+2)=plot3(Posx(k),Posy(k),SPL0toValM(k),'.','MarkerSize',15);
end
text(Posx,Posy,SPL0toValM*1.005,...
    strcat('\bf\color{black}',num2str(IDRec_00)),...
    'VerticalAlignment','bottom','HorizontalAlignment','center')%,...
%'\rm - \fontsize{9} ',char(SPL0totext)),...
%'VerticalAlignment','bottom','HorizontalAlignment','center')
% MaxdBpos = find(Z==max(Z(:)));
% text(X(MaxdBpos),Y(MaxdBpos),Z(MaxdBpos)*1.001,sprintf('Max 0 a %d',Rango),...
%     'VerticalAlignment','bottom','HorizontalAlignment','left',...
%     'FontWeight','bold')

%% Mapa de Xms a infinito ms
% Lo mismo que lo anterior para lo valores del rango final
Z = griddata(Posx,Posy,SPLValtoInfM,X,Y,'cubic');

% Extrapolacion/Iterpolacion
F = scatteredInterpolant(X(:),Y(:),Z(:),'linear');

% Obtencion de los niveles para los puntos elegidos Xi, Yi
Zi2 = F(Xi,Yi);

Vplot(2) = surf(Xi,Yi,Zi2);

plot3(Posx,Posy,SPLValtoInfM,'.','MarkerSize',15)
text(Posx,Posy,SPLValtoInfM*1.005,...
    strcat('\bf\color{black}',num2str(IDRec_00)),...
    'VerticalAlignment','bottom','HorizontalAlignment','center')%,...
%'\rm - \fontsize{9} ',char(SPLtoInftext)),...
%'VerticalAlignment','bottom','HorizontalAlignment','center')
% MaxdBpos = find(Z==max(Z(:)));
% text(X(MaxdBpos),Y(MaxdBpos),Z(MaxdBpos)*1.001,sprintf('Max %d a infinito',Rango),...
%     'VerticalAlignment','bottom','HorizontalAlignment','left',...
%     'FontWeight','bold')

% Añadir el punto que representa a la fuente
eval(sprintf('global SRCPosition_%s',IDFuente))
eval(sprintf('SRCPosition = SRCPosition_%s;',IDFuente))
z=max(max(Zi1,Zi2))+1;
plot3(SRCPosition(1),SRCPosition(2),z,'hk','LineWidth',5)
text(SRCPosition(1)+0.25,SRCPosition(2),max(z),...
    ['\bf\color{black} ',handles.LSOURCE,sprintf(': %s',IDFuente)])
hold off

%% Informacion de las graficas
% Definir los colores de las surfaces
colormap([winter(128);autumn(128)])
% Calculos para asignar los colores
cmin = min(min(Zi1(:),Zi2(:)));
cmax = max(max(Zi1(:),Zi2(:)));
% Valor de los datos de color para el plot de 0 a Valor
C1 = min(128,round((128-1)*(Zi1-cmin)/(cmax-cmin))+1);
% Valor de los datos de color para el plot de Valor a inf
C2 = 128+C1;
% Actualizar los colores
set(Vplot(1),'FaceColor','interp','EdgeColor','interp')
set(Vplot(1),'CData',C1);
set(Vplot(2),'FaceColor','interp','EdgeColor','interp')
set(Vplot(2),'CData',C2);
% Ajustar los limites en los ejes de color
caxis([min(C1(:)) max(C2(:))])

% Limite de los ejes
Lx = max(max(Posx),RoomDimensions_00(1));
Ly = max(max(Posy),RoomDimensions_00(2));
% Establecer limite de ejes para respetar el factor de forma
LimEje = max(Lx,Ly);
axis([0,LimEje,0,LimEje,-inf,inf]);
% Añade los titulos
title({[handles.LSPLTITLE,sprintf(' - %d ms',Rango)];...
    ['\color{blue} ',handles.LSUBTITLE,sprintf(': %s',IDFuente)]});
xlabel(handles.LLENGTHX)
ylabel(handles.LLENGTHY)
zlabel(handles.LLEVELDB)
% Imprime una leyenda con el resumen de los datos para cada receptor
leyenda{1} = ['0 ',handles.LWORDTO,sprintf(' %d ms',Rango)];
leyenda{2} = [sprintf('%d ms ',Rango),handles.LTOINF];
for k=1:size(IDRec_00,1)
    % Imprime en la leyenda la posicion en metros
    leyenda{k+2}=sprintf('%2d (%4.1fdB , %4.1fdB)',...
        IDRec_00(k),SPL0toValM(k),SPLValtoInfM(k));
end
lgdw=legend(Vplot,leyenda);
% Si se utiliza Matlab 2014b o anterior no añade el titulo a la leyenda ya
% que no es compatible
if ~verLessThan('matlab','8.7')
    title(lgdw,[handles.LTITLELEGEND,sprintf('\n'),...
        '\color{blue}ID ','(0 ',handles.LWORDTO,sprintf(' %d , %d ',Rango,Rango),handles.LTOINF,')'])
end
lgdw.FontSize = 11;
lgdw.Location = 'bestoutside';

%% Video
% Si se esta realizando un video, se obtiene el maximo y minimo valor desde el
% inicio del video hasta el final y se asignan como limites en el eje z
if GenVideo
    % Si es el primer fotograma del video se calcula los limites de eje para
    % todos los fotogramas
    if PrimFotograma
        for k=1:str2double(get(handles.limvideoms,'String'))
            for i=1:numel(SPLm)
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
                
                SPL0toValM(i) = 10*log10(sum(10.^(ValMS(1:k)/10)));
                SPLValtoInfM(i) = 10*log10(sum(10.^(ValMS(k:end)/10)));
                clearvars ValMS
            end
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
            % Lo mismo que lo anterior para lo valores del rango final
            Z = griddata(Posx,Posy,SPLValtoInfM,X,Y,'cubic');
            
            % Extrapolacion/Iterpolacion
            F = scatteredInterpolant(X(:),Y(:),Z(:),'linear');
            
            % Obtencion de los niveles para los puntos elegidos Xi, Yi
            Zi2 = F(Xi,Yi);
            
            MaxSPL(k) = max(max(Zi1(:),Zi2(:)));
            MinSPL(k) = min(min(Zi1(:),Zi2(:)));
            PrimFotograma = false;
            LimVideoMin = min(MinSPL);
            LimVideoMax = max(MaxSPL);
        end
    end
    % Limite de los ejes
    Lx = max(max(Posx),RoomDimensions_00(1));
    Ly = max(max(Posy),RoomDimensions_00(2));
    % Establecer limite de ejes para respetar el factor de forma
    LimEje = max(Lx,Ly);
    axis([0,LimEje,0,LimEje,LimVideoMin-2,LimVideoMax+2]);
end
