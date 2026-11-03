function P = ref_patron_dipolo(cfg, theta_vec, phi_vec)
    [~, THETA] = meshgrid(phi_vec, theta_vec);
    R = 256*cfg.lambda; k = cfg.k; eta = cfg.eta;
    I0 = cfg.antena.I0; l = cfg.antena.l;
    E = 1j*eta*k*I0*l ./ (4*pi*R) .* sin(THETA) .* ...
        (1 + 1./(1j*k*R) - 1./(k*R).^2) .* exp(-1j*k*R);
    P = abs(E).^2;
end