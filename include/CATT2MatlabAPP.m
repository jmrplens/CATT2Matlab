function varargout = CATT2MatlabAPP(varargin)
% CATT2MATLABAPP es una aplicacion GUIDE para datos exportados de CATT-Acoustic
% 8.0. Facilita la visualización de los diferentes datos que exporta la
% aplicación CATT-Acoustic 8.0 con diferentes representaciones graficas
% extendiendo así los resultados que ofrece la aplicacion de modelado.
%
% Simplemente se debe pulsar la opcion de importar datos de CATT-Acoustics,
% seleccionar la carpeta donde esten ubicados los archivos generados por el
% software (habitualmente la carpeta 'OUT') y esperar a que procese los datos.
%
% Para aprovechar al maximo las funciones de la aplicación, se debe activar en
% el programa CATT-Acoustic la salida de archivos de texto con los resultados de
% ISM, obteniendo asi valores de presion para las diferentes octavas y en
% distintas fracciones de tiempo.
% Para activar la salida de estos archivos, se debe editar el archivo:
% 'hiddenoptions_removethis.txt' ubicado en la carpeta de instalación de
% CATT-ACoustics. En primer lugar se debe modificar el nombre de archivo y
% dejarlo como 'hiddenoptions.txt', y despues abrirlo y descomentar la linea:
% ;F210A-C20D6-A4EBB-C0493 ;for ISM History plots create a text history file
% (I_ss_rr.TXT)
%
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CATT2MatlabAPP_OpeningFcn, ...
    'gui_OutputFcn',  @CATT2MatlabAPP_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


%% Funcion que se ejecuta al abrir la aplicacion 2/2
function CATT2MatlabAPP_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% Funcion para resetear botones y otros datos de la aplicacion
limpiar(handles);
% Color de fondo de la aplicacion en blanco
set(handles.CATT2MatlabApp, 'Color', [1 1 1]);
% Obtener el idioma que utiliza el ordenador
lang = get(0,'Language');
% Asignar el idioma al programa
language(handles,hObject,lang(1:2));

%% Funcion al abrir la aplicacion 1/2
function CATT2MatlabApp_CreateFcn(hObject, eventdata, handles)
global CarpetaTemp CarpetaInclude CarpetaTempMat

% Ruta de la carpeta de include (Archivos necesarios para la ejecucion)
CarpetaInclude = 'include';
% Ruta de la carpeta para archivos temporales
CarpetaTemp = [CarpetaInclude,filesep,'temp'];
CarpetaTempMat = [CarpetaInclude,filesep,'temp_mat'];
handles.carpetatempmat = CarpetaTempMat;
guidata(hObject, handles); % Almacena los cambios realizados en handles
rehash() % Actualiza el sistema de carpetas de Matlab
if ~exist(CarpetaTemp,'dir') % Si no existe la crea
    mkdir(CarpetaTemp)
end
if ~exist(CarpetaTempMat,'dir') % Si no existe la crea
    mkdir(CarpetaTempMat)
end
% Añade al sistema la ruta de la carpeta include
addpath(CarpetaInclude)

%% Se ejecuta cuando se cierra la aplicacion o se pulsa el item 'Salir'
function CATT2MatlabApp_CloseRequestFcn(hObject, eventdata, handles)
global CarpetaTemp
% Elimina las carpetas temporales generadas al abrir la aplicacion
if exist(CarpetaTemp,'dir')
    warning ('off','all')
    rmdir(CarpetaTemp,'s')
    warning ('on','all')
end
if exist(handles.carpetatempmat,'dir')
    warning ('off','all')
    rmdir(handles.carpetatempmat,'s')
    warning ('on','all')
end
% Elimina las variables globales
clear global
% Elimina la aplicacion
delete(handles.output);

%% Funcion que se ejecuta cuando se sale de la aplicacion
function varargout = CATT2MatlabAPP_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

%% Al hacer clic en "Importar datos de CATT" solicita una carpeta y los carga
function importardecatt_Callback(hObject, eventdata, handles)
global CarpetaTempMat
% Solicita una carpeta
Carpeta = uigetdir;
if Carpeta
    % Asigna la ruta por defecto de la carpeta temporal para archivos .mat
    CarpetaTempMat = handles.carpetatempmat;
    % Si ya existe, borra y vuelve a crearla para limpiar datos anteriores
    if exist(CarpetaTempMat,'dir')
        warning ('off','all')
        rmdir(CarpetaTempMat,'s')
        rehash()
        warning ('on','all')
        mkdir(CarpetaTempMat)
    end
    Error = CATT2MatlabImportacion(Carpeta,handles);
    % Si no ha encontrado archivos Param_SS.txt devuelve Error = true y por lo tanto no
    % se debe realizar nada
    if Error
        % Mensaje de error
        msgbox(handles.LNODATAFOUND,handles.LMSGBOXTITLE,'error','modal')
        return
    end
    % Añade la carpeta generada en la importacion para guardar los .mat al
    % workspace
    addpath(CarpetaTempMat)
    % Obtener variables
    ProcesarMats(CarpetaTempMat,handles);
    % Cambio de titulo de la aplicacion
    UltimaCarpeta = find(Carpeta==filesep,1,'last');
    TituloCarpeta = Carpeta(UltimaCarpeta:end);
    handles.CATT2MatlabApp.Name = [handles.LORIGINALNAME,' (...',TituloCarpeta,')'];
    % Mensaje de confirmacion
    msgbox(handles.LCATTIMPORTED,handles.LMSGBOXTITLE,'help','modal')
