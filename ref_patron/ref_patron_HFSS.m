function P = ref_patron_HFSS(cfg_or_fname, theta_vec, phi_vec)
    if isstruct(cfg_or_fname)
        cfg = cfg_or_fname;
        % Para espiral: usar hfss_gain_spir si existe; si no, hfss_gain
        relname = cfg.files.hfss_gain;
        if contains(lower(cfg.transform.scan_type),'espiral')
            if isfile(fullfile(cfg.data_dir, cfg.files.hfss_gain_spir))
                relname = cfg.files.hfss_gain_spir;
            end
        end
        fname = resolve_data_file(cfg, relname);
    else
        fname = cfg_or_fname;
        if ~isfile(fname)
            [fn, fp] = uigetfile({'*.csv','CSV (*.csv)'}, ...
                sprintf('No se encontro "%s". Seleccionalo:', fname));
            if isequal(fn,0), error('Sin far field HFSS: %s', fname); end
            fname = fullfile(fp, fn);
        end
    end

    M = readmatrix(fname);
    phi_u   = unique(M(:,1));
    theta_u = unique(M(:,2));
    gain_v  = M(:,3);
    n_p = numel(phi_u); n_t = numel(theta_u);
    assert(n_p*n_t == numel(gain_v), 'Grilla no rectangular (%dx%d != %d)', ...
        n_p, n_t, numel(gain_v));

    grid = reshape(gain_v, [n_p, n_t]).';   % theta lento, phi rapido
    [PHI_deg, THETA_deg] = meshgrid(phi_vec*180/pi, theta_vec*180/pi);
    P = interp2(phi_u, theta_u, grid, PHI_deg, THETA_deg, 'linear', 0);
end