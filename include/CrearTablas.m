function CrearTablas(handles)
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

global CarpetaTemp
Ruta = strcat(CarpetaTemp,filesep,'Tablas.mat');
RutaISM = strcat(CarpetaTemp,filesep,'Tablas_ISM.mat');
if exist(Ruta,'file'); delete(Ruta); end
if exist(RutaISM,'file'); delete(RutaISM); end
multiWaitbar(handles,handles.LCREATETPARAM,0,'color','r');
% Vector de nombres de variables que coinciden con la busqueda.
Array = who('global','-regexp', 'T30');
if ~isempty(Array); creartabla(Array); end

Array = who('global','-regexp', 'T15');
if ~isempty(Array); creartabla(Array); end
multiWaitbar(handles,handles.LCREATETPARAM,0.1,'color','r');
Array = who('global','-regexp', 'EDT');
if ~isempty(Array); creartabla(Array); end
multiWaitbar(handles,handles.LCREATETPARAM,0.2,'color','r');
Array = who('global','-regexp', 'G_');
if ~isempty(Array); creartabla(Array); end
multiWaitbar(handles,handles.LCREATETPARAM,0.3,'color','r');
Array = who('global','-regexp', 'LF_');
if ~isempty(Array); creartabla(Array); end
multiWaitbar(handles,handles.LCREATETPARAM,0.4,'color','r');
Array = who('global','-regexp', 'LFC');
if ~isempty(Array); creartabla(Array); end
multiWaitbar(handles,handles.LCREATETPARAM,0.5,'color','r');
Array = who('global','-regexp', 'C80');
if ~isempty(Array); creartabla(Array); end
multiWaitbar(handles,handles.LCREATETPARAM,0.6,'color','r');
Array = who('global','-regexp', 'C50');
if ~isempty(Array); creartabla(Array); end
multiWaitbar(handles,handles.LCREATETPARAM,0.7,'color','r');
Array = who('global','-regexp', 'D50');
if ~isempty(Array); creartabla(Array); end
multiWaitbar(handles,handles.LCREATETPARAM,0.8,'color','r');
Array = who('global','-regexp', 'Ts_');
if ~isempty(Array); creartabla(Array); end
multiWaitbar(handles,handles.LCREATETPARAM,0.9,'color','r');
Array = who('global','-regexp', 'TotalSPL');
if ~isempty(Array); creartabla(Array); end
multiWaitbar(handles,handles.LCREATETPARAM,1,'color','r');
Array = who('global','-regexp', 'SPLxRec');
if ~isempty(Array); creartablasISM(Array,handles); end

multiWaitbar(handles,handles.LCREATETPARAM,'Close');

function creartabla(NombreVar)
global IDRec_00 NumeroBandas CarpetaTemp
for i=1:size(NombreVar,1)
    % Si el nombre de la variable no contiene 'res' quiere decir que no es
    % una variable resumen y se ejecuta lo siguiente
    if (strncmp('res',NombreVar(i),3))==0
        % Carga la variable para poderla manejar
        eval(sprintf('%s %s;', 'global', cell2mat(NombreVar(i))))
        
        % Iguala la variable a una auxilar para manejarla
        eval(sprintf('%s = %s;', 'param', cell2mat(NombreVar(i))))
        
        NombreFilas = cellstr(num2str(IDRec_00));
        NombreColumnas = {'x125Hz';'x250Hz';'x500Hz';'x1000Hz';'x2000Hz';'x4000Hz';'x8000Hz';'x16000Hz'};
        T = cell2table(num2cell(param));
        T.Properties.RowNames = NombreFilas;
        T.Properties.VariableNames = NombreColumnas(1:NumeroBandas)';
        
        % Guarda la tabla con el nombre de lo que contiene
        eval(sprintf('Tabla_%s = T;', cell2mat(NombreVar(i))))
        
        % Guarda la tabla dentro del .mat
        Ruta = strcat(CarpetaTemp,filesep,'Tablas.mat');
        if exist(Ruta,'file')
            save(Ruta,sprintf('Tabla_%s', cell2mat(NombreVar(i))), '-append')
        else
            save(Ruta,sprintf('Tabla_%s', cell2mat(NombreVar(i))))
        end
        
    end
end

function creartablasISM(NombreVar,handles)
global NumeroBandas
global CarpetaTemp

eval(sprintf('%s %s;', 'global', cell2mat(NombreVar)))

% Iguala la variable a una auxilar para manejarla
eval(sprintf('%s = %s;', 'param', cell2mat(NombreVar)))

for i=2:length(param) %#ok<USENS>
    multiWaitbar(handles,handles.LCREATETISM,i/length(param),'color','g');
    Fuente = param(i,1);
    Receptor = param(i,2);
    Datos = param{i,3};
    
    NombreColumnas = {'Tiempo_ms';'x125Hz';'x250Hz';'x500Hz';'x1000Hz';'x2000Hz';'x4000Hz';'x8000Hz';'x16000Hz'};
    
    T = cell2table(num2cell(Datos));
    T.Properties.VariableNames = NombreColumnas(1:NumeroBandas+1);
    
    % Guarda la tabla con el nombre de lo que contiene
    eval(sprintf('Tabla_ISM_%s_%s = T;', char(Fuente),char(Receptor)))
    
    % Guarda la tabla dentro del .mat
    Ruta = strcat(CarpetaTemp,filesep,'Tablas_ISM.mat');
    if exist(Ruta,'file')
        save(Ruta,sprintf(sprintf('Tabla_ISM_%s_%s', char(Fuente),char(Receptor))), '-append')
    else
        save(Ruta,sprintf('Tabla_ISM_%s_%s', char(Fuente),char(Receptor)))
    end
end

multiWaitbar(handles,handles.LCREATETISM,'Close');