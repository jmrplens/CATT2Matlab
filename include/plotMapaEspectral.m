function NumBandas = plotMapaEspectral(handles,Tipo)
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

global RecPosition_00 SPLxRec_00 IDFuente Rango RoomDimensions_00

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
            ValMS(j,:)=0;
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
    
    SPL0toVal = ValMS(1:Rango,:);
    SPLValtoInf = ValMS(Rango:end,:);
    
    SPL0toValM(i,:) = 10*log10(sum(10.^(SPL0toVal/10)));
    SPLValtoInfM(i,:) = 10*log10(sum(10.^(SPLValtoInf/10)));
end

Resolucion=200;
if Tipo==1
    % Mapa de 0 a Val
    for i=1:NumBandas
        eval(sprintf('axes(handles.subplot%d)',i))
        mini = min(min(SPL0toValM(:)));
        maxi = max(max(SPL0toValM(:)));
        % Crea una resolucion de 200x200 lineas en el plano X,Y
        xlin = linspace(min(Posx),max(Posx),Resolucion);
        ylin = linspace(min(Posy),max(Posy),Resolucion);
        % Genera la malla
        [X,Y] = meshgrid(xlin,ylin);
        Z = griddata(Posx,Posy,SPL0toValM(:,i),X,Y,'cubic');
        % Extrapolacion/Iterpolacion
        F = scatteredInterpolant(X(:),Y(:),Z(:),'nearest');
        % Genera la malla para obtener niveles desde 0 metros a las dimensiones de la
        % sala mas 0.5 metros
        [Xi,Yi] = ndgrid(...
            0:0.1:max(max(RoomDimensions_00(1),Posx(:)))+0.5,...
            0:0.1:max(max(RoomDimensions_00(2),Posy(:)))+0.5...
            );
        % Obtencion de los niveles para los puntos elegidos Xi, Yi
        Zi = F(Xi,Yi);
        
        contourf(Xi,Yi,Zi,'ShowText','on')
        colormap(parula)
        caxis([mini, maxi])
        colorbar;
        
        % Añadir el punto que representa a la fuente
        hold on
        eval(sprintf('global SRCPosition_%s',IDFuente))
        eval(sprintf('SRCPosition = SRCPosition_%s;',IDFuente))
        z=max(Zi)+1;
        plot3(SRCPosition(1),SRCPosition(2),z,'hk','LineWidth',5)
        hold off
        
        % Limite de los ejes
        Lx = max(max(Posx),RoomDimensions_00(1));
        Ly = max(max(Posy),RoomDimensions_00(2));
        % Establecer limite de ejes para respetar el factor de forma
        LimEje = max(Lx,Ly);
        axis([0,LimEje,0,LimEje]);
        grid off
        
        title([handles.LLEVEL,...
            sprintf(' 0-%d ms - %s - ',Rango,char(Bandas(i))),...
            handles.LSOURCE,sprintf(': %s',IDFuente)])
        xlabel(handles.LLENGTHX)
        ylabel(handles.LLENGTHY)
        % Modifica la posicion del XLabel para posicionarlo un poco mas arriba
        xlabh = get(gca,'XLabel');
        set(xlabh,'Position',get(xlabh,'Position') + [0 .2 0])
    end
elseif Tipo==2
    % Mapa de Val a Inf
    for i=1:NumBandas
        eval(sprintf('axes(handles.subplot%d)',i))
        
        mini = min(min(SPLValtoInfM(:)));
        maxi = max(max(SPLValtoInfM(:)));
        % Crea una resolucion de 200x200 lineas en el plano X,Y
        xlin = linspace(min(Posx),max(Posx),Resolucion);
        ylin = linspace(min(Posy),max(Posy),Resolucion);
        % Genera la malla
        [X,Y] = meshgrid(xlin,ylin);
        Z = griddata(Posx,Posy,SPLValtoInfM(:,i),X,Y,'cubic'); %#ok<*GRIDD>
        
        F = scatteredInterpolant(X(:),Y(:),Z(:),'nearest');
        % Genera la malla para obtener niveles desde 0 metros a las dimensiones de la
        % sala mas 0.5 metros
        [Xi,Yi] = ndgrid(...
            0:0.1:max(max(RoomDimensions_00(1),Posx(:)))+0.5,...
            0:0.1:max(max(RoomDimensions_00(2),Posy(:)))+0.5...
            );
        % Obtencion de los niveles para los puntos elegidos Xi, Yi
        Zi = F(Xi,Yi);
        
        contourf(Xi,Yi,Zi,'ShowText','on')
        colormap(parula)
        caxis([mini, maxi])
        colorbar;
        
        % Añadir el punto que representa a la fuente
        hold on
        eval(sprintf('global SRCPosition_%s',IDFuente))
        eval(sprintf('SRCPosition = SRCPosition_%s;',IDFuente))
        z=max(Zi)+1;
        plot3(SRCPosition(1),SRCPosition(2),z,'hk','LineWidth',5)
        hold off
        
        % Limite de los ejes
        Lx = max(max(Posx),RoomDimensions_00(1));
        Ly = max(max(Posy),RoomDimensions_00(2));
        % Establecer limite de ejes para respetar el factor de forma
        LimEje = max(Lx,Ly);
        axis([0,LimEje,0,LimEje]);
        grid off
        
        title([handles.LLEVEL,...
            sprintf(' %d-Inf ms - %s - ',Rango,char(Bandas(i))),...
            handles.LSOURCE,sprintf(': %s',IDFuente)])
        xlabel(handles.LLENGTHX)
        ylabel(handles.LLENGTHY)
        % Modifica la posicion del XLabel para posicionarlo un poco mas arriba
        xlabh = get(gca,'XLabel');
        set(xlabh,'Position',get(xlabh,'Position') + [0 .2 0])
    end
end
end