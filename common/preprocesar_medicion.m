function cfg = preprocesar_medicion(cfg)
% PREPROCESAR_MEDICION  Pide E_field.txt (si hace falta) y genera matrices.
    if ~isfield(cfg, 'data_dir') || isempty(cfg.data_dir)
        cfg.project_root = fileparts(which('main_NF_FF'));
        cfg.data_dir     = fullfile(cfg.project_root, 'data');
        if ~isfolder(cfg.data_dir), mkdir(cfg.data_dir); end
    end

    % Archivo existente en data_dir?
    cand = fullfile(cfg.data_dir, 'E_field.txt');
    E_file = '';

    if isfile(cand)
        choice = questdlg( ...
            sprintf('Se encontro E_field.txt en:\n%s\n\nQue deseas hacer?', cand), ...
            'Pre-procesamiento', 'Reprocesar', 'Usar matrices existentes', ...
            'Reprocesar');
        if isempty(choice), error('Cancelado.'); end
        if strcmp(choice, 'Reprocesar'), E_file = cand; end
    else
        [fn, fp] = uigetfile({'*.txt;*.fld', 'HFSS (*.txt, *.fld)'; '*.*', '*.*'}, ...
            'Selecciona E_field.txt exportado de HFSS', cfg.data_dir);
        if ~isequal(fn, 0), E_file = fullfile(fp, fn); end
    end

    if ~isempty(E_file)
        fprintf('\n=== PRE-PROCESAMIENTO: E_field.txt ===\n');
        procesar_E_field_HFSS(E_file, cfg.data_dir, cfg);
        fprintf('=== FIN PRE-PROCESAMIENTO ===\n\n');
    else
        fprintf('[medicion] Usando matrices existentes en data/\n\n');
    end
end