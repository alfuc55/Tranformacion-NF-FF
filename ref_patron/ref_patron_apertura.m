function P = ref_patron_apertura(cfg, theta_vec, phi_vec)
    [PHI, THETA] = meshgrid(phi_vec, theta_vec);
    uu = cfg.antena.a_ap * sin(THETA).*cos(PHI) / cfg.lambda;
    vv = cfg.antena.b_ap * sin(THETA).*sin(PHI) / cfg.lambda;
    obl = (1+cos(THETA))/2;
    Eth =  sinc(uu).*sinc(vv).*obl.*cos(PHI);
    Eph = -sinc(uu).*sinc(vv).*obl.*sin(PHI);
    P = abs(Eth).^2 + abs(Eph).^2;
end