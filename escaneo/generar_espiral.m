function [pts, geom] = generar_espiral(cfg)
% GENERAR_ESPIRAL
%   Genera los puntos de la espiral no-redundante + toda la geometria
%   necesaria para OSI. Si la antena es dipolo/apertura, tambien calcula
%   el campo NF en cada punto. Para medicion, Exs/Eys/Ezs quedan vacios
%   (los llena HFSS en el .fld).

    a = cfg.espiral.a_geo;
    b = cfg.espiral.b_geo;
    if isempty(a)
        switch lower(cfg.antena.type)
            case 'dipolo',   a=max(cfg.antena.l/2, cfg.lambda/50); b=a/5;
            case 'apertura', a=sqrt((cfg.antena.a_ap/2)^2+(cfg.antena.b_ap/2)^2); b=cfg.lambda/2;
            case 'medicion', a=3*cfg.lambda; b=0.2*a;
        end
    end
    if isempty(b)
        switch lower(cfg.antena.type)
            case 'dipolo',   b=a/5;
            case 'apertura', b=cfg.lambda/2;
            case 'medicion', b=0.2*a;
        end
    end
    k  = cfg.k;
    z0 = cfg.plane.z0;
    R_scan = cfg.espiral.R_scan;
    chi_p  = cfg.espiral.chi_p;
    chi    = cfg.espiral.chi;
    modelo = lower(cfg.espiral.modelo);

    if strcmpi(modelo, 'esferico')
        N_p   = floor(chi_p*k*a)+1;
        N_pp  = floor(chi*N_p)+1;
        k_sp  = 1/(2*N_pp+1);
        phi_full = linspace(0,(2*N_pp+1)*pi,2e5);
        W = (k*a/pi)*trapz(phi_full, sqrt(k_sp^2+sin(k_sp*phi_full).^2));
        M_p = floor(chi_p*W)+1; M_pp = floor(chi*M_p)+1;
        Delta = 2*pi/(2*M_pp+1);

        phi_start = -2*pi;
        phi_max   = atan(R_scan/z0)/k_sp;
        phi_lkp   = linspace(phi_start, phi_max, 2e5);
        coord_lkp = cumtrapz(phi_lkp, sqrt(k_sp^2+sin(k_sp*phi_lkp).^2))*(k*a/W);

        cmin = coord_lkp(1); cmax = coord_lkp(end);
        M_max = floor((cmax-cmin)/Delta);
        coord_s = cmin + (0:M_max)*Delta;
        phi_s   = interp1(coord_lkp, phi_lkp, coord_s, 'linear','extrap');
        rho_s   = z0*tan(k_sp*phi_s);
    else
        ecc = sqrt(a^2-b^2)/a;
        [~, Ec] = ellipke(ecc^2);
        W = k*(4*a*Ec)/(2*pi);
        N_p = floor(chi_p*W)+1; N_pp = floor(chi*N_p)+1;
        k_sp = 1/(2*N_pp+1);
        M_p = floor(chi_p*W)+1; M_pp = floor(chi*M_p)+1;
        Delta = 2*pi/(2*M_pp+1);

        rho_lkp = linspace(0, R_scan, 2e5);
        [coord_lkp, ~] = ellipsoidal_params(rho_lkp, a, b, z0, k);
        phi_lkp = [];

        cmin = coord_lkp(1); cmax = coord_lkp(end);
        M_max = floor((cmax-cmin)/Delta);
        coord_s = cmin + (0:M_max)*Delta;
        rho_s = interp1(coord_lkp, rho_lkp, coord_s, 'linear','extrap');
        phi_s = coord_s / k_sp;
    end
    coord_bar = 6*Delta;

    % phase_samp DIRECTA (formula corregida)
    if strcmpi(modelo, 'esferico')
        R3D_s   = sqrt(rho_s.^2+z0^2);
        phase_s = k*(sqrt(max(R3D_s.^2-a^2,0)) - a.*acos(min(a./R3D_s,1)));
    else
        [~, phase_s] = ellipsoidal_params(rho_s, a, b, z0, k);
    end

    xs = rho_s .* cos(phi_s);
    ys = rho_s .* sin(phi_s);

    fprintf('  Espiral (%s): %d muestras, %.1f vueltas\n', ...
        modelo, numel(xs), (phi_s(end)-phi_s(1))/(2*pi));

    pts.xs = xs(:); pts.ys = ys(:);
    pts.Exs = []; pts.Eys = []; pts.Ezs = [];   % se llenan luego o via HFSS

    % Campo analitico si aplica
    if any(strcmpi(cfg.antena.type, {'dipolo','apertura'}))
        [pts.Exs, pts.Eys, pts.Ezs] = local_campo_analitico(cfg, xs(:), ys(:));
    end

    geom.a_geo = a; geom.b_geo = b;
    geom.k_sp = k_sp; geom.M_pp = M_pp; geom.M_p = M_p;
    geom.N_pp = N_pp; geom.N_p = N_p;
    geom.Delta = Delta;
    geom.coord_samp = coord_s; geom.coord_min = cmin; geom.coord_bar = coord_bar;
    geom.phase_samp = phase_s(:); geom.phi_samp = phi_s(:); geom.rho_samp = rho_s(:);
    geom.phi_lkp = phi_lkp; geom.coord_lkp = coord_lkp;
    geom.modelo = modelo;
