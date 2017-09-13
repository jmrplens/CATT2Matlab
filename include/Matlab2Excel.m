function Matlab2Excel (handles,Archivo)
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

global CarpetaTemp

% Crear tablas para la exportacion a excel
CrearTablas(handles)

Ruta = [CarpetaTemp,filesep,'Tablas.mat'];
load(Ruta)
RutaISM = [CarpetaTemp,filesep,'Tablas_ISM.mat'];

multiWaitbar(handles,handles.LWRITEPARAM,0,'color','r');
% Vector de nombres de variables que coinciden con la busqueda
% Se obtienen los nombre de variables que coinciden y se envian a la funcion de
% escribir excel
Array = who('-regexp', 'T30');
if ~isempty(Array); escribirExcel(handles,Array,Archivo,'s'); end

Array = who('-regexp', 'T15');
if ~isempty(Array); escribirExcel(handles,Array,Archivo,'s'); end
multiWaitbar(handles,handles.LWRITEPARAM,0.1,'color','r');
Array = who('-regexp', 'EDT');
if ~isempty(Array); escribirExcel(handles,Array,Archivo,'s'); end
multiWaitbar(handles,handles.LWRITEPARAM,0.2,'color','r');
Array = who('-regexp', 'G_');
if ~isempty(Array); escribirExcel(handles,Array,Archivo,'dB'); end
multiWaitbar(handles,handles.LWRITEPARAM,0.3,'color','r');
Array = who('-regexp', 'LF_');
if ~isempty(Array); escribirExcel(handles,Array,Archivo,'%'); end
multiWaitbar(handles,handles.LWRITEPARAM,0.4,'color','r');
Array = who('-regexp', 'LFC');
if ~isempty(Array); escribirExcel(handles,Array,Archivo,'%'); end
multiWaitbar(handles,handles.LWRITEPARAM,0.5,'color','r');
Array = who('-regexp', 'C80');
if ~isempty(Array); escribirExcel(handles,Array,Archivo,'dB'); end
multiWaitbar(handles,handles.LWRITEPARAM,0.6,'color','r');
Array = who('-regexp', 'C50');
if ~isempty(Array); escribirExcel(handles,Array,Archivo,'dB'); end
multiWaitbar(handles,handles.LWRITEPARAM,0.7,'color','r');
Array = who('-regexp', 'D50');
if ~isempty(Array); escribirExcel(handles,Array,Archivo,'%'); end
multiWaitbar(handles,handles.LWRITEPARAM,0.8,'color','r');
Array = who('-regexp', 'Ts_');
if ~isempty(Array); escribirExcel(handles,Array,Archivo,'ms'); end
multiWaitbar(handles,handles.LWRITEPARAM,0.9,'color','r');
Array = who('-regexp', 'TotalPower');
if ~isempty(Array); escribirExcel(handles,Array,Archivo,'dB'); end
multiWaitbar(handles,handles.LWRITEPARAM,1,'color','r');
if exist(RutaISM,'file'); escribirExcelISM(RutaISM,Archivo,handles); end

multiWaitbar(handles,handles.LWRITEPARAM,'Close');

function escribirExcel(handles,Array,Archivo,Unidades)
%%
global CarpetaTemp
global NumeroBandas

% Carga el .mat que contiene las tablas
load([CarpetaTemp,filesep,'Tablas.mat'])

% Inicializar variables necesarias
cont = 1;
bandas = {'125 Hz','250 Hz','500 Hz','1 KHz','2 KHz','4 KHz','8 KHz','16 KHz'};
bandas = bandas(1:NumeroBandas);

