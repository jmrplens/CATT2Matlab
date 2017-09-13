%% Funcion que obtiene la ID de cada fuente a traves del nombre de cada variable
function Fuentes = ObtenerIDFuentes(Carpeta)
% Version 2017.1
% Autor: Jose Manuel Requena Plens
% Email: <a href="matlab:web('mailto:info@jmrplens.com')">info@jmrplens.com</a>
% Telegram: <a href="matlab:web('https://t.me/jmrplens')">@jmrplens</a>

Archivos=what(Carpeta);
ArchivosMat=strcat(Archivos(1).path,filesep,Archivos(1).mat);

ListaDeVariables = [];
for i=1:length(ArchivosMat)
ListaDeVariables = [ListaDeVariables;who('-file',ArchivosMat{i})]; %#ok<AGROW>
end
NumVariables = length(ListaDeVariables);
a = 1;
b=1;
IDs{a} = ListaDeVariables{a}(end-1:end);
Fuentes{b} = ListaDeVariables{a}(end-1:end);
for i=2:NumVariables
    
    if isempty(find(strcmp(IDs, ListaDeVariables{i}(end-1:end))==1, 1))
        a = a + 1;
        IDs{a} = ListaDeVariables{i}(end-1:end);
        % Si contiene una letra (solo las fuentes la tienen) la suma dara 1
        if sum(isstrprop(IDs{a}, 'alpha'))==1
            b = b +1;
            Fuentes{b} = IDs{a};
        end
        
    end
    
end