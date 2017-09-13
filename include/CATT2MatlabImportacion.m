%% (1) Funcion que inicia la importacion de datos del CATT (Total 8 funciones)
function Error = CATT2MatlabImportacion(Carpeta,handles)
% Procesa uno a uno todos los TXT contenidos en la carpeta recibida. Solo
% procesa lo que tengan por nombre PARAM_ss.TXT o I_ss_rr.TXT
%
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

% Agregar la carpeta al proyecto para poder acceder a sus archivos
addpath(Carpeta)

%% Obtencion de datos PARAM
Carpeta = strcat(Carpeta,filesep);
PARAMtxt = dir (strcat(Carpeta,'PARAM_*.TXT'));
if isempty(PARAMtxt)
    sprintf(handles.LNOPARAM)
    Error = true;
    return
else
    Error = false;
    % Bucle para procesar cada archivo txt
    for N=1:size(PARAMtxt,1)
        % Si es de tipo PARAM_ssx.TXT no se procesa
        if ~strcmp(PARAMtxt(N).name(end-4),'x')
            multiWaitbar(handles,[handles.LREADSRC,' ',PARAMtxt(N).name(7:8)],N/size(PARAMtxt,1),'color','b');
            Obtencion(PARAMtxt(N).name,handles)
        end
        multiWaitbar(handles,[handles.LREADSRC,' ',PARAMtxt(N).name(7:8)],'Close');
        multiWaitbar(handles,handles.LGETPARAM,'Close');
    end
end
%% Obtencion de datos ISM
% Estos TXT solo los genera el CATT si se activan en la carpeta de instalacion.
% Hay que ir a la raiz de la carpeta del programa, editar el archivo
% hiddenoptions_removethis quitando los dos punto y coma que hay delante de los
% numeros de serie, guardar y quitar del nombre del archivo el '_removethis'
ISMtxt = dir(strcat(Carpeta,filesep,'I_*.TXT'));
if isempty(ISMtxt)
    sprintf(handles.LNOISM)
else
    
    % Crear matriz para almacenar los datos por rango de tiempo para cada receptor y
    % fuente
    SPLxRec_00 = cell([size(ISMtxt,1)+1,3]);
    % Primera linea de la matriz con la informacion de cada columna
    SPLxRec_00(1,:) = handles.LTITLESPLxREC;
    
    % Bucle para procesar cada archivo txt
    for N=1:size(ISMtxt,1)
        
        multiWaitbar(handles,handles.LREADISM,N/size(ISMtxt,1),'color','b');
        
        % Llama a la funcion para obtener los datos
        [SPLtemp,IDFuente,IDReceptor,ISM]=ObtencionISM(ISMtxt(N,1).name);
        
        % Guarda en la matriz la informacion para cada receptor y fuente
        SPLxRec_00(N+1,:) = [mat2cell(IDFuente,1),mat2cell(IDReceptor,1),SPLtemp];
    end
    
    % Guarda los datos de la matriz en el ISM.mat
    save(ISM,'SPLxRec_00','-append')
    multiWaitbar(handles,handles.LREADISM,'Close');
end

%% (2) Funcion que obtiene los parametros de cada archivo PARAM_ss.TXT
function Obtencion (Archivo,handles)

% Recibe la ruta o nombre del archivo producido por CATT-Acoustics, en concreto
% el tipo de archivo PARAM_##.TXT, donde las almohadillas indican el ID de la
% fuente.
%
% Devuelve 4 archivos .mat:
%
% * Sala.mat: Contiene las caracteristicas de la sala
% * Receptores.mat: Contiene la ID de los receptores, su posicion y su
% orientacion
% * ParametrosAcusticos.mat: Contiene matrices y vectores con los parametros
% acusticos crudos, sin procesar.
% * Fuente_SS.mat: Contiene las caracteristicas de la fuente 'SS'
%

%% Inicializacion de archivos

[A,NombreFuente,ParametrosAcusticos,Receptores,Sala,Fuente] = Inicializacion(Archivo,handles);

