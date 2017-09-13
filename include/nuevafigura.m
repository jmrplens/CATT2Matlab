function figura = nuevafigura(handles,varargin)
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

global NumeroBandas
if ~isempty(varargin)
    visi = varargin{1};
else
    visi = 'on';
end
% Obtener todos los datos de todas la graficas
x = get(findobj(gcf,'type','axes'),'Children');
% Analizar cuales tienen datos
ConDatos = find(~cellfun(@isempty,x));

% Nueva figura con tamaño igual al alto maximo, 3/4 del ancho maximo y centrada
figura = figure('units','normalized','Position',[0.125 0 0.75 1],...
    'Name','Nueva figura',...
    'NumberTitle','off','Visible',visi,...
    'Color', [1 1 1]);
% Si es una representacion de un plot
if size(ConDatos,1)==1
    if verLessThan('matlab','8.7')
        legend = findobj(handles.plotfig.Parent, 'Type', 'legend');
    else
        legend = handles.plotfig.Legend; % Extraer la leyenda
    end
    copyobj([legend,handles.plotfig],figura); % Copia el plot
    caxis(get(handles.plotfig,'CLim'))
    Parent = get(handles.plotfig,'parent');
    colormap(Parent.Colormap)
    set(gca,'Position',[.1 .1 .82 .82]);
    
    % Si es una representacion de 6 o mas plots
elseif size(ConDatos,1)>=6
    
    for i=1:NumeroBandas
        axN = subplot(4,2,i);
        eval(sprintf('fig = handles.subplot%d;',i))
        % Obtener los datos de la figura
        axes_c = findobj(fig,'type','axes');
        % Extraer los children
        Children = get(axes_c,'Children');
        % Extraer los parent
        Parent = get(axes_c,'Parent');
        % Copiar al subplot
        copyobj(Children,axN)
        % Copiar leyenda si la hubiera
        %legend = axes_c.Legend;
        %if ~isempty(legend); copyobj(legend, axN); end
        % Copiar resto de datos
        xlim(axes_c.XLim)
        ylim(axes_c.YLim)
        zlim(axes_c.ZLim)
        caxis(axes_c.CLim)
        % Eje X con las bandas de octava
        set(gca,'XTick',axes_c.XTick)
        set(gca,'XTickLabel',axes_c.XTickLabel)
        set(gca,'YTick',axes_c.YTick)
        set(gca,'YTickLabel',axes_c.YTickLabel)
        set(gca,'ZTick',axes_c.ZTick)
        set(gca,'ZTickLabel',axes_c.ZTickLabel)
        if verLessThan('matlab','8.7')
            if ~isempty(findobj(fig.Parent, 'Type', 'Colorbar'))
                colorbar();
            end
        else
            if ~isempty(axes_c.Colorbar)
                colorbar;
            end
        end
        colormap(Parent.Colormap)
        xlabel(axes_c.XLabel.String)
        ylabel(axes_c.YLabel.String)
        zlabel(axes_c.ZLabel.String)
        title(axes_c.Title.String)
        view(axes_c.View)
        
    end
end