end


%% Al hacer clic en "Importar datos de matlab" solicita una carpeta y los carga
function importardematlab_Callback(hObject, eventdata, handles)
% Borrar todas las variables globales excepto las direcciones de carpetas, asi
% se asegura no mantener restos de datos anteriores
clearvars -global -except CarpetaInclude CarpetaTempMat CarpetaTemp
global CarpetaTempMat
% Solicita una carpeta
Carpeta = uigetdir;
if Carpeta
    addpath(Carpeta)
    % Para asegurar que la opcion de exportar a .mat funciona correctamente
    % cuando los datos importados son .mat, se asigna como CarpetaTempMat la
    % carpeta que contiene los .mat
    CarpetaTempMat = Carpeta;
    % Obtener variables
    Error = ProcesarMats(Carpeta,handles);
    if Error
        % Mensaje de error
        msgbox(handles.LNODATAFOUND,handles.LMSGBOXTITLE,'error','modal')
        return
    end
    % Cambio de titulo de la aplicacion
    UltimaCarpeta = find(Carpeta==filesep,1,'last');
    TituloCarpeta = Carpeta(UltimaCarpeta:end);
    handles.CATT2MatlabApp.Name = [handles.LORIGINALNAME,' (...',TituloCarpeta,')'];
    % Mensaje de confirmacion
    msgbox(handles.LMATIMPORTED,handles.LMSGBOXTITLE,'help','modal')
    
end



%% Funcion que se ejecuta al marcar (Todos los receptores)
function todoslosreceptores_Callback(hObject, eventdata, handles)
global seleccionreceptor IDRec_00
% Si se selecciona la opcion de todos los receptores
if get(hObject,'Value')==1
    set(handles.todoslosreceptores,'Value',1);
    set(handles.listareceptores,'Enable','off');
    % Se crea un vector de numeros desde 1 a el numero de receptores disponibles
    seleccionreceptor = 1:numel(IDRec_00);
    % Actualizar informacion del receptor
    infoReceptor(hObject, eventdata, handles)
else % Si se deselecciona
    set(handles.promediotodo,'Value',0)
    set(handles.listareceptores,'Enable','on');
    % Cambia la seleccionreceptor al valor anterior a seleccionar todos los
    % receptores
    seleccionreceptor = handles.listareceptores.Value;
    % Actualizar informacion del receptor
    infoReceptor(hObject, eventdata, handles)
end



%% Se ejecuta al seleccionar algo en la lista de receptores
function listareceptores_Callback(hObject, eventdata, handles)
global seleccionreceptor
% Obtiene la seleccion de la lista
seleccionreceptor = get(handles.listareceptores,'Value');
% Actualizar informacion del receptor
infoReceptor(hObject, eventdata, handles)

%% Se ejecuta al seleccionar algo en la lista de fuentes
function listafuentes_Callback(hObject, eventdata, handles)
% Actualizar informacion de la fuente elegida
infoFuente(hObject, eventdata, handles);
% Actualizar distancia a la fuente en el panel del receptor
infoReceptor(hObject, eventdata, handles);

%% Funcion al pulsar el boton de mapa de posiciones 2D
function mapapos2d_Callback(hObject, eventdata, handles)
% Resetea todas las graficas
limpiarPlots(handles);
% Carga la representacion del mapa de posiciones
plotPosiciones2D(handles);
% Hace visible la representacion
set(handles.plotfig,'Visible','on')

%% Funcion al pulsar el boton de mapa de posiciones 3D
function mapapos3d_Callback(hObject, eventdata, handles)
% Resetea todas las graficas
limpiarPlots(handles);
% Carga la representacion del mapa de posiciones
plotPosiciones3D(handles);
% Hace visible la representacion
set(handles.plotfig,'Visible','on')

%% Se ejecuta cuando se pulsa el boton de Representar
function botonplotear_Callback(hObject, eventdata, handles)
global IDFuente IDReceptor Rango seleccionreceptor IDRec_00 GenVideo CarpetaTemp
global PrimFotograma
% Se obtiene las ID de fuentes de la lista de fuentes y el indice de la
% seleccion
ListaFuentes = get(handles.listafuentes,'string');
IndiceFuente = get(handles.listafuentes,'Value');
% Se obtiene la ID de fuente seleccionada
IDFuente = ListaFuentes{IndiceFuente};
% Se obtiene la ID del receptor o receptores seleccionados
IDReceptor = num2str(IDRec_00(seleccionreceptor));
% Si esta activada la opcion de generar video en la historia temporal se crean
% los parametros
if GenVideo
    % Ruta donde se va a guardar el archivo temporalmente
    Archivo = [CarpetaTemp,filesep,'Video.mp4'];
    % Se crea el objeto que almacenara el video, en formato MP4
    v = VideoWriter(Archivo,'MPEG-4');
    % Se configura los fotogramas por segundo que deben haber
    v.FrameRate = 3;
    % Abre el objeto para que se le puedan añadir fotogramas
    open(v)
    % Obtener limites para grabar. Especifica la posicion y alto y ancho de la
    % zona de la aplicacion a grabar (grafica, titulo, leyenda)
    XyAlto = getpixelposition(handles.MargenXyAltotag);
    X = XyAlto(1);
    Height = XyAlto(2);
    YyAncho = getpixelposition(handles.MargenYyAnchotag);
    Y = YyAncho(2);
    Width = YyAncho(1);
    % Se desactiva el warning que indica que la dimensiones del video no estan
    % dentro del estandar MP4
    warning('off','MATLAB:audiovideo:VideoWriter:mp4FramePadded')
    % Variable para indicar si es el primer fotograma o no, necesario para los
    % calculos de limites de eje para video en los distintos .m que generan
    % video
    PrimFotograma = true;
