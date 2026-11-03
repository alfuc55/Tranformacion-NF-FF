function ff = transform_planar_pws(nf, cfg)
    if contains(lower(cfg.transform.scan_type), 'espiral')
        ff = pws_espiral(nf, cfg);
    else
        ff = pws_rect(nf, cfg);
    end
end

function ff = pws_rect(nf, cfg)
    k = nf.k; dx = nf.dx; dy = nf.dy; z0 = nf.z0;
    Nx = size(nf.Ex,2); Ny = size(nf.Ex,1);
    [theta_vec, phi_vec, PHI_FF, THETA_FF] = ...
        build_angular_grid(cfg.transform.n_theta, cfg.transform.n_phi);

    switch lower(cfg.transform.window)
        case 'blackmanharris', win = @blackmanharris;
        case 'hann',           win = @hann;
        case 'hamming',        win = @hamming;
        case 'tukey',          win = @(n) tukeywin(n,1);
        case 'rect',           win = @rectwin;
        otherwise, error('Ventana no soportada: %s', cfg.transform.window);
    end
    W = win(Ny) * win(Nx)';

    Ex = nf.Ex .* W;  Ey = nf.Ey .* W;
    Nfft = Nx;
    Ex_k = fftshift(fft2(ifftshift(Ex), Nfft, Nfft)) * dx * dy;
    Ey_k = fftshift(fft2(ifftshift(Ey), Nfft, Nfft)) * dx * dy;

    kx = 2*pi*((0:Nfft-1)-floor(Nfft/2))/(Nfft*dx);
    ky = 2*pi*((0:Nfft-1)-floor(Nfft/2))/(Nfft*dy);
    [KX,KY] = meshgrid(kx,ky);
    KT = sqrt(KX.^2+KY.^2);

    filt = zeros(size(KT));
    ii = KT <= 0.95*k; it = KT > 0.95*k & KT <= k;
    filt(ii) = 1;
    filt(it) = 0.5*(1+cos(pi*(KT(it)-0.95*k)/(0.05*k)));
    Ex_k = Ex_k .* filt;  Ey_k = Ey_k .* filt;

    KX_q = k*sin(THETA_FF).*cos(PHI_FF);
    KY_q = k*sin(THETA_FF).*sin(PHI_FF);
    Ex_q = interp2(KX,KY,Ex_k,KX_q,KY_q,cfg.transform.interp,0);
    Ey_q = interp2(KX,KY,Ey_k,KX_q,KY_q,cfg.transform.interp,0);
    prop = exp(1j*k*cos(THETA_FF)*z0);
    Ex_q = Ex_q .* prop;  Ey_q = Ey_q .* prop;

    Etheta_ff =  Ex_q.*cos(PHI_FF) + Ey_q.*sin(PHI_FF);
    Ephi_ff   = (-Ex_q.*sin(PHI_FF) + Ey_q.*cos(PHI_FF)) .* cos(THETA_FF);
    P = abs(Etheta_ff).^2 + abs(Ephi_ff).^2;

    ff.theta_vec=theta_vec; ff.phi_vec=phi_vec;
    ff.Etheta_ff=Etheta_ff; ff.Ephi_ff=Ephi_ff;
    ff.P_ff_norm = P / max(P(:));
    ff.method_name = sprintf('planar PWS rect (%s)', cfg.transform.window);
end

function ff = pws_espiral(nf, cfg)
    k = nf.k; dx = nf.dx; dy = nf.dy; z0 = nf.z0;
    Nx = size(nf.Ex,2); Ny = size(nf.Ex,1);
    [theta_vec, phi_vec, PHI_FF, THETA_FF] = ...
        build_angular_grid(cfg.transform.n_theta, cfg.transform.n_phi);

    switch lower(cfg.transform.window)
        case 'tukey',          win = @(n) tukeywin(n,1);
        case 'blackmanharris', win = @blackmanharris;
        case 'hann',           win = @hann;
        case 'rect',           win = @rectwin;
        otherwise, error('Ventana no soportada: %s', cfg.transform.window);
    end
    W = win(Ny) * win(Nx)';

    Ex = nf.Ex .* W;  Ey = nf.Ey .* W;
    Nfft = Nx;
    Ex_k = fftshift(fft2(ifftshift(Ex), Nfft, Nfft)) * dx * dy;
    Ey_k = fftshift(fft2(ifftshift(Ey), Nfft, Nfft)) * dx * dy;

    kx = 2*pi*((0:Nfft-1)-floor(Nfft/2))/(Nfft*dx);
    ky = 2*pi*((0:Nfft-1)-floor(Nfft/2))/(Nfft*dy);
    [KX,KY] = meshgrid(kx,ky);
    KT2 = KX.^2 + KY.^2;

    KZ = sqrt(max(k^2-KT2,0));
    prop = exp(1j*KZ*z0);
    Ex_k = Ex_k .* prop;  Ey_k = Ey_k .* prop;

    propa = KT2 <= k^2;
    Ex_k(~propa) = 0;  Ey_k(~propa) = 0;

    KX_q = k*sin(THETA_FF).*cos(PHI_FF);
    KY_q = k*sin(THETA_FF).*sin(PHI_FF);
    Ex_q = interp2(KX,KY,Ex_k,KX_q,KY_q,'linear',0);
    Ey_q = interp2(KX,KY,Ey_k,KX_q,KY_q,'linear',0);

    Etheta_ff =  Ex_q.*cos(PHI_FF) + Ey_q.*sin(PHI_FF);
    Ephi_ff   = (-Ex_q.*sin(PHI_FF) + Ey_q.*cos(PHI_FF)) .* cos(THETA_FF);
    P = abs(Etheta_ff).^2 + abs(Ephi_ff).^2;

    ff.theta_vec=theta_vec; ff.phi_vec=phi_vec;
    ff.Etheta_ff=Etheta_ff; ff.Ephi_ff=Ephi_ff;
    ff.P_ff_norm = P / max(P(:));
    ff.method_name = 'planar PWS espiral (tukey)';
end