%% Informacion sobre receptores

if ~isempty(find(strcmp(A, 'Rec id and loc')==1, 1))
    
    % Obtener numero de receptores. Se obtiene restando la posicion donde empieza
    % una lista de receptores a la posicion donde termina.
    % Si no lo identifica correctamente modifica las cadenas de caracteres que lo
    % delimitan
    NumReceivers_00 = size(find(strcmp(A, 'Rec id and loc')==1),1);
    save(Receptores, 'NumReceivers_00', '-append')
    
    Ini = find(strcmp(A, 'Rec id and loc')==1,1);
    % Obtener el ID de cada receptor
    IDRec_00 = str2double(A(Ini:Ini+NumReceivers_00-1,3));
    save(Receptores, 'IDRec_00', '-append')
    
    % Obtener posicion de cada receptor {x,y,z}
    RecPosition_00 = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,4:6)); % metros
    save(Receptores, 'RecPosition_00', '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.35);
% Añadir orientacion de cada receptor a IDRec {x,y,z}
if ~isempty(find(strcmp(A, 'Head direction')==1, 1))
    Ini = find(strcmp(A, 'Head direction')==1,1);
    if ~isnan(A{Ini+1,2})
        % Extrae los numeros eliminando texto y lo convierte a matriz de numeros
    HeadDirection_00 = cellfun(@(var) cell2mat(textscan(var, '%f')),A(Ini+1:Ini+NumReceivers_00,2:4)); % metros
    else
        HeadDirection_00 = [];
    end
    save(Receptores, 'HeadDirection_00', '-append')
end

multiWaitbar(handles,handles.LGETPARAM,0.40);

%% Parametros de la fuente

% Posicion de la fuente {x,y,z}
if ~isempty(find(strcmp(A, 'Src id and loc')==1, 1))
    Ini = strcmp(A, 'Src id and loc')==1;
    SRCPosition = cellfun(@str2double, A(Ini,4:6)); % metros
    eval(sprintf('SRCPosition_%s = SRCPosition ;', NombreFuente));
    save(Fuente, strcat('SRCPosition_',NombreFuente), '-append')
end

% Indice de directividad de 125Hz a 4KHz-16KHz
if ~isempty(find(strcmp(A, 'Dir. Index (DI) [dB] :')==1, 1))
    Ini = find(strcmp(A, 'Dir. Index (DI) [dB] :')==1,1);
    if isnan(A{Ini,8})
        Directivity = cellfun(@str2double, A(Ini,2:7)); %#ok<*NASGU> % dB
    else
        Directivity = cellfun(@str2double, A(Ini,2:9)); % dB
    end
    eval(sprintf('Directivity_%s = Directivity ;', NombreFuente));
    save(Fuente, strcat('Directivity_',NombreFuente), '-append')
end

% Segun la longitud de la variable directividad seran datos hasta los 4 KHz o
% hasta 16 Khz, la variable siguiente se utiliza para importar arrays de 6 o de
% 8 elementos
NumBandas = numel(Directivity);

% Presion acustica a 1 metro de 125Hz a 4Khz-16KHz
if ~isempty(find(strcmp(A, 'On axis')==1, 1))
    Ini = strcmp(A, 'On axis')==1;
    if NumBandas == 6
        Pressure1m = cellfun(@str2double, A(Ini,4:9)); % dB
    else
        Pressure1m = cellfun(@str2double, A(Ini,4:11)); % dB
    end
    eval(sprintf('Pressure1m_%s = Pressure1m ;', NombreFuente));
    save(Fuente, strcat('Pressure1m_',NombreFuente), '-append')
end

% Potencia acustica total de 125Hz a 4Khz-16KHz
if ~isempty(find(strcmp(A, 'Total power')==1, 1))
    Ini = strcmp(A, 'Total power')==1;
    if NumBandas == 6
        TotalPower = cellfun(@str2double, A(Ini,3:8)); % dB
    else
        TotalPower = cellfun(@str2double, A(Ini,3:10)); % dB
    end
    eval(sprintf('TotalPower_%s = TotalPower ;', NombreFuente));
    save(Fuente, strcat('TotalPower_',NombreFuente), '-append')
end

multiWaitbar(handles,handles.LGETPARAM,0.5);

%% Parametros de la sala

% Obtener parametros de dimensiones
% No se puede elegir el string de volumen porque contiene caracteres especiales
% (^3) por lo que se selecciona el string de la columna siguiente, pero como
% cuenta toda la primera columna y luego hasta que lo encuentra en la segunda
% hay que restar el total al resultado
if ~isempty(find(strcmp(A, 'Lx[m]')==1, 1))
    Ini = find(strcmp(A, 'Lx[m]')==1)-size(A,1);
    RoomVolume_00 = str2double(A(Ini+2,1)); % metros cubicos
    RoomDimensions_00 = [str2double(A(Ini+2,2)),str2double(A(Ini+2,3)),str2double(A(Ini+2,4))]; % metros
    RoomSurface_00 = str2double(A(Ini+2,5)); % Superficie
    save(Sala, 'RoomVolume_00', '-append')
    save(Sala, 'RoomDimensions_00', '-append')
    save(Sala, 'RoomSurface_00', '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.55);
% Temperatura
if ~isempty(find(strcmp(A, 'Temperature')==1, 1))
    Ini = strcmp(A, 'Temperature')==1;
    Temperature_00 = str2double(A(Ini,3)); % Celsius
    save(Sala, 'Temperature_00', '-append')
end

% Humedad del aire
if ~isempty(find(strcmp(A, 'Relative humidity')==1, 1))
    Ini = strcmp(A, 'Relative humidity')==1;
    Humidity_00 = str2double(A(Ini,3)); % En %
    save(Sala, 'Humidity_00', '-append')
end

% Densidad del aire
if ~isempty(find(strcmp(A, 'Density')==1, 1))
    Ini = strcmp(A, 'Density')==1;
    AirDensity_00 = str2double(A(Ini,3)); % Kg/m3
    save(Sala, 'AirDensity_00', '-append')
end

% Velocidad del sonido
if ~isempty(find(strcmp(A, 'Sound speed')==1, 1))
    Ini = strcmp(A, 'Sound speed')==1;
    SoundSpeed_00 = str2double(A(Ini,3)); % En m/s
    save(Sala, 'SoundSpeed_00', '-append')
end

% Impedancia del aire
if ~isempty(find(strcmp(A, 'Impedance')==1, 1))
    Ini = strcmp(A, 'Impedance')==1;
    AirImpedance_00 = str2double(A(Ini,3)); % En Ns/m3
    save(Sala, 'AirImpedance_00', '-append')
end

% Coeficiente de disipacion del aire. 125Hz a 4Khz-16KHz
if ~isempty(find(strcmp(A, 'Diss. coeff. [0.001/m] :')==1, 1))
    Ini = strcmp(A, 'Diss. coeff. [0.001/m] :')==1;
    if NumBandas == 6
        DissAirCoeff_00 = str2double(A(Ini,2:7)); % En Ns/m3
    else
        DissAirCoeff_00 = str2double(A(Ini,2:9)); % En Ns/m3
    end
    save(Sala, 'DissAirCoeff_00', '-append')
end

multiWaitbar(handles,handles.LGETPARAM,0.6);

%% Parametros acusticos
% Retardo del campo directo. Cuanto tarda el sonido desde la fuente al receptor
if ~isempty(find(strcmp(A, 'Rec id Initial delay time [ms]')==1, 1))
    Ini = find(strcmp(A, 'Rec id Initial delay time [ms]')==1)+1;
    DelayDirect = cellfun(@str2double,A(Ini:Ini+NumReceivers_00-1,2)); % milisegundos
    eval(sprintf('DelayDirect_%s = DelayDirect ;', NombreFuente));
    save(ParametrosAcusticos, strcat('DelayDirect_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.62);
% Resumen de resultados
% Camino libre medio de 125Hz a 4KHz-16KHz
% Distancia media recorrida por los rayos por bandas de octava calculado como
% 4*Volumen/Superficie
if ~isempty(find(strcmp(A, 'MFP')==1, 1))
    Ini = find(strcmp(A, 'MFP')==1);
    if NumBandas == 6
        MeanFreePath = str2double(A(Ini,3:8)); % segundos
    else
        MeanFreePath = str2double(A(Ini,3:10)); % segundos
    end
    eval(sprintf('MeanFreePath_%s = MeanFreePath ;', NombreFuente));
    save(ParametrosAcusticos, strcat('MeanFreePath_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.64);
% Coeficiente de dispersion de 125Hz a 4KHz-16KHz
if ~isempty(find(strcmp(A, 'Diffs[%]')==1, 1))
    Ini = find(strcmp(A, 'Diffs[%]')==1);
    if NumBandas == 6
        AverageScattering = str2double(A(Ini,2:7)); % segundos
    else
        AverageScattering = str2double(A(Ini,2:9)); % segundos
    end
    eval(sprintf('AverageScattering_%s = AverageScattering ;', NombreFuente));
    save(ParametrosAcusticos, strcat('AverageScattering_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.66);
% T15 - De -5dB a -20dB
if ~isempty(find(strcmp(A, 'T-15 [s]')==1, 1))
    Ini = find(strcmp(A, 'T-15 [s]')==1);
    if NumBandas == 6
        resT15 = str2double(A(Ini,2:7)); % segundos
    else
        resT15 = str2double(A(Ini,2:9)); % segundos
    end
    eval(sprintf('resT15_%s = resT15 ;', NombreFuente));
    save(ParametrosAcusticos, strcat('resT15_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.68);
% T30 - De -5dB a -35dB
if ~isempty(find(strcmp(A, 'T-30 [s]')==1, 1))
    Ini = find(strcmp(A, 'T-30 [s]')==1);
    if NumBandas == 6
        resT30 = str2double(A(Ini,2:7)); % segundos
    else
        resT30 = str2double(A(Ini,2:9)); % segundos
    end
    eval(sprintf('resT30_%s = resT30 ;', NombreFuente));
    save(ParametrosAcusticos, strcat('resT30_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.70);
% RT de referencia introducido por el usuario
if ~isempty(find(strcmp(A, 'Tref [s]')==1, 1))
    Ini = find(strcmp(A, 'Tref [s]')==1);
    if NumBandas == 6
        resTref = str2double(A(Ini,2:7)); % segundos
    else
        resTref = str2double(A(Ini,2:9)); % segundos
    end
    eval(sprintf('resTref_%s = resTref ;', NombreFuente));
    save(ParametrosAcusticos, strcat('resTref_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.72);
% RT Eyring utilizando AbsC
if ~isempty(find(strcmp(A, 'EyrT [s]')==1, 1))
    Ini = find(strcmp(A, 'EyrT [s]')==1);
    if NumBandas == 6
        resEyrT = str2double(A(Ini,2:7)); % segundos
    else
        resEyrT = str2double(A(Ini,2:9)); % segundos
    end
    eval(sprintf('resEyrT_%s = resEyrT ;', NombreFuente));
    save(ParametrosAcusticos, strcat('resEyrT_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.74);
% RT Eyring utilizando AbsCg
if ~isempty(find(strcmp(A, 'EyrTg[s]')==1, 1))
    Ini = find(strcmp(A, 'EyrTg[s]')==1);
    if NumBandas == 6
        resEyrTg = str2double(A(Ini,2:7)); % segundos
    else
        resEyrTg = str2double(A(Ini,2:9)); % segundos
    end
    eval(sprintf('resEyrTg_%s = resEyrTg ;', NombreFuente));
    save(ParametrosAcusticos, strcat('resEyrTg_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.76);
% RT Sabine
if ~isempty(find(strcmp(A, 'SabT [s]')==1, 1))
    Ini = find(strcmp(A, 'SabT [s]')==1);
    if NumBandas == 6
        resSabT = str2double(A(Ini,2:7)); % segundos
    else
        resSabT = str2double(A(Ini,2:9)); % segundos
    end
    eval(sprintf('resSabT_%s = resSabT ;', NombreFuente));
    save(ParametrosAcusticos, strcat('resSabT_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.78);
% Coeficiente de aborcion medio basado en trazado de rayos
if ~isempty(find(strcmp(A, 'AbsC [%]')==1, 1))
    Ini = find(strcmp(A, 'AbsC [%]')==1);
    if NumBandas == 6
        resAbsC = str2double(A(Ini,2:7)); % En %
    else
        resAbsC = str2double(A(Ini,2:9)); % En %
    end
    eval(sprintf('resAbsC_%s = resAbsC ;', NombreFuente));
    save(ParametrosAcusticos, strcat('resAbsC_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.80);
% Coeficiente de absorcion medio
if ~isempty(find(strcmp(A, 'AbsCg[%]')==1, 1))
    Ini = find(strcmp(A, 'AbsCg[%]')==1);
    if NumBandas == 6
        resAbsCg = str2double(A(Ini,2:7)); % En %
    else
        resAbsCg = str2double(A(Ini,2:9)); % En %
    end
    eval(sprintf('resAbsCg_%s = resAbsCg ;', NombreFuente));
    save(ParametrosAcusticos, strcat('resAbsCg_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.82);
% Nivel de ruido de fondo
if ~isempty(find(strcmp(A, 'Back[dB]')==1, 1))
    Ini = find(strcmp(A, 'Back[dB]')==1);
    if NumBandas == 6
        resBackNoise = str2double(A(Ini,2:7)); % dB
    else
        resBackNoise = str2double(A(Ini,2:9)); % dB
    end
    eval(sprintf('resBackNoise_%s = resBackNoise ;', NombreFuente));
    save(ParametrosAcusticos, strcat('resBackNoise_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.84);
% RASTI
if ~isempty(find(strcmp(A, 'RASTI')==1, 1))
    Ini = find(strcmp(A, 'RASTI')==1)+2;
    Rasti = cellfun(@(var) cell2mat(textscan(var, '%f')),A(Ini:Ini+NumReceivers_00-1,2));
    RastiWithNoise = cellfun(@(var) cell2mat(textscan(var, '%f')),A(Ini:Ini+NumReceivers_00-1,3));
    eval(sprintf('Rasti_%s = Rasti ;', NombreFuente));
    save(ParametrosAcusticos, strcat('Rasti_',NombreFuente), '-append')
    eval(sprintf('RastiWithNoise_%s = RastiWithNoise ;', NombreFuente));
    save(ParametrosAcusticos, strcat('RastiWithNoise_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.86);
% STIuser
if or(~isempty(find(strcmp(A, 'STIuser')==1, 1)),~isempty(find(strcmp(A, 'STI Modified')==1, 1)))
    Ini = find(strcmp(A, 'STIuser')==1, 1);
    if isempty(Ini); Ini = find(strcmp(A, 'STI Modified')==1, 1); end
    Ini = Ini + 2;
    STIuser = cellfun(@(var) cell2mat(textscan(var, '%f')),A(Ini:Ini+NumReceivers_00-1,2));
    STIuserWithNoise = cellfun(@(var) cell2mat(textscan(var, '%f')),A(Ini:Ini+NumReceivers_00-1,3));
    eval(sprintf('STIuser_%s = STIuser ;', NombreFuente));
    save(ParametrosAcusticos, strcat('STIuser_',NombreFuente), '-append')
    eval(sprintf('STIuserWithNoise_%s = STIuserWithNoise ;', NombreFuente));
    save(ParametrosAcusticos, strcat('STIuserWithNoise_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.88);
% Tiempo Central - 125 Hz a 4 KHz-16KHz
if ~isempty(find(strcmp(A, 'Ts')==1, 1))
    Ini = find(strcmp(A, 'Ts')==1)+2;
    if NumBandas == 6
        Ts = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:7)); % milisegundos
    else
        Ts = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:9)); % milisegundos
    end
    eval(sprintf('Ts_%s = Ts ;', NombreFuente));
    save(ParametrosAcusticos, strcat('Ts_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.90);
% C-50 - 125 Hz a 4 KHz-16KHz
if ~isempty(find(strcmp(A, 'C-50 [dB]')==1, 1))
    Ini = find(strcmp(A, 'C-50 [dB]')==1)+2;
    if NumBandas == 6
        C50 = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:7)); % dB
    else
        C50 = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:9)); % dB
    end
    eval(sprintf('C50_%s = C50 ;', NombreFuente));
    save(ParametrosAcusticos, strcat('C50_',NombreFuente), '-append')
end

% D-50 - 125 Hz a 4 KHz-16KHz
if ~isempty(find(strcmp(A, 'D-50')==1, 1))
    Ini = find(strcmp(A, 'D-50')==1)+2;
    if NumBandas == 6
        D50 = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:7)); % En %
    else
        D50 = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:9)); % En %
    end
    eval(sprintf('D50_%s = D50 ;', NombreFuente));
    save(ParametrosAcusticos, strcat('D50_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.92);
% C-80 - 125 Hz a 4 KHz-16KHz
if ~isempty(find(strcmp(A, 'C-80 [dB]')==1, 1))
    Ini = find(strcmp(A, 'C-80 [dB]')==1)+2;
    if NumBandas == 6
        C80 = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:7)); % dB
    else
        C80 = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:9)); % dB
    end
    eval(sprintf('C80_%s = C80 ;', NombreFuente));
    save(ParametrosAcusticos, strcat('C80_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.94);
% LFC - 125 Hz a 4 KHz-16KHz
if ~isempty(find(strcmp(A, 'LFC')==1, 1))
    Ini = find(strcmp(A, 'LFC')==1)+2;
    if NumBandas == 6
        LFC = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:7)); % En %
    else
        LFC = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:9)); % En %
    end
    eval(sprintf('LFC_%s = LFC ;', NombreFuente));
    save(ParametrosAcusticos, strcat('LFC_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.96);
% LF - 125 Hz a 4 KHz-16KHz
if ~isempty(find(strcmp(A, 'LF')==1, 1))
    Ini = find(strcmp(A, 'LF')==1)+2;
    if NumBandas == 6
        LF = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:7)); % En %
    else
        LF = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:9)); % En %
    end
    eval(sprintf('LF_%s = LF ;', NombreFuente));
    save(ParametrosAcusticos, strcat('LF_',NombreFuente), '-append')
end

% Sonoridad G - 125 Hz a 4 KHz-16KHz
if ~isempty(find(strcmp(A, 'G')==1, 1))
    Ini = find(strcmp(A, 'G')==1)+2;
    if NumBandas == 6
        G = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:7)); % dB
    else
        G = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:9)); % dB
    end
    eval(sprintf('G_%s = G ;', NombreFuente));
    save(ParametrosAcusticos, strcat('G_',NombreFuente), '-append')
end

% SPL - 125 Hz a 4 KHz-16KHz
if ~isempty(find(strcmp(A, 'SPL')==1, 1))
    Ini = find(strcmp(A, 'SPL')==1)+2;
    if NumBandas == 6
        TotalSPL = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:7)); % dB
    else
        TotalSPL = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:9)); % dB
    end
    eval(sprintf('TotalSPL_%s = TotalSPL ;', NombreFuente));
    save(ParametrosAcusticos, strcat('TotalSPL_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,0.98);
% EDT - 125 Hz a 4 KHz-16KHz
if ~isempty(find(strcmp(A, 'EDT')==1, 1))
    Ini = find(strcmp(A, 'EDT')==1)+2;
    if NumBandas == 6
        EDT = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:7)); % segundos
    else
        EDT = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:9)); % segundos
    end
    eval(sprintf('EDT_%s = EDT ;', NombreFuente));
    save(ParametrosAcusticos, strcat('EDT_',NombreFuente), '-append')
end

% T-15 - 125 Hz a 4 KHz-16KHz
if ~isempty(find(strcmp(A, 'T-15')==1, 1))
    Ini = find(strcmp(A, 'T-15')==1)+2;
    if NumBandas == 6
        T15 = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:7)); % segundos
    else
        T15 = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:9)); % segundos
    end
    eval(sprintf('T15_%s = T15 ;', NombreFuente));
    save(ParametrosAcusticos, strcat('T15_',NombreFuente), '-append')