end

function [Exs, Eys, Ezs] = local_campo_analitico(cfg, xs, ys)
    z0 = cfg.plane.z0; k = cfg.k; lambda = cfg.lambda; eta = cfg.eta;
    RHO = hypot(xs, ys);
    R   = sqrt(xs.^2 + ys.^2 + z0^2);
    st  = RHO./R;  ct = z0./R;  PHI = atan2(ys, xs);

    switch lower(cfg.antena.type)
        case 'dipolo'
            I0 = cfg.antena.I0; l = cfg.antena.l;
            Er = eta*I0*l ./ (2*pi*R.^2) .* ct .* (1+1./(1j*k*R)) .* exp(-1j*k*R);
            Et = 1j*eta*k*I0*l ./ (4*pi*R) .* st .* ...
                 (1+1./(1j*k*R)-1./(k*R).^2) .* exp(-1j*k*R);
            Ep = zeros(size(R));
        case 'apertura'
            a_ap=cfg.antena.a_ap; b_ap=cfg.antena.b_ap;
            bf = k/2;  k1 = k*st.*cos(PHI); k2 = k*st.*sin(PHI);
            sq = sqrt(2*pi*bf);
            u1=(2*bf*(-a_ap/2)-k1)/sq; u2=(2*bf*(a_ap/2)-k1)/sq;
            v1=(2*bf*(-b_ap/2)-k2)/sq; v2=(2*bf*(b_ap/2)-k2)/sq;
            Gu=fresnel_G(u2)-fresnel_G(u1); Gv=fresnel_G(v2)-fresnel_G(v1);
            p1=sqrt(pi/(2*bf)).*exp(1j*k1.^2/(4*bf));
            p2=sqrt(pi/(2*bf)).*exp(1j*k2.^2/(4*bf));
            pref = 1j*exp(-1j*k*R)./(2*lambda*R).*(1+ct);
            Et =  pref.*cos(PHI).*(p1.*Gu).*(p2.*Gv);
            Ep = -pref.*sin(PHI).*(p1.*Gu).*(p2.*Gv);
            Er = zeros(size(R));
    end
    cphi = zeros(size(RHO)); sphi = zeros(size(RHO));
    m = RHO>0; cphi(m)=xs(m)./RHO(m); sphi(m)=ys(m)./RHO(m);
    Exs = Er.*st.*cphi + Et.*ct.*cphi - Ep.*sphi;
    Eys = Er.*st.*sphi + Et.*ct.*sphi + Ep.*cphi;
    Ezs = Er.*ct - Et.*st;
end