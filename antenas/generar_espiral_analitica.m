function [xs, ys, Exs, Eys, Ezs] = generar_espiral_analitica(cfg)
% GENERAR_ESPIRAL_ANALITICA  Calcula el campo NF en los puntos de la espiral
% para una antena analitica (dipolo o apertura). Reusa la formula del plano NF
% pero evaluada solo en los puntos espirales.
    puntos = generar_espiral(cfg);
    xs = puntos(:,1); ys = puntos(:,2);
    z0 = cfg.plane.z0; k = cfg.k; lambda = cfg.lambda; eta = cfg.eta;
    RHO = hypot(xs, ys);  R = sqrt(xs.^2 + ys.^2 + z0^2);
    sin_t = RHO./R;  cos_t = z0./R;  PHI = atan2(ys, xs);

    switch lower(cfg.antena.type)
        case 'dipolo'
            I0 = cfg.antena.I0; l = cfg.antena.l;
            Er = eta*I0*l ./ (2*pi*R.^2) .* cos_t .* ...
                 (1 + 1./(1j*k*R)) .* exp(-1j*k*R);
            Et = 1j*eta*k*I0*l ./ (4*pi*R) .* sin_t .* ...
                 (1 + 1./(1j*k*R) - 1./(k*R).^2) .* exp(-1j*k*R);
            Ep = zeros(size(R));

        case 'apertura'
            a_ap = cfg.antena.a_ap; b_ap = cfg.antena.b_ap;
            beta = k/2;
            k1 = k*sin_t.*cos(PHI); k2 = k*sin_t.*sin(PHI);
            sq = sqrt(2*pi*beta);
            u1 = (2*beta*(-a_ap/2) - k1)/sq;  u2 = (2*beta*( a_ap/2) - k1)/sq;
            v1 = (2*beta*(-b_ap/2) - k2)/sq;  v2 = (2*beta*( b_ap/2) - k2)/sq;
            Gu = fresnel_G(u2) - fresnel_G(u1);
            Gv = fresnel_G(v2) - fresnel_G(v1);
            p1 = sqrt(pi/(2*beta)).*exp(1j*k1.^2/(4*beta));
            p2 = sqrt(pi/(2*beta)).*exp(1j*k2.^2/(4*beta));
            pref = 1j*exp(-1j*k*R)./(2*lambda*R).*(1+cos_t);
            Et =  pref.*cos(PHI).*(p1.*Gu).*(p2.*Gv);
            Ep = -pref.*sin(PHI).*(p1.*Gu).*(p2.*Gv);
            Er = zeros(size(R));
    end

    cphi = xs./RHO;  sphi = ys./RHO;
    cphi(RHO==0)=0; sphi(RHO==0)=0;
    Exs = Er.*sin_t.*cphi + Et.*cos_t.*cphi - Ep.*sphi;
    Eys = Er.*sin_t.*sphi + Et.*cos_t.*sphi + Ep.*cphi;
    Ezs = Er.*cos_t - Et.*sin_t;
end