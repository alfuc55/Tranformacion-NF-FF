function run_pipeline(cfg)
    t0 = tic;
    fprintf('\n=== PIPELINE NF-FF ===\n');
    fprintf('  Antena   : %s\n', cfg.antena.type);
    fprintf('  Geometria: %s\n', cfg.transform.geometry);
    fprintf('  Escaneo  : %s\n\n', cfg.transform.scan_type);
    % ==================== ETAPA 1: NF ====================
pts  = [];
    geom = [];
    if strcmpi(cfg.transform.scan_type, 'rectangular')
        nf = obtener_nf_rectangular(cfg);
    else
        % ---- Espiral ----
        [pts, geom] = generar_espiral(cfg);

        if strcmpi(cfg.antena.type, 'medicion')
            f_fld = fullfile(cfg.data_dir, cfg.files.hfss_spiral);
            if ~isfile(f_fld)
                escribir_puntos_HFSS( ...
                    fullfile(cfg.data_dir, cfg.files.spiral_points), pts, geom, cfg);
                fprintf('\n*** Puntos espirales escritos en:\n    %s ***\n', ...
                    fullfile(cfg.data_dir, cfg.files.spiral_points));
                fprintf('\nInstrucciones:\n');
                fprintf('  1) Importa ese archivo en HFSS.\n');
                fprintf('  2) Exporta E(x,y,z) complejo en esos puntos.\n');
                fprintf('  3) Guarda como: %s\n', f_fld);
                fprintf('  4) Re-ejecuta main_NF_FF.\n\n');
                return;
            end
            pts = leer_escaneo_espiral(cfg, pts, geom);
        end

        nf = osi_reconstruir_grid(cfg, pts, geom);
    end
    fprintf('[%5.2fs] NF listo: %dx%d\n', toc(t0), size(nf.Ex,1), size(nf.Ex,2));

    % ==================== ETAPA 2: FF ====================
    ff = transform_planar_pws(nf, cfg);
    fprintf('[%5.2fs] FF listo (%s)\n', toc(t0), ff.method_name);

    % ==================== ETAPA 3: Referencia ====================
    ref = ref_patron(cfg, ff.theta_vec, ff.phi_vec);
    fprintf('[%5.2fs] Referencia lista (%s)\n', toc(t0), ref.name);

    % ==================== ETAPA 4: Metricas ====================
    met = compute_metrics(ff, ref, cfg);
    fprintf('[%5.2fs] Metricas listas\n', toc(t0));

    % ==================== ETAPA 5: Figuras ====================
    plot_resultados(nf, ff, ref, met, cfg);
    if strcmpi(cfg.transform.scan_type, 'rectangular')
        plot_malla_rectangular(nf);
    else
        plot_malla_espiral(pts, geom, cfg);
    end    
    fprintf('[%5.2fs] Listo\n\n', toc(t0));
end

function nf = obtener_nf_rectangular(cfg)
    switch lower(cfg.antena.type)
        case 'dipolo',    nf = antena_dipolo(cfg);
        case 'apertura',  nf = antena_apertura(cfg);
        case 'medicion',  nf = antena_medicion_HFSS(cfg);
        otherwise, error('Antena no reconocida: %s', cfg.antena.type);
    end
end