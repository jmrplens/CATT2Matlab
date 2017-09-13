%% Funcion que recibe la ubicacion de los archivos .mat y los carga en el workspace
function Error = ProcesarMats(Carpeta,handles)
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

% Busqueda de archivos .mat en la carpeta recibida
Archivos=what(Carpeta);

% filesep es el separador que se usa en el sistema que se ejecuta este programa,
% para windows es '\' mientras que para Linux o OSX es '/'
ArchivosMat=strcat(Carpeta,filesep,Archivos(1).mat);

% Si no hay archivos .mat cancela la importación
if isempty(ArchivosMat) 
    Error = true;
    return
end
% Si no tiene los archivos .mat basicos tambien cancela la importacion
Nombres = Archivos(1).mat; % Extrae los nombres de archivo
if isempty(cellfun(@(s) strfind(s, 'Source_'), Nombres,'un',0)) ||...
        isempty(cellfun(@(s) strfind(s, 'AcousticParameters_'), Nombres,'un',0)) ||...
        isempty(cellfun(@(s) strfind(s, 'Receivers'), Nombres,'un',0)) ||...
        isempty(cellfun(@(s) strfind(s, 'Room'), Nombres,'un',0))
    Error = true;
    return
else
    Error = false;
end

% Funcion para resetear botones y otros datos de la aplicacion
limpiar(handles);

for a=1:numel(ArchivosMat)
    %% Crea y actualiza el valor de la barra de progreso
    multiWaitbar(handles,handles.LIMPORTINGMAT,a/numel(ArchivosMat),'color','b');
    % Almacena los datos de .mat a un struct
    data=load(char(ArchivosMat(a)));
    % Extrae el nombre de cada variable contenida en el struct
    fields = fieldnames(data, '-full');
    % Cuenta el numero de variable contenidas en el struct
    numberOfFields = length(fields);
    
    % Copia del struct de tipo cell para obtener los datos (ACTIVAR SI SE DESEA
    % VER LAS VARIABLES EN EL WORKSPACE, VER LINEA 36
    % "assignin('base',thisField,encell{f});")
    %encell = struct2cell(data);
    
    % Obtiene cada una de las variables y la guarda para hacerlas globales en
    % este .m
    for f = 1 : numberOfFields
        thisField = fields{f};
        % Inicializa las variables como globales
        commandLine = sprintf('%s %s', 'global', thisField);
        eval(commandLine); % ejecucion como globales
        
        commandLine = sprintf('%s = data.%s;', thisField, thisField);
        % Ejecuta la linea creada antes, que iguala el dato de la estructura a
        % un nuevo dato de mismo nombre
        eval(commandLine);
        
        % Asigna al nombre de variable contenido en 'thisField' los datos
        % contenidos en la posicion f de encell (SOLO PARA TENER LAS VARIABLES
        % EN EL WORKSPACE, UTIL PARA CUANDO SE ESTA PROGRAMANDO Y VER LAS
        % VARIABLES FACILMENTE)
        %assignin('base',thisField,encell{f});
    end
    % Borrar las variables que ya no son necesarias creadas para poder obtener
    % la variables de los .mat
    clear('f', 'thisField', 'numberOfFields');
    clear('fields', 'commandLine');
end

%% Inicia la ventana de progreso
multiWaitbar(handles,handles.LLOADDATAAPP,0,'color','r');

%% Visible: botones de parametros si existen
if ~isempty(who('global','-regexp', 'T30'))
    set(handles.botont30,'visible','on'); end
if ~isempty(who('global','-regexp', 'T15'))
    set(handles.botont15,'visible','on'); end
if ~isempty(who('global','-regexp', 'EDT'))
    set(handles.botonedt,'visible','on'); end
if ~isempty(who('global','-regexp', 'G_'))
    set(handles.botong,'visible','on'); end
if ~isempty(who('global','-regexp', 'LF_'))
    set(handles.botonlf,'visible','on'); end
if ~isempty(who('global','-regexp', 'LFC'))
    set(handles.botonlfc,'visible','on'); end
if ~isempty(who('global','-regexp', 'C80'))
    set(handles.botonc80,'visible','on'); end
if ~isempty(who('global','-regexp', 'C50'))
    set(handles.botonc50,'visible','on'); end
if ~isempty(who('global','-regexp', 'D50'))
    set(handles.botond50,'visible','on'); end
if ~isempty(who('global','-regexp', 'Ts_'))
    set(handles.botonts,'visible','on'); end
if ~isempty(who('global','-regexp', 'Rasti'))
    set(handles.rastisinruidoboton,'visible','on')
    set(handles.rasticonruidoboton,'visible','on')
