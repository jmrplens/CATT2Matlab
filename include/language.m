function [handles] = language(handles,hObject,lang)
% LANGUAGE  Actualiza los idiomas disponibles y asigna el idioma elegido
%
% Para añadir un idioma al programa se deben seguir dos sencillos pasos:
%
% 1. Añadir el nombre del idioma y el codigo de idioma a la variable
%   Languages, siendo este un vector de 2 elementos.
%
% 2. En la funcion switch, añadir un caso con el codigo del idioma agregado
%   y dentro de él, copiar todo lo que contiene el caso por defecto(otherwise) y
%   traducir las frases
%
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>


% Idiomas disponibles
Languages = {
    % Idioma , Codigo
    'Español','es';
    'English','en'
    };

% Si se ha añadido/eliminado algun idioma en la variable Languages se
% reconstruye el submenu para elegir idioma
if length(handles.menuidioma.Children)~=length(Languages)
    % Reinicia el submenu de idiomas
    delete(handles.menuidioma.Children);
    
    % Crear los items en el submenu idioma para cada idioma incluido en 'Languages'
    for i=1:length(Languages)
        uimenu(handles.menuidioma,'Label',Languages{i,1},...
            'Callback',{@(hObject,eventdata)...
            CATT2MatlabAPP('cambiaridioma',hObject,eventdata,guidata(hObject),Languages{i,2})});
    end
end

