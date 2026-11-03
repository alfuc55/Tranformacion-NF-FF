function ref = ref_patron(cfg, theta_vec, phi_vec)
    switch lower(cfg.antena.type)
        case 'dipolo'
            P = ref_patron_dipolo(cfg, theta_vec, phi_vec);
            name = 'dipolo (analitico)';
        case 'apertura'
            P = ref_patron_apertura(cfg, theta_vec, phi_vec);
            name = 'apertura (analitica)';
        case 'medicion'
            P = ref_patron_HFSS(cfg, theta_vec, phi_vec);
            name = 'medicion (HFSS)';
        otherwise
            error('Antena no reconocida: %s', cfg.antena.type);
    end
    ref.P = P / max(P(:));
    ref.name = name;
end