end

% T-30 - 125 Hz a 4 KHz-16KHz
if ~isempty(find(strcmp(A, 'T-30')==1, 1))
    Ini = find(strcmp(A, 'T-30')==1)+2;
    if NumBandas == 6
        T30 = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:7)); % segundos
    else
        T30 = cellfun(@str2double, A(Ini:Ini+NumReceivers_00-1,2:9)); % segundos
    end
    eval(sprintf('T30_%s = T30 ;', NombreFuente));
    save(ParametrosAcusticos, strcat('T30_',NombreFuente), '-append')
end
multiWaitbar(handles,handles.LGETPARAM,1);
%% (3) Funcion que inicializa variables para la funcion (2)
function [A,NombreFuente,ParametrosAcusticos,Receptores,Sala,Fuente]...
    = Inicializacion(Archivo,handles)
global CarpetaTempMat
Carpeta = CarpetaTempMat;
if isempty(dir(Carpeta)) % Si no existe la crea
    mkdir(Carpeta)
end
addpath(Carpeta)


% Realiza una copia del archivo a leer, corrige ciertas cadenas de caracteres y
% guarda en un nuevo archivo que al finalizar el script sera eliminado
Archivo = correccionesArchivo(Archivo);

multiWaitbar(handles,handles.LGETPARAM,0.1);