switch lang
    
    case 'es'   % Español
        
        % Titulo de la aplicacion
        handles.LORIGINALNAME               = 'CATT2MatlabAPP';
        
        % Panel de parametros de la sala
        handles.panelparametrossala.Title   = 'Parámetros de la sala';
        handles.dimensionestag.String       = 'Dimensiones:';
        handles.volumentag.String           = 'Volumen:';
        handles.superficietag.String        = 'Superficie:';
        handles.temperaturatag.String       = 'Temperatura:';
        handles.densidadairetag.String      = 'Densidad del aire:';
        handles.impedanciatag.String        = 'Impedancia del aire:';
        handles.humedadtag.String           = 'Humedad:';
        handles.velocidadsonidotag.String   = 'Velocidad del sonido:';
        handles.absorcionairetag.String     = 'Absorción del aire por octava [%]';
        
        % Panel de parametros de fuente
        handles.LSRCPARAMETERS              = 'Parámetros de la fuente';
        handles.posiciontag.String          = 'Posición:';
        handles.spl1mtag.String             = 'SPL a 1 metro por octava (dB):';
        handles.potenciatotaltag.String     = 'Potencia total por octava (dB):';
        handles.directividadtag.String      = 'Directividad por octava (dB):';
        
        % Lista fuentes
        handles.panellistafuentes.Title     = 'Fuentes';
        
        % Lista receptores
        handles.panellistareceptores.Title  = 'Receptores';
        
        % Panel de parametros del receptor
        handles.LRECPARAMETERS              = 'Parámetros del receptor';
        handles.posicionreceptortag.String  = 'Posición:';
        handles.orientaciontag.String       = 'Orientación:';
        handles.LWITHOUTINFO                = 'Sin información';
        handles.distfuentetag.String        = 'Distancia a fuente:';
        handles.LRECTITLEMULTIPLE           = 'Parámetros del receptor - Múltiples';
        handles.LNOAVAILABLE                = 'No disponible';
        
        % Panel de botones de parametros
        handles.botonesparametros.Title     = 'Parámetros acústicos disponibles';
        handles.promediotodo.String         = 'Obtener promedio (Barras)';
        handles.rastisinruidoboton.String   = 'RASTI sin ruido de fondo';
        handles.rasticonruidoboton.String   = 'RASTI con ruido de fondo';
        handles.stisinruidoboton.String     = 'STI sin ruido de fondo';
        handles.sticonruidoboton.String     = 'STI con ruido de fondo';
        
        % Botones de historia temporal
        handles.paneltemporal.Title         = 'Historia temporal';
        handles.InfoRangoTemp.String        = 'Rango temporal en ms (de 0 a N ms y de N ms a infinito)';
        handles.valmaxtag.String            = 'Valor máximo elegible:';
        handles.MapaSPLboton.String         = 'Mapa SPL [3D]';
        handles.splVSdist.String            = 'SPL vs Distancia';
        handles.MapCruceGlobalBoton.String  = 'Mapa de cruce de nivel global [2D]';
        handles.MapCruceOctBoton.String     = 'Mapa de cruce por octavas [2D]';
        handles.MapEspec0toValBoton.String  = 'Mapa de nivel por octava (0-N ms) [2D]';
        handles.MapEspecValtoinfBoton.String = 'Mapa de nivel por octava (N-inf ms) [2D]';
        handles.panelvideo.Title            = 'Vídeo';
        handles.generarvideoboton.String    = 'Generar vídeo';
        handles.infogenvideo.String         = 'De 1 ms hasta:';
        
        % Resto de botones
        handles.todoslosreceptores.String   = 'Todos los receptores';
        handles.mapapos2d.String            = 'Mapa de posiciones 2D';
        handles.mapapos3d.String            = 'Mapa de posiciones 3D';
        handles.PestParam.String            = 'Parámetros';
        handles.PestHist.String             = 'Hist. Temporal';
        handles.botonplotear.String         = 'Representar';
        handles.abrirnuevafigura.String     = 'Abrir representación en una nueva figura';
        handles.botonExportar.String        = 'Exportar figura';
        
        % Mensajes de carga
        handles.cargandoPlot.String         = sprintf('\nCargando representación');
        handles.LREADSRC                    = 'Leyendo archivo de fuente:';
        handles.LGETPARAM                   = 'Obteniendo parámetros';
        handles.LREADISM                    = 'Leyendo archivos ISM';
        handles.LIMPORTINGMAT               = 'Importando datos';
        handles.LLOADDATAAPP                = 'Cargando datos en la aplicación';
        handles.LCREATETPARAM               = 'Creando tablas de parámetros';
        handles.LCREATETISM                 = 'Creando tablas de datos de ISM';
        handles.LWRITEPARAM                 = 'Escribiendo parámetros';
        handles.LWRITEISM                   = 'Escribiendo datos de ISM';
        handles.LPROGRESSTITLE              = 'Progreso';
        handles.LTIMEDAYS                   = 'dias';
        handles.LTIMEHOURS                  = 'horas';
        handles.LTIMEMINS                   = 'mins';
        handles.LTIMESECS                   = 'segs';
        handles.LTIMESEC                    = 'seg';
        
        % Informacion de ejes
        handles.LVALUEDB                    = 'Valor (dB)';
        handles.LTIMEMS                     = 'Tiempo (ms)';
        handles.LTIMES                      = 'Tiempo (s)';
        handles.LVALUEPERCENT               = 'Valor (%)';
        handles.LXFREQ                      = 'Frecuencia';
        handles.LLEVELDB                    = 'Nivel (dB)';
        handles.LLENGTHX                    = 'Lx (m)';
        handles.LLENGTHY                    = 'Ly (m)';
        handles.LLENGTHZ                    = 'Lz (m)';
        handles.LDISTANCE                   = 'Distancia (en metros)';
        
        % Titulos de graficas
        handles.LSUBTITLE                   = 'Resultados para fuente';
        handles.LTITLECROSSRANK             = 'Cruce de los rangos de tiempos CATT';
        handles.LSPLTITLE                   = 'SPL según rango de tiempo CATT';
        handles.LTITLEMAPPOS                = 'Posición de los receptores';
        handles.LWITHOUTNOISE               = 'sin ruido de fondo';
        handles.LWITHNOISE                  = 'con ruido de fondo';
        
        
        
        % Titulos de leyendas
        handles.LTITLELEGEND                = 'Receptores:';
        handles.LSUBTITLELEGEND             = 'ID (Distancia a la fuente)';
        handles.LWORDTO                     = 'a';
        handles.LTOINF                      = 'a infinito';
        handles.LLEGENDSPLDIST              = 'Curvas';
        
        % Otros textos de las graficas
        handles.LSOURCE                     = 'Fuente';
        handles.LLEVEL                      = 'Nivel';
        
        % Menu
        handles.menuinicio.Label            = 'Inicio';
        handles.importarmenu.Label          = 'Importar de ...';
        handles.importardecatt.Label        = 'CATT-Acoustic v8 (Carpeta ''OUT'')';
        handles.importardematlab.Label      = 'CATT2Matlab (variables .mat)';
        handles.menuidioma.Label            = 'Idioma';
        handles.menusalir.Label             = 'Salir';
        handles.exportardatosmenu.Label     = 'Exportar datos';
        handles.exportaramat.Label          = 'Exportar datos a CATT2MatlabAPP (.mat)';
        handles.exportarexcel.Label         = 'Exportar datos a Excel (.xlsx)';
        handles.ayudamenu.Label             = 'Ayuda';
        handles.botoninformacion.Label      = 'Información';
        handles.menuacercade.Label          = 'Acerca de CATT2Matlab';
        
        % Menu boton derecho
        handles.menucontex.Children.Label   = 'Exportar figura';
        
        % Mensajes de error
        handles.LNOPARAM                    = 'No hay archivos del tipo ''PARAM_ss.TXT''';
        handles.LNOISM                      = 'No hay archivos del tipo ''I_ss_rr.TXT''';
        
        % Cabeceras de variables tipo CELL o TABLA y exportacion a Excel
        handles.LTITLESPLxREC               = {'Fuente','Receptor','Hist. Temporal'};
        handles.LRECID                      = 'ID Receptor';
        handles.LTIMESTRING                 = 'Tiempo';
        handles.LSOURCEEXCEL                = 'Fuente';
        
        % Otros
        handles.LDATA                       = 'Datos';
        
        % Mensajes emergentes
        handles.LMATSAVED                   = 'Archivos guardados';
        handles.LEXCELSAVED                 = 'Archivo Excel creado';
        handles.LMATIMPORTED                = 'Datos .mat importados';
        handles.LCATTIMPORTED               = 'Datos de CATT-Acoustic importados';
        handles.LNODATAFOUND                = 'No se han encontrado datos';
        
        % Ventanas de archivos o carpetas
        handles.LMSGBOXTITLE                = 'Información';
        handles.LSAVEDATAMAT                = 'Guardar datos';
        handles.LSAVEDATAMATFOLDER          = 'Carpeta nueva';
        handles.LSAVEFIGURE                 = 'Guardar figura';
        handles.LEXPORTINGFIGURE            = 'Exportando, por favor, espere...';
        handles.LEXPORTINGTITLE             = 'Exportando figura';
        handles.LEXPORTEDFIGURE             = 'Figura exportada';
        handles.LSAVEDATAEXCEL              = 'Guardar datos';
        handles.LEXPORTEDEXCEL              = 'Datos exportados';
        handles.LVIDEOSTRING                = 'Vídeo';
        handles.LSAVEVIDEO                  = 'Guardar vídeo';
        

    otherwise   % Idioma por defecto / english
        
        % Titulo de la aplicacion
        handles.LORIGINALNAME               = 'CATT2MatlabAPP';
        
        % Panel de parametros de la sala
        handles.panelparametrossala.Title   = 'Room parameters';
        handles.dimensionestag.String       = 'Dimensions:';
        handles.volumentag.String           = 'Volume:';
        handles.superficietag.String        = 'Surface:';
        handles.temperaturatag.String       = 'Temperature:';
        handles.densidadairetag.String      = 'Air density:';
        handles.impedanciatag.String        = 'Air impedance:';
        handles.humedadtag.String           = 'Humidity:';
        handles.velocidadsonidotag.String   = 'Sound speed:';
        handles.absorcionairetag.String     = 'Air absorption per octave [%]';
        
        % Panel de parametros de fuente
        handles.LSRCPARAMETERS              = 'Source parameters';
        handles.posiciontag.String          = 'Position:';
        handles.spl1mtag.String             = 'SPL to 1 meter per octave (dB):';
        handles.potenciatotaltag.String     = 'Total power per octave (dB):';
        handles.directividadtag.String      = 'Directivity per octave (dB):';
        
        % Lista fuentes
        handles.panellistafuentes.Title     = 'Sources';
        
        % Lista receptores
        handles.panellistareceptores.Title  = 'Receivers';
        
        % Panel de parametros del receptor
        handles.LRECPARAMETERS              = 'Receiver parameters';
        handles.posicionreceptortag.String  = 'Position:';
        handles.orientaciontag.String       = 'Direction:';
        handles.LWITHOUTINFO                = 'No information';
        handles.distfuentetag.String        = 'Distance to source:';
        handles.LRECTITLEMULTIPLE           = 'Receiver parameters - Multiple';
        handles.LNOAVAILABLE                = 'Not available';
        
        % Panel de botones de parametros
        handles.botonesparametros.Title     = 'Acoustic parameters availables';
        handles.promediotodo.String         = 'Get average (Bars)';
        handles.rastisinruidoboton.String   = 'RASTI without background noise';
        handles.rasticonruidoboton.String   = 'RASTI with background noise';
        handles.stisinruidoboton.String     = 'STI without background noise';
        handles.sticonruidoboton.String     = 'STI with background noise';
        
        % Botones de historia temporal
        handles.paneltemporal.Title         = 'Temporary history';
        handles.InfoRangoTemp.String        = 'Temporary range in ms (from 0 to N ms and from N ms to infinite)';
        handles.valmaxtag.String            = 'Max value available:';
        handles.MapaSPLboton.String         = 'SPL map [3D]';
        handles.splVSdist.String            = 'SPL vs Distance';
        handles.MapCruceGlobalBoton.String  = 'Cross map of global level [2D]';
        handles.MapCruceOctBoton.String     = 'Cross map per octave [2D]';
        handles.MapEspec0toValBoton.String  = 'Level map per octave (0-N ms) [2D]';
        handles.MapEspecValtoinfBoton.String = 'Level map per octave (N-inf ms) [2D]';
        handles.panelvideo.Title            = 'Video';
        handles.generarvideoboton.String    = 'Generate video';
        handles.infogenvideo.String         = 'From 1 ms to:';
        
        % Resto de botones
        handles.todoslosreceptores.String   = 'All receivers';
        handles.mapapos2d.String            = 'Positions map 2D';
        handles.mapapos3d.String            = 'Positions map 3D';
        handles.PestParam.String            = 'Parameters';
        handles.PestHist.String             = 'Temp. History';
        handles.botonplotear.String         = 'Plot';
        handles.abrirnuevafigura.String     = 'Open plot in new figure';
        handles.botonExportar.String        = 'Export figure';
        
        % Mensajes de carga
        handles.cargandoPlot.String         = sprintf('\nLoading plot');
        handles.LREADSRC                    = 'Reading file of source:';
        handles.LGETPARAM                   = 'Obtain parameters';
        handles.LREADISM                    = 'Reading ISM''s files';
        handles.LIMPORTINGMAT               = 'Importing data';
        handles.LLOADDATAAPP                = 'Load data into the aplication';
        handles.LCREATETPARAM               = 'Creating parameters tables';
        handles.LCREATETISM                 = 'Creating ISM data tables';
        handles.LWRITEPARAM                 = 'Writing parameters';
        handles.LWRITEISM                   = 'Writing ISM data';
        handles.LPROGRESSTITLE              = 'Progress';
        handles.LTIMEDAYS                   = 'days';
        handles.LTIMEHOURS                  = 'hours';
        handles.LTIMEMINS                   = 'mins';
        handles.LTIMESECS                   = 'secs';
        handles.LTIMESEC                    = 'sec';
        
        % Informacion de ejes
        handles.LVALUEDB                    = 'Value (dB)';
        handles.LTIMEMS                     = 'Time (ms)';
        handles.LTIMES                      = 'Time (s)';
        handles.LVALUEPERCENT               = 'Value (%)';
        handles.LXFREQ                      = 'Frequency';
        handles.LLEVELDB                    = 'Level (dB)';
        handles.LLENGTHX                    = 'Lx (m)';
        handles.LLENGTHY                    = 'Ly (m)';
        handles.LLENGTHZ                    = 'Lz (m)';
        handles.LDISTANCE                   = 'Distance (in meters)';
        
        % Titulos de graficas
        handles.LSUBTITLE                   = 'Results for source';
        handles.LTITLECROSSRANK             = 'Cross the range times';
        handles.LSPLTITLE                   = 'SPL acording time range';
        handles.LTITLEMAPPOS                = 'Receivers position';
        handles.LWITHOUTNOISE               = 'without background noise';
        handles.LWITHNOISE                  = 'with background noise';
        
        
        
        % Titulos de leyendas
        handles.LTITLELEGEND                = 'Receivers:';
        handles.LSUBTITLELEGEND             = 'ID (Distance to source)';
        handles.LWORDTO                     = 'to';
        handles.LTOINF                      = 'to infinite';
        handles.LLEGENDSPLDIST              = 'Curves';
        
        % Otros textos de las graficas
        handles.LSOURCE                     = 'Source';
        handles.LLEVEL                      = 'Level';
        
        % Menu
        handles.menuinicio.Label            = 'File';
        handles.importarmenu.Label          = 'Import from ...';
        handles.importardecatt.Label        = 'CATT-Acoustic v8 (Folder ''OUT'')';
        handles.importardematlab.Label      = 'CATT2Matlab (.mat variables)';
        handles.menuidioma.Label            = 'Language';
        handles.menusalir.Label             = 'Quit';
        handles.exportardatosmenu.Label     = 'Export data';
        handles.exportaramat.Label          = 'Export data to CATT2MatlabAPP (.mat)';
        handles.exportarexcel.Label         = 'Export data to Excel (.xlsx)';
        handles.ayudamenu.Label             = 'Help';
        handles.botoninformacion.Label      = 'Information';
        handles.menuacercade.Label          = 'About CATT2Matlab';
        
        % Menu boton derecho
        handles.menucontex.Children.Label   = 'Export figure';
        
        % Mensajes de error
        handles.LNOPARAM                    = 'No files of the type ''PARAM_ss.TXT''';
        handles.LNOISM                      = 'No files of the type ''I_ss_rr.TXT''';
        
        % Cabeceras de variables tipo CELL o TABLA y exportacion a Excel
        handles.LTITLESPLxREC               = {'Source','Receiver','Temp. History'};
        handles.LRECID                      = 'Receiver ID';
        handles.LTIMESTRING                 = 'Time';
        handles.LSOURCEEXCEL                = 'Source';
        
        % Otros
        handles.LDATA                       = 'Data';
        
        % Mensajes emergentes
        handles.LMATSAVED                   = 'Saved files';
        handles.LEXCELSAVED                 = 'Created Excel file';
        handles.LMATIMPORTED                = 'Imported .mat data';
        handles.LCATTIMPORTED               = 'Imported data from CATT-Acoustic';
        handles.LNODATAFOUND                = 'No data found';
        
        % Ventanas de archivos o carpetas
        handles.LMSGBOXTITLE                = 'Information';
        handles.LSAVEDATAMAT                = 'Save data';
        handles.LSAVEDATAMATFOLDER          = 'New folder';
        handles.LSAVEFIGURE                 = 'Save figure';
        handles.LEXPORTINGFIGURE            = 'Exporting, please, wait...';
        handles.LEXPORTINGTITLE             = 'Exporting figure';
        handles.LEXPORTEDFIGURE             = 'Exported figure';
        handles.LSAVEDATAEXCEL              = 'Save data';
        handles.LEXPORTEDEXCEL              = 'Exported data';
        handles.LVIDEOSTRING                = 'Video';
        handles.LSAVEVIDEO                  = 'Save video';
        
        
        
end
% Almacenar las variables en la aplicacion
guidata(hObject, handles);