% Recorre una a una las tablas
for i=1:length(Array)
    
    % Divide el nombre de la variable
    Info = strsplit(char(Array(i)),'_');
    
    % Obtener los datos relevantes del nombre de la variable
    NomParam = Info(2);
    NomFuente = Info(3);
    
    % Iguala la variable a una auxilar para manejarla
    eval(sprintf('%s = %s;', 'Tabla', char(Array(i))))
    
    % Desactiva el warning de que se esta creando una hoja nueva
    warning('off','MATLAB:xlswrite:AddSheet')
    
    % Calculo del incremento de distancia de la columna a escribir
    inc = (cont-1)*(NumeroBandas+3);
    
    % Posicion horizontal de la variable actual
    RangoInfo = [ColumnaExcel(inc+1),'2'];
    RangoDatos = [ColumnaExcel(inc+2),'2'];
    RangoTitulos = [ColumnaExcel(inc+3),'2'];
    
    % Escribe los datos en el excel
    writetable(Tabla,Archivo,'WriteRowNames',true,'Sheet',char(NomParam),'Range',RangoDatos)
    writetable(cell2table(bandas),Archivo,'WriteVariableNames',false,'Sheet',char(NomParam),'Range',RangoTitulos)
    writetable(cell2table({'ID'}),Archivo,'WriteVariableNames',false,'Sheet',char(NomParam),'Range',RangoDatos)
    writetable(cell2table({handles.LSOURCEEXCEL;NomFuente;'Unidades';Unidades}),Archivo,'WriteVariableNames',false,'Sheet',char(NomParam),'Range',RangoInfo)
    
     % Incrementa el contador para el calculo del incremento
    cont = cont+1;
end

function escribirExcelISM(RutaISM,Archivo,handles)
%%
global NumeroBandas
% Carga el .mat que contiene las tablas
load(RutaISM)

% Obtener un array de nombres de las tablas
Variables = who('-regexp','Tabla_ISM');

% Inicializar variables necesarias
cont = 1;
titulos = {handles.LTIMESTRING,'125 Hz','250 Hz','500 Hz','1 KHz','2 KHz','4 KHz','8 KHz','16 KHz';
    'ms','dB','dB','dB','dB','dB','dB','dB','dB'};
titulos = titulos(:,1:NumeroBandas+1);



% Recorre una a una las tablas
for i=1:length(Variables)
    
    multiWaitbar(handles,handles.LWRITEISM,i/length(Variables),'color','g');
    
    % Divide el nombre de la variable
    Info = strsplit(char(Variables(i)),'_');
    
    % Si despues de la primera iteracion en adelante se obtiene ISM de otra
    % fuente, se resetea el contador y el incremento
    if i>1
        if ~strcmp(Info(3),NomFuente)
            cont = 1;
            inc = 0; %#ok<NASGU>
        end
    end
    % Obtener los datos relevantes del nombre de la variable
    NomFuente = Info(3);
    NomReceptor = Info(4);
    
    % Iguala la variable a una auxilar para manejarla
    eval(sprintf('%s = %s;', 'Tabla', cell2mat(Variables(i))))
    
    % Calculo del incremento de distancia de la columna a escribir
    inc = (cont-1)*(NumeroBandas+3);
 
    % Posicion horizontal de la variable actual
    Rango = [ColumnaExcel(inc+2),'3'];
    RangoReceptor = [ColumnaExcel(inc+1),'3'];
    RangoTitulos = [ColumnaExcel(inc+2),'2'];
    
    % Escribe los datos en el excel
    writetable(Tabla,Archivo,'WriteRowNames',true,'Sheet',['ISM - ',char(NomFuente)],'Range',Rango)
    writetable(cell2table(titulos),Archivo,'WriteVariableNames',false,'Sheet',['ISM - ',char(NomFuente)],'Range',RangoTitulos)
    writetable(cell2table({handles.LRECID;NomReceptor}),Archivo,'WriteVariableNames',false,'Sheet',['ISM - ',char(NomFuente)],'Range',RangoReceptor)
    
    % Incrementa el contador para el calculo del incremento
    cont = cont+1;
end
multiWaitbar(handles,handles.LWRITEISM,'Close');

function b = ColumnaExcel(a)
%%
% Funcion que devuelve la cadena de caracteres que corresponde a un numero de
% columna en excel
base = 26;
n = ceil(log(a)/log(base));
d = cumsum(base.^(0:n+1));
n = find(a >= d, 1, 'last');
d = d(n:-1:1);
r = mod(floor((a-d)./base.^(n-1:-1:0)), base) + 1;
b = char(r+64);