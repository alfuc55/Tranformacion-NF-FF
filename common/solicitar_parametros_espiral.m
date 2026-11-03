function cfg = solicitar_parametros_espiral(cfg)
% SOLICITAR_PARAMETROS_ESPIRAL  Configura el escaneo espiral segun D'Agostino.
%
%   1. Auto-detecta geometria (a_geo, b_geo) que encierra la AUT
%   2. Pide al usuario z0 (validando contra z0_min del modelo)
%   3. Pide al usuario theta_max (cobertura angular, default 80)
%   4. Auto-calcula R_scan = z0 * tan(theta_max)
%   5. Auto-calcula Lx = Ly = 2 * R_scan
%   6. Auto-calcula N_osi = max(128, ceil(4 * R_scan / lambda))
%   7. Auto-calcula Nx = Ny = max(256, ceil(2 * N_osi))

    lam    = cfg.lambda;
    modelo = lower(cfg.espiral.modelo);

    % --- Geometria auto (igual que generar_espiral) ---
    switch lower(cfg.antena.type)
        case 'dipolo'
            a_geo = max(cfg.antena.l/2, lam/50);
            b_geo = a_geo/5;
        case 'apertura'
            a_geo = sqrt((cfg.antena.a_ap/2)^2 + (cfg.antena.b_ap/2)^2);
            b_geo = lam/2;
        case 'medicion'
            a_geo = 3*lam;
            b_geo = 0.2*a_geo;
    end

    % --- Restriccion z0 segun el paper ---
    if strcmpi(modelo, 'esferico')
        z0_min = a_geo;        % paper: z0 >= a (mitad del tamano max)
        z0_typ = 2 * a_geo;
        z0_note = 'z0 >= a (mitad tamano max)';
    else
        z0_min = b_geo;        % paper: z0 > b (fuera del elipsoide)
        z0_typ = 4 * b_geo;    % practica: 4b evita acople sonda-AUT
        z0_note = 'z0 > b (fuera del elipsoide)';
    end

    % --- Dialogo ---
    prompt = { ...
        sprintf(['Modelo: %s\n' ...
                 'Geometria AUT:  a=%.3f\\lambda,  b=%.3f\\lambda\n' ...
                 'Restriccion:   %s\n' ...
                 '                 z0_min = %.3f\\lambda\n\n' ...
                 'z0 / lambda:'], ...
                 modelo, a_geo/lam, b_geo/lam, z0_note, z0_min/lam), ...
        sprintf('theta_max (grados, 60-88):\n(default 80 cubre main beam + sidelobes)'), ...
        sprintf('N_osi (opcional, vacio=auto):\n(auto = max(128, 4*R_scan/lambda))') };

    ans_ = inputdlg(prompt, 'Escaneo espiral - Parametros', 1, ...
        { num2str(z0_typ/lam, '%.2f'), '80', '' });
    if isempty(ans_), error('Cancelado.'); end

    z0        = str2double(ans_{1}) * lam;
    theta_max = str2double(ans_{2});
    N_osi_str = strtrim(ans_{3});

    % --- Validaciones ---
    if isnan(z0) || isnan(theta_max)
        error('Valores no numericos.');
    end
    if z0 <= z0_min
        error(['z0 = %.3fλ <= z0_min = %.3fλ.\n' ...
               'El plano debe estar fuera del modelo %s.\n' ...
               'Prueba con z0 >= %.2fλ.'], ...
              z0/lam, z0_min/lam, modelo, 1.5*z0_min/lam);
    end
    if theta_max < 30 || theta_max > 88
        error('theta_max debe estar entre 30 y 88 grados.');
    end

    % Advertencia de acople sonda-AUT
    if z0 < 2*z0_min
        warning(['z0 = %.3fλ es solo %.1fx z0_min. ' ...
                 'Recomendado z0 >= 2*z0_min (o 4*z0_min para evitar acople).'], ...
                z0/lam, z0/z0_min);
    end

    % --- Auto-computar R_scan, Lx, N_osi ---
    R_scan = z0 * tand(theta_max);
    Lx     = 2 * R_scan;
    if isempty(N_osi_str)
        N_osi = max(128, ceil(4 * R_scan / lam));
    else
        N_osi = max(16, round(str2double(N_osi_str)));
    end
    Nx = max(256, ceil(2*N_osi));

    % --- Asignar a cfg ---
    cfg.plane.z0 = z0;
    cfg.plane.Lx = Lx;
    cfg.plane.Ly = Lx;
    cfg.plane.Nx = Nx;
    cfg.plane.Ny = Nx;
    cfg.espiral.R_scan = R_scan;
    cfg.espiral.N_osi  = N_osi;

    % Parametros del original corregido
    cfg.transform.n_theta = 4*181;
    cfg.transform.n_phi   = 4*360;
    cfg.transform.window  = 'tukey';
    cfg.transform.interp  = 'linear';

    % --- Reporte ---
    fprintf('\n');
    fprintf('=====================================================================\n');
    fprintf('   ESCANEO ESPIRAL - PARAMETROS (modelo %s)\n', upper(modelo));
    fprintf('=====================================================================\n');
    fprintf('   Geometria AUT : a = %.3f lambda,  b = %.3f lambda   (auto)\n', ...
            a_geo/lam, b_geo/lam);
    fprintf('   z0 min        : %.3f lambda   (%s)\n', z0_min/lam, z0_note);
    fprintf('   z0            : %.3f lambda\n', z0/lam);
    fprintf('   theta_max     : %.1f grados\n', theta_max);
    fprintf('   R_scan        : %.3f lambda   (= z0*tan(theta_max))\n', R_scan/lam);
    fprintf('   Lx = Ly       : %.3f lambda   (= 2*R_scan)\n', Lx/lam);
    fprintf('   N_osi         : %d   (pixel ~ %.3f lambda)\n', ...
            N_osi, 2*R_scan/N_osi/lam);
    fprintf('   Nx = Ny       : %d\n', Nx);
    fprintf('   Ventana/interp: tukey / linear\n');
    fprintf('=====================================================================\n\n');
end