end
if ~isempty(who('global','-regexp', 'STI'))
    set(handles.stisinruidoboton,'visible','on')
    set(handles.sticonruidoboton,'visible','on')
end
if ~isempty(who('global','-regexp', 'TotalSPL'))
    set(handles.botonsplbandas,'visible','on'); end

%% Actualiza el valor de la barra de progreso
multiWaitbar(handles,handles.LLOADDATAAPP,0.15,'color','r');

%% Visible: botones a la derecha de la lista de receptores
set(handles.mapapos2d,'Visible','on')
set(handles.mapapos3d,'Visible','on')
set(handles.botonesparametros,'Visible','on')

%% Si hay datos de ISM hace visible el boton de Historia temporal
set(handles.PestParam,'visible','on')
if ~isempty(who('global','-regexp', 'SPLxRec'))
    set(handles.PestHist,'visible','on')
    % Obtener el maximo valor elegible para los rangos de historia temporal
    global SPLxRec_00 %#ok<TLEV>
    Valores=SPLxRec_00(2:end,3);
    Max = min(cell2mat(cellfun( @(val) max(val(:)), Valores,'UniformOutput',0)));
    global MaxElegible %#ok<TLEV>
    MaxElegible = Max;
    set(handles.ValMaxText,'String',num2str(floor(Max)))
end

%% Actualiza el valor de la barra de progreso
multiWaitbar(handles,handles.LLOADDATAAPP,0.3,'color','r');

%% Visible: botones de representar
set(handles.botonplotear,'Visible','on')
set(handles.abrirnuevafigura,'Visible','on')
set(handles.botonExportar,'Visible','on')

%% Obtener el numero de bandas de octavas disponibles
global NumeroBandas
bandastabla = {'125','250','500','1K','2K','4K','8K','16K'};
numbandas = numel(DissAirCoeff_00);
bandastabla(numbandas+1:end) = [];
NumeroBandas = numbandas;

%% Actualiza el valor de la barra de progreso
multiWaitbar(handles,'Cargando datos en la aplicación',0.4,'color','r');

%% Agregar los datos de la sala al panel de parámetros de la sala
set(handles.panelparametrossala,'Visible','on')
set(handles.dimensiones,'string',...
    strcat(num2str(RoomDimensions_00(1)),'x',num2str(RoomDimensions_00(2)),'x',num2str(RoomDimensions_00(3)),' m'))
set(handles.volumen,'string',strcat(num2str(RoomVolume_00),' m3'))
set(handles.superficie,'string',strcat(num2str(RoomSurface_00),' m2'))
set(handles.temperatura,'string',strcat(num2str(Temperature_00),' ºC'))
set(handles.densidadaire,'string',strcat(num2str(AirDensity_00),' Kg/m3'))
set(handles.impedanciaaire,'string',strcat(num2str(AirImpedance_00),' Ns/m3'))
set(handles.humedad,'string',strcat(num2str(Humidity_00),' %'))
set(handles.velocidadsonido,'string',strcat(num2str(SoundSpeed_00),' m/s'))
set(handles.tablaAbsAire,'Data',[bandastabla;num2cell(DissAirCoeff_00)])

%% Actualiza el valor de la barra de progreso
multiWaitbar(handles,handles.LLOADDATAAPP,0.55,'color','r');

%% Crear variable global para almacenar la ID de las fuentes
commandLine = sprintf('%s %s', 'global', 'IDFuentes');
eval(commandLine);
IDFuentes = ObtenerIDFuentes(Carpeta);

%% Actualiza el valor de la barra de progreso
multiWaitbar(handles,handles.LLOADDATAAPP,0.70,'color','r');

%% Agregar los datos de la sala al panel de parámetros de la fuente
set(handles.parametrosfuente,'Visible','on')
eval(sprintf('Directivity = Directivity_%s;',IDFuentes{1}))
eval(sprintf('SRCPosition = SRCPosition_%s;',IDFuentes{1}))
eval(sprintf('TotalPower = TotalPower_%s;',IDFuentes{1}))
eval(sprintf('Pressure1m = Pressure1m_%s;',IDFuentes{1}))
set(handles.parametrosfuente,'Title',[handles.LSRCPARAMETERS,sprintf(' %s',IDFuentes{1})])
set(handles.SRCPosition,'string',...
    strcat(num2str(SRCPosition(1)),'x',num2str(SRCPosition(2)),'x',num2str(SRCPosition(3)),' m'))
set(handles.tablaSPL1m,'data',[bandastabla;num2cell(Pressure1m)])
set(handles.tablaPotTotal,'data',[bandastabla;num2cell(TotalPower)])
set(handles.tablaDir,'data',[bandastabla;num2cell(Directivity)])

