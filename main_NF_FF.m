%% main_NF_FF.m  -  Punto de entrada interactivo
clear; clc; close all;
addpath(genpath(fileparts(mfilename('fullpath'))));

cfg = config_default();
cfg.project_root = fileparts(mfilename('fullpath'));
cfg.data_dir     = fullfile(cfg.project_root, 'data');
if ~isfolder(cfg.data_dir), mkdir(cfg.data_dir); end
fprintf('Proyecto: %s\n', cfg.project_root);
fprintf('Datos   : %s\n\n', cfg.data_dir);

%% 1. Antena
opts = {'dipolo (ideal)', 'apertura (ideal)', 'medicion (HFSS)'};
vals = {'dipolo', 'apertura', 'medicion'};
[ix, ok] = listdlg('PromptString', 'Selecciona la antena:', ...
    'SelectionMode', 'single', 'ListString', opts, 'ListSize', [280 90]);
if ~ok, fprintf('Cancelado.\n'); return; end
cfg.antena.type = vals{ix};

%% 2. Geometria
opts = {'planar (unica implementada)'};
[ix, ok] = listdlg('PromptString', 'Tipo de transformacion:', ...
    'SelectionMode', 'single', 'ListString', opts, 'ListSize', [320 60]);
if ~ok, fprintf('Cancelado.\n'); return; end
cfg.transform.geometry = 'planar';

%% 3. Escaneo
opts = {'Rectangular completo', ...
        'Espiral - modelo esferico (no redundante)', ...
        'Espiral - modelo elipsoidal (no redundante)'};
vals = {'rectangular', 'espiral_esferico', 'espiral_elipsoide'};
[ix, ok] = listdlg('PromptString', 'Tipo de escaneo:', ...
    'SelectionMode', 'single', 'ListString', opts, 'ListSize', [380 100]);
if ~ok, fprintf('Cancelado.\n'); return; end
cfg.transform.scan_type = vals{ix};

cfg.transform.method = 'pws';

%% 4. Dimensiones de la antena (dipolo / apertura)
cfg = solicitar_dimensiones_antena(cfg);

%% 5. Parametros segun caso
if strcmpi(cfg.transform.scan_type, 'rectangular')
    if strcmpi(cfg.antena.type, 'medicion')
        % Pre-procesar E_field.txt -> matrices
        cfg = preprocesar_medicion(cfg);
    else
        % Pedir malla al usuario
        cfg = solicitar_malla_rectangular(cfg);
    end
else
    % ---- Espiral ----
    cfg.espiral.modelo = 'esferico';
    if contains(cfg.transform.scan_type, 'elipso')
        cfg.espiral.modelo = 'elipsoide';
    end

    cfg = solicitar_parametros_espiral(cfg);
end
%% 6. Ejecutar
run_pipeline(cfg);