end

% Si esta marcada la opcion de T30
if get(handles.botont30,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global T30_%s',IDFuente))
    eval(sprintf('T30 = T30_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotParametro(T30,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% Si esta marcada la opcion de T15
if get(handles.botont15,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global T15_%s',IDFuente))
    eval(sprintf('T15 = T15_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotParametro(T15,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% Si esta marcada la opcion de EDT
if get(handles.botonedt,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global EDT_%s',IDFuente))
    eval(sprintf('EDT = EDT_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotParametro(EDT,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% Si esta marcada la opcion de G
if get(handles.botong,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global G_%s',IDFuente))
    eval(sprintf('G = G_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotParametro(G,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end
% Si esta marcada la opcion de LF
if get(handles.botonlf,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global LF_%s',IDFuente))
    eval(sprintf('LF = LF_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotParametro(LF,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% Si esta marcada la opcion de LFC
if get(handles.botonlfc,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global LFC_%s',IDFuente))
    eval(sprintf('LFC = LFC_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotParametro(LFC,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% Si esta marcada la opcion de C50
if get(handles.botonc50,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global C50_%s',IDFuente))
    eval(sprintf('C50 = C50_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotParametro(C50,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% Si esta marcada la opcion de D50
if get(handles.botond50,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global D50_%s',IDFuente))
    eval(sprintf('D50 = D50_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotParametro(D50,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% Si esta marcada la opcion de C80
if get(handles.botonc80,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global C80_%s',IDFuente))
    eval(sprintf('C80 = C80_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotParametro(C80,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% Si esta marcada la opcion de Ts
if get(handles.botonts,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global Ts_%s',IDFuente))
    eval(sprintf('Ts = Ts_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotParametro(Ts,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% Si esta marcada la opcion de SPL
if get(handles.botonsplbandas,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global TotalSPL_%s',IDFuente))
    eval(sprintf('TotalSPL = TotalSPL_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotParametro(TotalSPL,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% Si esta marcada la opcion de RASTI sin ruido
if get(handles.rastisinruidoboton,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global Rasti_%s',IDFuente))
    eval(sprintf('Rasti = Rasti_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotSTI(Rasti,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% Si esta marcada la opcion de RASTI con ruido
if get(handles.rasticonruidoboton,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global RastiWithNoise_%s',IDFuente))
    eval(sprintf('RastiWithNoise = RastiWithNoise_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotSTI(RastiWithNoise,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% Si esta marcada la opcion de STI sin ruido
if get(handles.stisinruidoboton,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global STIuser_%s',IDFuente))
    eval(sprintf('STI = STIuser_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotSTI(STI,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% Si esta marcada la opcion de STI con ruido
if get(handles.sticonruidoboton,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Carga la variable global en una local
    eval(sprintf('global STIuserWithNoise_%s',IDFuente))
    eval(sprintf('STIWithNoise = STIuserWithNoise_%s;',IDFuente))
    % Representacion del parametro solicitado
    plotSTI(STIWithNoise,handles)
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible la grafica
    set(handles.plotfig,'Visible','on')
end

% ********************************** Botones de historia temporal

% Si esta marcada la opcion de SPL vs Distancia
if get(handles.splVSdist,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Si no esta elegida la opcion de generar video
    if (~isempty(GenVideo) && GenVideo) == false
        Rango = str2double(get(handles.rangotemporal,'String'));
        % Representacion del parametro solicitado
        plotSPLDist(handles)
        % Hace visible la grafica
        set(handles.plotfig,'Visible','on')
    else
        % Representa desde 1 ms hasta el valor elegido en cada iteracion
        for i=1:str2double(get(handles.limvideoms,'String'))
            Rango = i;
            % Representacion del parametro solicitado
            plotSPLDist(handles)
            % Oculta el mensaje de carga de representacion
            set(handles.cargandoPlot,'Visible','off')
            % Hace visible la grafica
            set(handles.plotfig,'Visible','on')
            % Asignar el cuadro a grabar y grabarlo
            writeVideo(v,getframe(gcf,[X,Y,Width,Height]))
            % Muestra el mensaje de carga de representacion
            set(handles.cargandoPlot,'Visible','on')
        end
    end
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
end

% Si esta marcada la opcion de Mapa SPL
if get(handles.MapaSPLboton,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Si no esta elegida la opcion de generar video
    if (~isempty(GenVideo) && GenVideo) == false
        Rango = str2double(get(handles.rangotemporal,'String'));
        % Representacion del parametro solicitado
        plotMapaSPL(handles)
        % Hace visible la grafica
        set(handles.plotfig,'Visible','on')
    else
        % Representa desde 1 ms hasta el valor elegido en cada iteracion
        for i=1:str2double(get(handles.limvideoms,'String'))
            Rango = i;
            % Representacion del parametro solicitado
            plotMapaSPL(handles)
            % Oculta el mensaje de carga de representacion
            set(handles.cargandoPlot,'Visible','off')
            % Hace visible la grafica
            set(handles.plotfig,'Visible','on')
            % Asignar el cuadro a grabar y grabarlo
            writeVideo(v,getframe(gcf,[X,Y,Width,Height]))
            % Muestra el mensaje de carga de representacion
            set(handles.cargandoPlot,'Visible','on')
        end
    end
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
end

% Si esta marcada la opcion de Mapa de cruce por octavas
if get(handles.MapCruceOctBoton,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Si no esta elegida la opcion de generar video
    if (~isempty(GenVideo) && GenVideo) == false
        Rango = str2double(get(handles.rangotemporal,'String'));
        % Representacion del parametro solicitado
        NumBandas = plotMapaCruce(handles,1);
        % Hace visible las graficas
        set(handles.subplot1,'Visible','on')
        set(handles.subplot2,'Visible','on')
        set(handles.subplot3,'Visible','on')
        set(handles.subplot4,'Visible','on')
        set(handles.subplot5,'Visible','on')
        set(handles.subplot6,'Visible','on')
        % Si tiene las bandas de 8 y 16 KHz las muestra
        if NumBandas == 8
            set(handles.subplot7,'Visible','on')
            set(handles.subplot8,'Visible','on')
        end
    else
        % Representa desde 1 ms hasta el valor elegido en cada iteracion
        for i=1:str2double(get(handles.limvideoms,'String'))
            Rango = i;
            % Representacion del parametro solicitado
            NumBandas = plotMapaCruce(handles,1);
            % Oculta el mensaje de carga de representacion
            set(handles.cargandoPlot,'Visible','off')
            % Hace visible las graficas
            set(handles.subplot1,'Visible','on')
            set(handles.subplot2,'Visible','on')
            set(handles.subplot3,'Visible','on')
            set(handles.subplot4,'Visible','on')
            set(handles.subplot5,'Visible','on')
            set(handles.subplot6,'Visible','on')
            % Si tiene las bandas de 8 y 16 KHz las muestra
            if NumBandas == 8
                set(handles.subplot7,'Visible','on')
                set(handles.subplot8,'Visible','on')
            end
            % Asignar el cuadro a grabar y grabarlo
            writeVideo(v,getframe(gcf,[X,Y,Width,Height]))
            % Muestra el mensaje de carga de representacion
            set(handles.cargandoPlot,'Visible','on')
        end
    end
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
end

% Si esta marcada la opcion de Mapa de cruce de nivel global
if get(handles.MapCruceGlobalBoton,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    % Si no esta elegida la opcion de generar video
    if (~isempty(GenVideo) && GenVideo) == false
        Rango = str2double(get(handles.rangotemporal,'String'));
        % Representacion del parametro solicitado
        plotMapaCruce(handles,2);
        % Hace visible la grafica
        set(handles.plotfig,'Visible','on')
    else
        % Representa desde 1 ms hasta el valor elegido en cada iteracion
        for i=1:str2double(get(handles.limvideoms,'String'))
            Rango = i;
            % Representacion del parametro solicitado
            plotMapaCruce(handles,2);
            % Oculta el mensaje de carga de representacion
            set(handles.cargandoPlot,'Visible','off')
            % Hace visible la grafica
            set(handles.plotfig,'Visible','on')
            % Asignar el cuadro a grabar y grabarlo
            writeVideo(v,getframe(gcf,[X,Y,Width,Height]))
            % Muestra el mensaje de carga de representacion
            set(handles.cargandoPlot,'Visible','on')
        end
    end
    set(handles.cargandoPlot,'Visible','off')
end

% Si esta marcada la opcion de Mapa de nivel por octava (0-N ms)
if get(handles.MapEspec0toValBoton,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    Rango = str2double(get(handles.rangotemporal,'String'));
    % Representacion del parametro solicitado
    NumBandas = plotMapaEspectral(handles,1);
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible las graficas
    set(handles.subplot1,'Visible','on')
    set(handles.subplot2,'Visible','on')
    set(handles.subplot3,'Visible','on')
    set(handles.subplot4,'Visible','on')
    set(handles.subplot5,'Visible','on')
    set(handles.subplot6,'Visible','on')
    % Si tiene las bandas de 8 y 16 KHz las muestra
    if NumBandas == 8
        set(handles.subplot7,'Visible','on')
        set(handles.subplot8,'Visible','on')
    end
end

% Si esta marcada la opcion de Mapa de nivel por octava (N-inf ms)
if get(handles.MapEspecValtoinfBoton,'Value')==1
    % Limpia todas las graficas
    limpiarPlots(handles)
    % Muestra el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','on')
    Rango = str2double(get(handles.rangotemporal,'String'));
    % Representacion del parametro solicitado
    NumBandas = plotMapaEspectral(handles,2);
    % Oculta el mensaje de carga de representacion
    set(handles.cargandoPlot,'Visible','off')
    % Hace visible las graficas
    set(handles.subplot1,'Visible','on')
    set(handles.subplot2,'Visible','on')
    set(handles.subplot3,'Visible','on')
    set(handles.subplot4,'Visible','on')
    set(handles.subplot5,'Visible','on')
    set(handles.subplot6,'Visible','on')
    % Si tiene las bandas de 8 y 16 KHz las muestra
    if NumBandas == 8
        set(handles.subplot7,'Visible','on')
        set(handles.subplot8,'Visible','on')
    end
end

% Si la opcion de video esta activada cierra el archivo y lo guarda
if GenVideo
    % Finaliza el objeto
    close(v)
    % Solicita una ruta donde guardar el video
    [file,path,ind] = uiputfile({...
        '*.mp4',[handles.LVIDEOSTRING,' (.mp4)'];
        '*.gif',[handles.LVIDEOSTRING,' (.gif)']
        },handles.LSAVEVIDEO,[handles.LVIDEOSTRING,'.mp4']);
    % Si se ha elegido una ruta 
    if ischar(file)
        switch ind
            case 1
                % Si se ha elegido .mp4 se mueve el archivo de la carpeta
                % temporal a la ruta elegida
                movefile(Archivo,[path,file],'f')
            case 2
                % Si se ha elegido .gif, se convierte el video de la carpeta
                % temporal a GIF, se guarda en la carpeta elegida y se elimina
                % el archivo temporal
                v = VideoReader(Archivo);
                k = 0;
                while hasFrame(v)
                    k = k+1;
                    im = readFrame(v);
                    [A,map] = rgb2ind(im,256);
                    if k == 1
                        imwrite(A,map,[path,file],'gif','LoopCount',Inf,'DelayTime',1);
                    else
                        imwrite(A,map,[path,file],'gif','WriteMode','append','DelayTime',1);
                    end
                end
                delete(Archivo)
        end
    else % Si no se ha elegido una ruta se elimina el archivo de la carpeta temporal
        delete(Archivo)
    end
end

% Hace visible la barra de heramientas
set(handles.barraheramientas,'Visible','on')
% Activar el boton de abrir en nueva figura
set(handles.abrirnuevafigura,'Enable','on')
% Activa el boton de exportar figura
set(handles.botonExportar,'Enable','on')

%% Funcion al pulsar el boton de nueva figura
function abrirnuevafigura_Callback(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
nuevafigura(handles);


%% Funcion que se ejecuta al pulsar en exportar a excel
function exportarexcel_Callback(hObject, eventdata, handles)
% Solicita un nombre de archivo, ruta y formato de archivo
[file,path,~] = uiputfile({...
    '*.xlsx','Excel (.xlsx)'
    },handles.LSAVEDATAEXCEL,[handles.LEXPORTEDEXCEL,'.xlsx']);
if ~ischar(file); return; end
Archivo = [path,file];
% Ejecuta la funcion para exportar a Excel
Matlab2Excel(handles,Archivo);
% Avisa de que ha terminado la exportacion
msgbox(handles.LEXCELSAVED,handles.LMSGBOXTITLE,'help','modal');


%% Funcion que se ejecuta al pulsar el boton de parametros
function PestParam_Callback(hObject, eventdata, handles)
global seleccionreceptor GenVideo
% Oculta el panel de botones de historia temporal
set(handles.paneltemporal,'visible','off')
% Muestra el panel de botones de parametros
set(handles.botonesparametros,'visible','on')
% Si no estaba la opcion de todos los receptores elegida, reactiva el panel de
% receptores y actualiza la informacion de receptor
if ~get(handles.todoslosreceptores,'Value')
    set(handles.listareceptores,'Enable','on');
    seleccionreceptor = handles.listareceptores.Value;
    % Actualizar informacion del receptor
    infoReceptor(hObject, eventdata, handles)
end
% Reactiva la opcion de todos los receptores
set(handles.todoslosreceptores,'Enable','on');
% Deseleccionar botones de historia temporal
set(handles.splVSdist,'Value',0)
set(handles.MapCruceOctBoton,'Value',0)
set(handles.MapaSPLboton,'Value',0)
set(handles.MapCruceGlobalBoton,'Value',0)
set(handles.MapEspec0toValBoton,'Value',0)
set(handles.MapEspecValtoinfBoton,'Value',0)
set(handles.generarvideoboton,'Value',0)
GenVideo = false;
% Desactivar boton de plotear
set(handles.botonplotear,'Enable','off')

%% Funcion que se ejecuta al pulsar el boton de historia temporal
function PestHist_Callback(hObject, eventdata, handles)
global seleccionreceptor IDRec_00
% Guarda un vector de indices del mismo tamaño que el total de IDRec, es decir,
% selecciona todos los receptores
seleccionreceptor = 1:numel(IDRec_00);
% Hace visible el panel de botones de historia temporal
set(handles.paneltemporal,'visible','on')
% Oculta el panel de botones de parametros
set(handles.botonesparametros,'visible','off')
% Desactiva la lista de receptores
set(handles.listareceptores,'Enable','off');
% Desactiva la opcion de todos los receptores
set(handles.todoslosreceptores,'Enable','off');
% Deseleccionar botones de parametros
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
set(handles.rastisinruidoboton,'Value',0)
set(handles.rasticonruidoboton,'Value',0)
set(handles.stisinruidoboton,'Value',0)
set(handles.sticonruidoboton,'Value',0)
% Si anteriormente estos botones se han desactivado al activar el video, se
% reactivan
set(handles.MapEspec0toValBoton,'Enable','on')
set(handles.MapEspecValtoinfBoton,'Enable','on')
% Desactivar boton de plotear
set(handles.botonplotear,'Enable','off')
% Actualizar informacion del receptor
infoReceptor(hObject, eventdata, handles)

%% Funcion que se ejecuta al pulsar el boton de Promedio
function promediotodo_Callback(hObject, eventdata, handles)
global seleccionreceptor IDRec_00
% Si se selecciona
if get(hObject,'Value')==1
    % Selecciona la opcion de todos los receptores
    set(handles.todoslosreceptores,'Value',1);
    % Desactiva la lista de receptores
    set(handles.listareceptores,'Enable','off');
    % Almacena un vector para seleccionar todos los receptores
    seleccionreceptor = 1:numel(IDRec_00);
    % Desactiva y deselecciona los botones de parametros que no ofrecen promedio
    set(handles.rastisinruidoboton,'enable','off')
    set(handles.rasticonruidoboton,'enable','off')
    set(handles.stisinruidoboton,'enable','off')
    set(handles.sticonruidoboton,'enable','off')
    set(handles.rastisinruidoboton,'value',0)
    set(handles.rasticonruidoboton,'value',0)
    set(handles.stisinruidoboton,'value',0)
    set(handles.sticonruidoboton,'value',0)
    % Actualiza la informacion de receptor
    infoReceptor(hObject, eventdata, handles)
    % Si no hay ningun parametro seleccionado se desactiva la opcion de plotear
    if isempty(handles.botonesparametros.SelectedObject)
        set(handles.botonplotear,'Enable','Off')
    end
else % Si se deselecciona
    % El boton de todos los receptores se deselecciona
    set(handles.todoslosreceptores,'Value',0);
    % Se reactiva la lista de receptores
    set(handles.listareceptores,'Enable','on');
    % Se actualiza la seleccion de receptor
    seleccionreceptor = handles.listareceptores.Value;
    % Se reactivan los botones de RASTI y STI
    set(handles.rastisinruidoboton,'enable','on')
    set(handles.rasticonruidoboton,'enable','on')
    set(handles.stisinruidoboton,'enable','on')
    set(handles.sticonruidoboton,'enable','on')
    % Actualizar informacion del receptor
    infoReceptor(hObject, eventdata, handles)
end


%% Se ejecuta al seleccionar algun boton del panel de parametros
function botonesparametros_SelectionChangedFcn(hObject, eventdata, handles)
set(handles.botonplotear,'Enable','on')


%% Se ejecuta al seleccionar algun boton del panel de historia temporal
function paneltemporal_SelectionChangedFcn(hObject, eventdata, handles)
set(handles.botonplotear,'Enable','on')

%% Funcion para resetear botones, listas y graficas
function limpiar(handles)
global seleccionreceptor
% Deselecciona el boton de todos los receptores
set(handles.todoslosreceptores,'Value',0)
% Deselecciona el boton de promedio
set(handles.promediotodo,'Value',0)
% Resetea la seleccion de receptor al primero de la lista
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
set(handles.botonsplbandas,'Value',0)
set(handles.rastisinruidoboton,'Value',0)
set(handles.rasticonruidoboton,'Value',0)
set(handles.stisinruidoboton,'Value',0)
set(handles.sticonruidoboton,'Value',0)

% Desactivar boton de plotear, el de abrir nueva figura y el de exportar figura
set(handles.botonplotear,'Enable','off')
set(handles.abrirnuevafigura,'Enable','off')
set(handles.botonExportar,'Enable','off')

% Limpiar graficas
limpiarPlots(handles)
% Oculta la barra de herramientas
set(handles.barraheramientas,'Visible','off')

% Asegurar que no quedan listados receptores y fuentes de datos anteriores
set(handles.listareceptores,'string',[])
set(handles.listafuentes,'string',[])

%% Funcion para actualizar la informacion del receptor
function infoReceptor(hObject, eventdata, handles)
global RecPosition_00 HeadDirection_00 IDFuente seleccionreceptor IDRec_00
% si solo hay un receptor seleccionado se añade toda la informacion a su panel
if numel(seleccionreceptor)==1
    Ind = seleccionreceptor;
    % Se carga la variable global de posicion de fuente a una local
    eval(sprintf('global SRCPosition_%s',IDFuente))
    eval(sprintf('SRCPosition = SRCPosition_%s;',IDFuente))
    % Actualiza el titulo del panel de receptor
    set(handles.panelreceptor,'Title',[handles.LRECPARAMETERS,sprintf(' %s',num2str(IDRec_00(Ind)))])
    % Actualiza la posicion del receptor
    set(handles.posicionreceptor,'string',...
        strcat(num2str(RecPosition_00(Ind,1)),'x',num2str(RecPosition_00(Ind,2)),'x',num2str(RecPosition_00(Ind,3)),' m'))
    % Actualiza la direccion del receptor
    if ~isempty(HeadDirection_00)
        set(handles.orientacionrec,'string',...
            strcat(num2str(HeadDirection_00(Ind,1)),'x',num2str(HeadDirection_00(Ind,2)),'x',num2str(HeadDirection_00(Ind,3)),' m'))
    else
        set(handles.orientacionrec,'string',handles.LWITHOUTINFO)
    end
    % Calcula la distancia entre el receptor y la fuente
    Distancia = sqrt(...
        (RecPosition_00(Ind,1)-SRCPosition(1))^2+...
        (RecPosition_00(Ind,2)-SRCPosition(2))^2+...
        (RecPosition_00(Ind,3)-SRCPosition(3))^2);
    % Actualiza la distancia a la fuente
    set(handles.distfuente,'string',sprintf('%4.2f m',Distancia))
else % Si hay elegido mas de un receptor se indica que no hay informacion a mostrar
    set(handles.panelreceptor,'Title',handles.LRECTITLEMULTIPLE)
    set(handles.posicionreceptor,'string',handles.LNOAVAILABLE)
    set(handles.orientacionrec,'string',handles.LNOAVAILABLE)
    set(handles.distfuente,'string',handles.LNOAVAILABLE)
end


%% Funcion que actualiza los parametros mostrados de la fuente
function infoFuente(hObject, eventdata, handles)
global IDFuente NumeroBandas
% Se obtiene las ID de fuentes de la lista de fuentes y el indice de la
% seleccion
ListaFuentes = get(handles.listafuentes,'string');
IndiceFuente = get(handles.listafuentes,'Value');
% Se obtiene la ID de fuente seleccionada
IDFuente = ListaFuentes{IndiceFuente};
% Se cargan las variables globales de la fuentes en variables locales
eval(sprintf('global Directivity_%s',IDFuente))
eval(sprintf('Directivity = Directivity_%s;',IDFuente))
eval(sprintf('global SRCPosition_%s',IDFuente))
eval(sprintf('SRCPosition = SRCPosition_%s;',IDFuente))
eval(sprintf('global TotalPower_%s',IDFuente))
eval(sprintf('TotalPower = TotalPower_%s;',IDFuente))
eval(sprintf('global Pressure1m_%s',IDFuente))
eval(sprintf('Pressure1m = Pressure1m_%s;',IDFuente))
% Actualiza el titulo del panel de fuente
set(handles.parametrosfuente,'Title',[handles.LSRCPARAMETERS,sprintf(' %s',IDFuente)])
% Actualiza la posicion de la fuente
set(handles.SRCPosition,'string',...
    strcat(num2str(SRCPosition(1)),'x',num2str(SRCPosition(2)),'x',num2str(SRCPosition(3)),' m'))
% Variable para titular las columnas de las tablas
bandastabla = {'125','250','500','1K','2K','4K','8K','16K'};
bandastabla(NumeroBandas+1:end) = [];
% Actualiza la tabla de presion a 1 metro
set(handles.tablaSPL1m,'data',[bandastabla;num2cell(Pressure1m)])
% Actualiza la tabla de potencia total
set(handles.tablaPotTotal,'data',[bandastabla;num2cell(TotalPower)])
% Actualiza la tabla de la directividad
set(handles.tablaDir,'data',[bandastabla;num2cell(Directivity)])


%% Funcion que limpia y oculta los plots y subplots
function limpiarPlots(handles)
% Resetea todos los axes
reset(gca)
% Limpia el contenido de las graficas
cla(handles.plotfig,'reset')
cla(handles.middleplot1,'reset')
cla(handles.middleplot2,'reset')
cla(handles.subplot1,'reset')
cla(handles.subplot2,'reset')
cla(handles.subplot3,'reset')
cla(handles.subplot4,'reset')
cla(handles.subplot5,'reset')
cla(handles.subplot6,'reset')
cla(handles.subplot7,'reset')
cla(handles.subplot8,'reset')
% Oculta las graficas
set(handles.plotfig,'Visible','off')
set(handles.middleplot1,'Visible','off')
set(handles.middleplot2,'Visible','off')
set(handles.subplot1,'Visible','off')
set(handles.subplot2,'Visible','off')
set(handles.subplot3,'Visible','off')
set(handles.subplot4,'Visible','off')
set(handles.subplot5,'Visible','off')
set(handles.subplot6,'Visible','off')
set(handles.subplot7,'Visible','off')
set(handles.subplot8,'Visible','off')


%% Funcion al pulsar el boton de guardar imagen
function botonExportar_Callback(hObject, eventdata, handles)
% Crea una nueva figura copiando la existente y dejandola invisible
figura = nuevafigura(handles,'off');
% Solicita un nombre de archivo, ruta y formato de archivo
[file,path,index] = uiputfile({...
    '*.jpg','JPEG';                             % 1 - JPEG
    '*.png','PNG';                              % 2 - PNG
    '*.bmp','BMP';                              % 3 - BMP
    '*.tif','TIFF';                             % 4 - TIFF
    '*.pdf','Portable Document Format (PDF)';   % 5 - PDF
    '*.eps','Encapsulated PostScript (EPS)';    % 6 - EPS
    '*.svg','Scalable vector graphics (SVG)';   % 7 - SVG
    '*.fig','MATLAB FIG-file'...                % 8 - FIG
    },handles.LSAVEFIGURE,[handles.LEXPORTEDFIGURE,'.jpg']);
if file==0
    % Si se ha cancelado la seleccion de ruta, sale de la funcion
    close(figura); % Cierra la nueva figura
    return
end
% Mensaje para esperar a que termine de exportar
h = msgbox(handles.LEXPORTINGFIGURE,handles.LEXPORTINGTITLE,'help','modal');
set(findobj(h,'style','pushbutton'),'Visible','off')
% Si no se ha elegido guardar como figura, se realizan modificaciones antes de
% guardar
if index~=8
    % Modifica el tamaño de diferentes partes de la figura para que la imagen se
    % pueda ver sin molestia
    axes_c = findobj(figura,'type','axes');
    numPlots = numel(axes_c);
    % Para utilizar la altura de la pantalla para calcular la escala
    Tamano = get(groot,'Screensize');
    if numPlots>1
        escala = Tamano(4)/400;
        Fuentes = findall(axes_c,'-property','FontSize');
    else
        if size(axes_c.Legend.String,2)<15
            Factor = 400;
        elseif size(axes_c.Legend.String,2)<25
            Factor = 480;
        elseif size(axes_c.Legend.String,2)<34
            Factor = 500;
        else
            Factor = 560;
        end
        escala = Tamano(4)/Factor; % usar 360 en lugar de factor si se desea
        Fuentes = findall(figura,'-property','FontSize');
    end
    % Escalar las fuentes
    for i=1:numel(Fuentes)
        Fuentes(i).FontSize = Fuentes(i).FontSize*escala;
    end
    % Escalar las lineas
    Lineas = findall(axes_c,'-property','LineWidth');
    for i=1:numel(Lineas)
        Lineas(i).LineWidth = escala;
    end
    
end
% Guardar en el formato elegido
switch index
    case 1
        print(figura,'-opengl','-djpeg','-r300', strcat(path,file))
    case 2
        print(figura,'-opengl','-dpng','-r300', strcat(path,file))
    case 3
        print(figura,'-opengl','-dbmp','-r300', strcat(path,file))
    case 4
        print(figura,'-opengl','-dtiff','-r300', strcat(path,file))
    case 5
        % Configura las dimensiones para ajustar la pagina PDF al tamaño de la
        % figura
        set(figura, 'Units', 'centimeters')
        set(figura, 'PaperUnits','centimeters');
        pos = get(figura,'Position');
        set(figura, 'PaperSize', [pos(3) pos(4)]);
        set(figura, 'PaperPositionMode', 'manual');
        set(figura, 'PaperPosition', [0 0 pos(3) pos(4)]);
        % Guardar el archivo PDF
        print(figura,'-opengl','-dpdf','-r300', strcat(path,file))
    case 6
        print(figura,'-opengl','-depsc','-r300', strcat(path,file))
    case 7
        print(figura,'-opengl','-dsvg','-r300', strcat(path,file))
    otherwise
        saveas(figura,strcat(path,file));
end
close(figura); % Cierra la nueva figura
set(findobj(h,'Tag','MessageBox'),'String',handles.LEXPORTEDFIGURE)
set(findobj(h,'style','pushbutton'),'Visible','on')
% Funcion si se pulsa el boton informacion del menu de la aplicacion
function botoninformacion_Callback(~, ~, ~)
% hObject    handle to botoninformacion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('Information in upcoming versions','Information','help')

% --------------------------------------------------------------------
function menuacercade_Callback(~, ~, ~)
msgbox(sprintf('Created by Jose Manuel Requena Plens\n info@jmrplens.com'),'About','Help')


% --------------------------------------------------------------------
function exportaramat_Callback(hObject, eventdata, handles)
global CarpetaTempMat
% Nombre de la carpeta que almacenará todos los .mat
CarpetaDatos = sprintf([handles.LDATA,'_%s'],datestr(datetime('now'),'dd-mm-yy_HH.MM'));
% Solicita la carpeta donde guardar los .mat
[file,path,~] = uiputfile({...
    '*',handles.LSAVEDATAMATFOLDER;                             % 1 - JPEG
    },handles.LSAVEDATAMAT,CarpetaDatos);

if file==0; return; end
% Busca los archivos .mat y almacena su ruta
Archivos = what(CarpetaTempMat);
ArchivosMat=strcat(CarpetaTempMat,filesep,Archivos(1).mat);
% Crear la carpeta dentro de la ruta elegida por el usuario
mkdir([path,file,filesep])
% Copia uno a uno los archivos .mat desde la carpeta temporal a la nueva
% carpeta
for i=1:length(ArchivosMat)
    copyfile(ArchivosMat{i},[path,file,filesep])
end
msgbox(handles.LMATSAVED,handles.LMSGBOXTITLE,'help','modal')

%% Esta funcion se utiliza cada vez que se pulsa un idioma en el menu de idiomas
function cambiaridioma(hObject,eventdata,handles,lang)
global IDFuente
handles = language(handles,hObject,lang);
% Si aun no se ha cargado datos en la aplicacion, no actualiza la informacion
if ~isempty(IDFuente)
    infoReceptor(hObject,eventdata,handles)
    infoFuente(hObject,eventdata,handles)
end


% --- Executes on button press in generarvideoboton.
function generarvideoboton_Callback(hObject, eventdata, handles)
global GenVideo
if get(hObject,'value')==0
    GenVideo = false;
    set(handles.MapEspec0toValBoton,'Enable','on')
    set(handles.MapEspecValtoinfBoton,'Enable','on')
else
    GenVideo = true;
    set(handles.MapEspec0toValBoton,'Enable','off')
    set(handles.MapEspecValtoinfBoton,'Enable','off')
    set(handles.MapEspec0toValBoton,'Value',0)
    set(handles.MapEspecValtoinfBoton,'Value',0)
    if isempty(handles.paneltemporal.SelectedObject)
        set(handles.botonplotear,'Enable','off')
    end
end

%% Funcion que se ejecuta despues de cambiar el valor en el rango para el video
function limvideoms_Callback(hObject, ~, ~)
global MaxElegible
Valor = str2double(get(hObject,'String'));
set(hObject,'String',num2str(floor(Valor)))
if str2double(get(hObject,'String')) > MaxElegible
    set(hObject,'String',num2str(floor(MaxElegible)))
end
if str2double(get(hObject,'String'))==0
    set(hObject,'String','1')
end



%% Funcion que se ejecuta despues de cambiar el valor en el rango temporal
function rangotemporal_Callback(hObject, ~, ~)
global MaxElegible
Valor = str2double(get(hObject,'String'));
set(hObject,'String',num2str(floor(Valor)))
if str2double(get(hObject,'String')) > MaxElegible
    set(hObject,'String',num2str(floor(MaxElegible)))
end
if str2double(get(hObject,'String'))==0
    set(hObject,'String','1')
end

%% Otras funciones generadas por Matlab

function rangotemporal_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function limvideoms_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CATT2MatlabApp_DeleteFcn(~, ~, ~)

function listafuentes_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string',[])

function listareceptores_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string',[])