%% Actualiza el valor de la barra de progreso
multiWaitbar(handles,handles.LLOADDATAAPP,0.85,'color','r');

%% Agregar los datos de la sala al panel de parámetros del receptor
set(handles.panelreceptor,'Visible','on')
set(handles.panelreceptor,'Title',[handles.LRECPARAMETERS,sprintf(' %s',num2str(IDRec_00(1)))])
set(handles.posicionreceptor,'string',...
    strcat(num2str(RecPosition_00(1,1)),'x',num2str(RecPosition_00(1,2)),'x',num2str(RecPosition_00(1,3)),' m'))
if ~isempty(HeadDirection_00)
    set(handles.orientacionrec,'string',...
    strcat(num2str(HeadDirection_00(1,1)),'x',num2str(HeadDirection_00(1,2)),'x',num2str(HeadDirection_00(1,3)),' m'))
else
    set(handles.orientacionrec,'string',handles.LWITHOUTINFO)
end
Distancia = sqrt(...
    (RecPosition_00(1,1)-SRCPosition(1))^2+...
    (RecPosition_00(1,2)-SRCPosition(2))^2+...
    (RecPosition_00(1,3)-SRCPosition(3))^2);
set(handles.distfuente,'string',sprintf('%4.2f m',Distancia))

%% Actualiza el valor de la barra de progreso
multiWaitbar(handles,handles.LLOADDATAAPP,0.95,'color','r');

%% Añadir a las listas los receptores y las fuentes
set(handles.todoslosreceptores,'Visible','on')
set(handles.panellistafuentes,'Visible','on')
set(handles.panellistareceptores,'Visible','on')
global IDFuente
IDFuente = IDFuentes{1};
set(handles.listafuentes,'string',IDFuentes)
global seleccionreceptor
seleccionreceptor = 1;
set(handles.listareceptores,'string',num2cell(IDRec_00))

%% Actualiza el valor de la barra de progreso
multiWaitbar(handles,handles.LLOADDATAAPP,1,'color','r');

%% Cerrar mensajes de progreso
multiWaitbar(handles,handles.LLOADDATAAPP,'Close');
multiWaitbar(handles,handles.LIMPORTINGMAT,'Close');

%% Funcion para resetear botones, listas y graficas
function limpiar(handles)
global seleccionreceptor
set(handles.todoslosreceptores,'Value',0)
set(handles.promediotodo,'Value',0)
set(handles.listareceptores,'Value',1); seleccionreceptor = 1;
% Se asegura que no haya ninguna opcion seleccionada
set(handles.splVSdist,'Value',0)
set(handles.MapCruceOctBoton,'Value',0)
set(handles.MapaSPLboton,'Value',0)
set(handles.MapCruceGlobalBoton,'Value',0)
set(handles.MapEspec0toValBoton,'Value',0)
set(handles.MapEspecValtoinfBoton,'Value',0)
set(handles.botont30,'Value',0)
set(handles.botont15,'Value',0)
set(handles.botonedt,'Value',0)
set(handles.botong,'Value',0)
set(handles.botonlf,'Value',0)
set(handles.botonlfc,'Value',0)
set(handles.botonc80,'Value',0)
set(handles.botonc50,'Value',0)
set(handles.botond50,'Value',0)
set(handles.botonts,'Value',0)
set(handles.botonsplbandas,'Value',0)

% Desactivar boton de plotear y el de abrir nueva figura
set(handles.botonplotear,'Enable','off')
set(handles.abrirnuevafigura,'Enable','off')
set(handles.botonExportar,'Enable','off')

% Limpiar graficas
cla(handles.plotfig,'reset')
cla(handles.subplot1,'reset')
cla(handles.subplot2,'reset')
cla(handles.subplot3,'reset')
cla(handles.subplot4,'reset')
cla(handles.subplot5,'reset')
cla(handles.subplot6,'reset')
cla(handles.subplot7,'reset')
cla(handles.subplot8,'reset')
set(handles.plotfig,'Visible','off')
set(handles.subplot1,'Visible','off')
set(handles.subplot2,'Visible','off')
set(handles.subplot3,'Visible','off')
set(handles.subplot4,'Visible','off')
set(handles.subplot5,'Visible','off')
set(handles.subplot6,'Visible','off')
set(handles.subplot7,'Visible','off')
set(handles.subplot8,'Visible','off')

% Ocultar barra de herramientas
set(handles.barraheramientas,'Visible','off')

% Asegurar que no quedan listados receptores y fuentes de datos anteriores
set(handles.listareceptores,'string',[])
set(handles.listafuentes,'string',[])