% Obtencion de los datos del archivo
A = CargarParamTXT(Archivo,1,lineasTXT(Archivo));
% Elimina los vacios
A(cellfun('isempty',A))={NaN};

multiWaitbar(handles,handles.LGETPARAM,0.3);

delete(Archivo) % Elimina el archivo temporal generado

% ID de la fuente
Nom = cell2mat(A(8,3));NombreFuente = Nom(1:2);

ParametrosAcusticos = strcat(Carpeta,filesep,'AcousticParameters_',NombreFuente,'.mat');
Receptores = strcat(Carpeta,filesep,'Receivers','.mat');
Sala = strcat(Carpeta,filesep,'Room','.mat');
Fuente = strcat(Carpeta,filesep,'Source_',NombreFuente,'.mat');

% Inicializacion de objetos .mat para guardar
Eliminar = 0; % Solo para generar el archivo .mat, se elimina en la lineas siguientes
save(ParametrosAcusticos,'Eliminar')
save(Receptores,'Eliminar')
save(Sala,'Eliminar')
save(Fuente,'Eliminar')
vars = rmfield(load(ParametrosAcusticos),'Eliminar');
save(ParametrosAcusticos,'-struct','vars');
vars = rmfield(load(Receptores),'Eliminar');
save(Receptores,'-struct','vars');
vars = rmfield(load(Sala),'Eliminar');
save(Sala,'-struct','vars');
vars = rmfield(load(Fuente),'Eliminar');
save(Fuente,'-struct','vars');

