function [rho_s, phi_s, phase_s, k_sp, M_pp, M_p, N_pp, N_p, ...
          coord_s, cmin, cbar, a, b, phi_lkp, coord_lkp] = ...
    recomputar_geometria_espiral(cfg)
% RECOMPUTAR_GEOMETRIA_ESPIRAL
%   Replica EXACTAMENTE la geometria de NFtoFF_escaneo_Espiral_elipsoide.m
%   (version corregida).
%
%   15 salidas (antes eran 16 con phase_lkp; ahora phase_samp se calcula
%   DIRECTAMENTE dentro de esta funcion, no por lookup).

    % ---- Semiejes ----
    a = cfg.espiral.a_geo;
    b = cfg.espiral.b_geo;
    if isempty(a)
        switch lower(cfg.antena.type)
            case 'dipolo'
                a = max(cfg.antena.l/2, cfg.lambda/50);
                b = a/5;
            case 'apertura'
                a = sqrt((cfg.antena.a_ap/2)^2 + (cfg.antena.b_ap/2)^2);
                b = cfg.lambda/2;
            case 'medicion'
                a = 3*cfg.lambda;
                b = 0.2*a;
        end
    end
    if isempty(b)
        switch lower(cfg.antena.type)
            case 'dipolo',   b = a/5;
            case 'apertura', b = cfg.lambda/2;
            case 'medicion', b = 0.2*a;
        end
    end

    k      = cfg.k;
    z0     = cfg.plane.z0;
    R_scan = cfg.espiral.R_scan;
    chi_p  = cfg.espiral.chi_p;
    chi    = cfg.espiral.chi;

    % ============ PARAMETROS DE LA ESPIRAL ============
    if strcmpi(cfg.espiral.modelo, 'esferico')
        N_p   = floor(chi_p*k*a) + 1;
        N_pp  = floor(chi*N_p)   + 1;
        k_sp  = 1/(2*N_pp + 1);

        phi_full = linspace(0, (2*N_pp+1)*pi, 2e5);
        W = (k*a/pi) * trapz(phi_full, sqrt(k_sp^2 + sin(k_sp*phi_full).^2));

        M_p   = floor(chi_p*W) + 1;
        M_pp  = floor(chi*M_p) + 1;
        Delta = 2*pi/(2*M_pp + 1);

        % ---- Tablas de lookup para OSI 1 ----
        phi_start = -2*pi;
        phi_max   = atan(R_scan/z0)/k_sp;
        phi_lkp   = linspace(phi_start, phi_max, 2e5);
        coord_lkp = cumtrapz(phi_lkp, sqrt(k_sp^2 + sin(k_sp*phi_lkp).^2))*(k*a/W);

        cmin  = coord_lkp(1);
        cmax  = coord_lkp(end);
        M_max = floor((cmax - cmin)/Delta);

        coord_s = cmin + (0:M_max)*Delta;
        phi_s   = interp1(coord_lkp, phi_lkp, coord_s, 'linear', 'extrap');
        rho_s   = z0 * tan(k_sp * phi_s);

        % ---- phase_samp DIRECTA (formula corregida) ----
        R3D_s    = sqrt(rho_s.^2 + z0^2);
        phase_s  = k * ( sqrt(max(R3D_s.^2 - a^2, 0)) - a .* acos(min(a ./ R3D_s, 1)) );

        cbar = 6*Delta;

    else  % elipsoide
        ecc = sqrt(a^2 - b^2)/a;
        [~, Ec] = ellipke(ecc^2);
        W = k*(4*a*Ec)/(2*pi);

        N_p   = floor(chi_p*W) + 1;
        N_pp  = floor(chi*N_p) + 1;
        k_sp  = 1/(2*N_pp + 1);

        M_p   = floor(chi_p*W) + 1;
        M_pp  = floor(chi*M_p) + 1;
        Delta = 2*pi/(2*M_pp + 1);

        rho_lkp = linspace(0, R_scan, 2e5);
        [coord_lkp, ~] = ellipsoidal_params(rho_lkp, a, b, z0, k);
        phi_lkp = [];   % NO se usa en OSI 1 del modelo elipsoidal

        cmin  = coord_lkp(1);
        cmax  = coord_lkp(end);
        M_max = floor((cmax - cmin)/Delta);

        coord_s = cmin + (0:M_max)*Delta;
        rho_s   = interp1(coord_lkp, rho_lkp, coord_s, 'linear', 'extrap');
        phi_s   = coord_s / k_sp;

        % ---- phase_samp DIRECTA (formula corregida) ----
        [~, phase_s] = ellipsoidal_params(rho_s, a, b, z0, k);

        cbar = 6*Delta;
    end
end