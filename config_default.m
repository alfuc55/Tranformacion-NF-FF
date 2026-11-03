function cfg = config_default()
    % --- Fisica ---
    cfg.lambda = 0.125;
    cfg.k      = 2*pi/cfg.lambda;
    cfg.eta    = 376.730313668;

    % --- Antena dipolo ---
    cfg.antena.type = 'dipolo';
    cfg.antena.I0   = 1;
    cfg.antena.l    = cfg.lambda/150;

    % --- Antena apertura ---
    cfg.antena.a_ap = 2*cfg.lambda;
    cfg.antena.b_ap = 2*cfg.lambda;

    % --- Plano NF (default rectangular) ---
    cfg.plane.z0 = 3   * cfg.lambda;
    cfg.plane.Lx = 30  * cfg.lambda;
    cfg.plane.Ly = 30  * cfg.lambda;
    cfg.plane.Nx = 2048;
    cfg.plane.Ny = 2048;

    % --- Archivos (nombres relativos, resueltos contra data_dir) ---
    cfg.files.Ex             = 'Ex_matrix.txt';
    cfg.files.Ey             = 'Ey_matrix.txt';
    cfg.files.Ez             = 'Ez_matrix.txt';
    cfg.files.mesh_params    = 'mesh_params.txt';
    cfg.files.hfss_gain      = 'Gain Plot 1.csv';
    cfg.files.hfss_spiral    = 'E_field_spiral.fld';
    cfg.files.hfss_gain_spir = 'Gain Plot spiral.csv';
    cfg.files.spiral_points  = 'spiral_points_HFSS.txt';
    cfg.files.spiral_units   = 'mm';
    cfg.files.E_field        = 'E_field.txt';

    % --- Rutas (rellenadas por main_NF_FF) ---
    cfg.project_root = '';
    cfg.data_dir     = '';

    % --- Transformacion (defaults para rectangular) ---
    cfg.transform.scan_type = 'rectangular';
    cfg.transform.n_theta   = 3*181;
    cfg.transform.n_phi     = 4*360;
    cfg.transform.window    = 'blackmanharris';
    cfg.transform.interp    = 'makima';
    cfg.transform.method    = 'pws';
    cfg.transform.geometry  = 'planar';

    % --- Espiral (defaults del original corregido) ---
    cfg.espiral.modelo = 'esferico';   % 'esferico' | 'elipsoide'
    cfg.espiral.R_scan = 8.5*cfg.lambda;
    cfg.espiral.chi_p  = 1.20;
    cfg.espiral.chi    = 1.20;
    cfg.espiral.a_geo  = [];           % [] -> auto segun antena
    cfg.espiral.b_geo  = [];
    cfg.espiral.N_osi  = 128;
    cfg.espiral.p_osi  = 6;
    cfg.espiral.q_osi  = 6;

    % --- Metricas ---
    cfg.metrics.cuts_deg = [0 30 60 90];
end