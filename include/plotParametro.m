%% Plot de parametros acusticos
function plotParametro(Param,handles)
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

global IDRec_00 IDFuente RecPosition_00 seleccionreceptor
% Ejes donde representar
axes(handles.plotfig)
colormap(parula)

eval(sprintf('global SRCPosition_%s',IDFuente))
eval(sprintf('SRCPosition = SRCPosition_%s;',IDFuente))
Param = Param(seleccionreceptor,:);
IDRec = IDRec_00(seleccionreceptor);
RecPosition = RecPosition_00(seleccionreceptor,:);
if get(handles.promediotodo,'Value')==1
    Param = mean(Param);
end

if size(Param,2)==6
    bandas = [125,250,500,1000,2000,4000]; % Bandas para los ejes x de las graficas de parametros
    bandastabla = {'125 Hz','250 Hz','500 Hz','1 KHz','2 KHz','4 KHz'};
    LimX = [100,5000];
elseif size(Param,2)==8
    bandas = [125,250,500,1000,2000,4000,8000,16000];
    bandastabla = {'125 Hz','250 Hz','500 Hz','1 KHz','2 KHz','4 KHz','8 KHz','16 KHz'};
    LimX = [100,20000];
end
% Si esta marcada la opcion de Promedio
if get(handles.promediotodo,'Value')==1
    bar(Param)
    if min(Param)>0
        ylim([0,max(Param)*1.33])
    else
        ylim([min(Param)*1.5,max(Param)*1.33])
    end
    set(gca,'XTickLabel', bandastabla);
    for i1=1:numel(Param)
        if Param(i1)>0
            text(i1,Param(i1),num2str(Param(i1),'%0.2f'),...
                'HorizontalAlignment','center',...
                'VerticalAlignment','bottom')
        else
            text(i1,Param(i1),num2str(Param(i1),'%0.2f'),...
                'HorizontalAlignment','center',...
                'VerticalAlignment','top')
        end
    end
else
    % Plot de todos los datos de la variable actual
    Vplot=semilogx(bandas,Param');
    % Ajusta los ejes
    ylim([min(Param(:))-abs(min(Param(:))*0.1),max(Param(:))+abs(max(Param(:))*0.1)])
    xlim(LimX)
    % Eje X con las bandas de octava
    set(gca,'XTick',bandas)
    set(gca,'XTickLabel',bandastabla)
    % Rejilla
    grid on
    grid minor
end
if strcmp(inputname(1),'T30') || strcmp(inputname(1),'T15') || strcmp(inputname(1),'EDT')
    ylabel(handles.LTIMES)
    L = get(gca,'YLim');
    set(gca,'YTick',floor(L(1)):0.1:ceil(L(2)))
end
if strcmp(inputname(1),'C50') || strcmp(inputname(1),'C80') || strcmp(inputname(1),'G') || strcmp(inputname(1),'SPLTotal')
    ylabel(handles.LVALUEDB)
end
if strcmp(inputname(1),'Ts')
    ylabel(handles.LTIMEMS)
end
if strcmp(inputname(1),'LF') || strcmp(inputname(1),'LFC') || strcmp(inputname(1),'D50')
    ylabel(handles.LVALUEPERCENT)
end
xlabel(handles.LXFREQ)
Distancia = zeros(1,size(RecPosition,1));
for d=1:size(RecPosition,1)
    Distancia(d) = sqrt(...
        (RecPosition(d,1)-SRCPosition(1))^2+...
        (RecPosition(d,2)-SRCPosition(2))^2+...
        (RecPosition(d,3)-SRCPosition(3))^2);
end
DatLey = cat(2,IDRec,Distancia');
for k=1:size(IDRec,1)
    leyenda{k}=sprintf('%2d (%4.2f m)',...
        DatLey(k,1),DatLey(k,2));
end
if get(handles.promediotodo,'Value')==0
    lgdw=legend(Vplot,leyenda);
    % Si se utiliza Matlab 2014b o anterior no añade el titulo a la leyenda ya
    % que no es compatible
    if ~verLessThan('matlab','8.7')
    title(lgdw,[handles.LTITLELEGEND,sprintf('\n'),'\color{blue}',handles.LSUBTITLELEGEND])
    end
    lgdw.FontSize = 11;
    lgdw.Location = 'NorthEastOutside';
end
title({[inputname(1),' CATT'];...
    ['\color{blue} ',handles.LSUBTITLE,sprintf(': %s',IDFuente)]},'fontweight','b');
