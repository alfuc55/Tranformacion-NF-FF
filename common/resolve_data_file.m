function fname = resolve_data_file(cfg, relpath, prompt_if_missing)
    if nargin < 3, prompt_if_missing = true; end

    candidates = {};
    if isfield(cfg,'data_dir') && ~isempty(cfg.data_dir)
        candidates{end+1} = fullfile(cfg.data_dir, relpath);
    end
    if isfield(cfg,'project_root') && ~isempty(cfg.project_root)
        candidates{end+1} = fullfile(cfg.project_root, relpath);
        candidates{end+1} = fullfile(cfg.project_root, 'data', relpath);
    end
    candidates{end+1} = fullfile(pwd, relpath);

    for k = 1:numel(candidates)
        if isfile(candidates{k}), fname = candidates{k}; return; end
    end

    if prompt_if_missing
        [fn, fp] = uigetfile({'*.*','Todos (*.*)'}, ...
            sprintf('No se encontro "%s". Seleccionalo:', relpath));
        if isequal(fn, 0)
            error('Archivo no encontrado: %s\nBusque en:\n  %s', ...
                relpath, strjoin(candidates, '\n  '));
        end
        fname = fullfile(fp, fn);
        return;
    end
    error('Archivo no encontrado: %s\nBusque en:\n  %s', ...
        relpath, strjoin(candidates, '\n  '));
end