%% (4) Correcciones realizadas sobre un TXT temporal para la funcion (3)
function Archivo = correccionesArchivo(Archivo)

% Conversion de algunos caracteres para mejorar la identificacion de columnas
fid = fopen(Archivo,'rt') ;
Y = fread(fid) ;
fclose(fid) ;
Y = char(Y.') ;
% Cambios
Y = regexprep(Y,'\s\d',' $0'); % Aï¿½ade un espacio delante de todo numero
Y = regexprep(Y,'m]\s:\s\s\s\w\d','$0-9999');
Y = strrep(Y, ',', '.');
% Guardar en un archivo secundario para no modificar el original
fid2 = fopen(strcat(Archivo,'_temp'),'wt') ;
fwrite(fid2,Y) ;
fclose (fid2) ;
Archivo = strcat(Archivo,'_temp');

%% (5) Obtencion y promedio de los datos de I_ss_rr.TXT
function [SPLtemp,IDFuente,IDReceptor,ISM] =ObtencionISM(Archivo)

global CarpetaTempMat
if ~exist(CarpetaTempMat,'dir') % Si no existe la crea
    mkdir(CarpetaTempMat)
end
addpath(CarpetaTempMat)

ISM = strcat(CarpetaTempMat,filesep,'ISM.mat');
% Genera el archivo .mat si no existe
if ~exist(ISM,'file')
    Eliminar = 0; % Solo para generar el archivo .mat, se elimina en la lineas siguientes
    save(ISM,'Eliminar')
    vars = rmfield(load(ISM),'Eliminar');
    save(ISM,'-struct','vars');
end

A = CargarISMTXT(Archivo,26,inf);

% Obtencion de ID de la fuente y del receptor a traves del nombre de archivo
NombreArchivo = Archivo;
IDFuente = NombreArchivo(3:4);
IDReceptor = NombreArchivo(6:7);

% Extrae los datos necesarios y los ordena segun su tiempo de llegada
A = sortrows(A);
% Elimina columnas innecesarias
A(:,2:4)=[];

SPLtemp = A;

%% (6) Funcion necesaria para obtener el numero de lineas para las funciones (7) y (8)
function n = lineasTXT(X)

% Recibe la ruta o nombre de un archivo de texto
% Devuelve el numero de lineas que tiene un archivo de texto

fid = fopen(X);
n = 1;
tline = fgetl(fid);
while ischar(tline)
    tline = fgetl(fid);
    n = n+1;
end
fclose(fid);

%% (7) Funcion que importa el PARAM_ss.TXT a una matriz cell
function A = CargarParamTXT(archivo, inicio, final)
% Initialize variables.
delimiter = {'     ','   ','  '};
if nargin<=2
    inicio = 1;
    final = inf;
end
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

% Open the text file.
fileID = fopen(archivo,'r');

% Read columns of data according to the format.
textscan(fileID, '%[^\n\r]', inicio(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, final(1)-inicio(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(inicio)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', inicio(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, final(block)-inicio(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

% Close the text file.
fclose(fileID);

% Create output variable
A = [dataArray{1:end-1}];

%% (8) Funcion que importa el I_ss_rr.TXT a una matriz numerica
function ISMMat = CargarISMTXT(filename, startRow, endRow)

% Delimitador entre columnas
delimiter = '\t';

% Especificar el formato
formatSpec = '%*s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

% Abre el TXT
fileID = fopen(filename,'r');

% Leer las columnas segun el formato especificado
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'ReturnOnError', false, 'EndOfLine', '\r\n');

% Cierra TXT
fclose(fileID);

% Si la columna 11 esta vacia, es que no tiene 8 ni 16 KHZ, y tendrá 10 columnas
% si no esta vacia tendra 12 columnas
if isempty(dataArray{1,11}{1,1})
    maxCol = 10;
else
    maxCol = 12;
end
% Inicializa un cell con el tamaño de los datos
raw = repmat({''},length(dataArray{1}),maxCol);
% Copia el contenido de cada array a la matriz cell
for col=1:maxCol
    raw(1:length(dataArray{col}),col) = dataArray{col};
end

% Convierte los decimales con coma a decimales con punto y lo almacena como
% numero en una matriz double
ISMMat = str2double(strrep(raw,',','.'));
ISMMat = ISMMat(1:end-1,:); 


