function nf = osi_reconstruir_grid(cfg, pts, geom)
% OSI + reconstruccion al mallado rectangular.
    z0     = cfg.plane.z0;
    k      = cfg.k;
    lambda = cfg.lambda;
    eta    = cfg.eta;
    R_scan = cfg.espiral.R_scan;
    N_osi  = cfg.espiral.N_osi;
    p_osi  = cfg.espiral.p_osi;
    q_osi  = cfg.espiral.q_osi;
    modelo = geom.modelo;
    a_geo  = geom.a_geo;
    b_geo  = geom.b_geo;

    phi_samp   = geom.phi_samp;
    phase_samp = geom.phase_samp;
    k_sp       = geom.k_sp;
    M_pp       = geom.M_pp;  M_p = geom.M_p;
    N_pp       = geom.N_pp;  N_p = geom.N_p;
    Delta      = geom.Delta;
    coord_samp = geom.coord_samp;
    cmin       = geom.coord_min;
    cbar       = geom.coord_bar;
    phi_lkp    = geom.phi_lkp;
    coord_lkp  = geom.coord_lkp;

    phi_max_planar = atan(R_scan/z0)/k_sp;

    Vx_red = pts.Exs(:) .* exp( 1j*phase_samp(:));
    Vy_red = pts.Eys(:) .* exp( 1j*phase_samp(:));
    Vz_red = pts.Ezs(:) .* exp( 1j*phase_samp(:));

    % Malla OSI
    x_osi = linspace(-R_scan, R_scan, N_osi);
    y_osi = x_osi;
    [X_osi,Y_osi] = meshgrid(x_osi,y_osi);
    RHO_osi = hypot(X_osi,Y_osi);
    PHI_osi = atan2(Y_osi,X_osi);

    eta_bar = q_osi*(2*pi*k_sp);
    M_win = M_pp-M_p; if mod(M_win,2)==1, M_win=M_win+1; end
    N_win = N_pp-N_p; if mod(N_win,2)==1, N_win=N_win+1; end

    Ex_osi = zeros(N_osi);  Ey_osi = zeros(N_osi);  Ez_osi = zeros(N_osi);
    fprintf('  OSI (%dx%d, modelo=%s)...\n', N_osi, N_osi, modelo);
    t_osi = tic;

    for i = 1:N_osi
        if mod(i,32)==0, fprintf('    fila %3d/%3d  (%.1fs)\n', i, N_osi, toc(t_osi)); end
        for j = 1:N_osi
            rho_t = RHO_osi(i,j);
            if rho_t > R_scan || rho_t < 1e-9, continue; end
            phi_t   = PHI_osi(i,j);
            theta_t = atan(rho_t/z0);

            if strcmpi(modelo, 'esferico')
                coord_t_Q = theta_t;
                R3D_t     = sqrt(rho_t^2+z0^2);
                phase_t_Q = k*(sqrt(max(R3D_t^2-a_geo^2,0)) - a_geo*acos(min(a_geo/R3D_t,1)));
            else
                [coord_t_Q, phase_t_Q] = ellipsoidal_params(rho_t, a_geo, b_geo, z0, k);
            end

            n_c   = round((theta_t - k_sp*phi_t)/(2*pi*k_sp));
            n_rng = (n_c-q_osi):(n_c+q_osi);
            phi_n = phi_t + 2*pi*n_rng;
            vld   = (phi_n >= phi_samp(1)) & (phi_n <= phi_max_planar);

            Vx_i = zeros(1,numel(n_rng));
            Vy_i = zeros(1,numel(n_rng));
            Vz_i = zeros(1,numel(n_rng));

            for nn = 1:numel(n_rng)
                if ~vld(nn), continue; end
                if strcmpi(modelo, 'esferico')
                    coord_t = interp1(phi_lkp, coord_lkp, phi_n(nn), 'linear','extrap');
                else
                    coord_t = k_sp*phi_n(nn);
                end
                m0    = floor((coord_t - cmin)/Delta)+1;
                m_win = (m0-p_osi):(m0+p_osi);
                m_win = m_win(m_win>=1 & m_win<=numel(coord_samp));
                if isempty(m_win), continue; end
                dxw = (coord_t - coord_samp(m_win)).';
                Om  = tschebyscheff_window(dxw, M_win, cbar);
                Dr  = dirichlet_kernel(dxw, M_pp);
                ker = Om .* Dr;
                Vx_w = Vx_red(m_win); Vx_w = Vx_w(:);
                Vy_w = Vy_red(m_win); Vy_w = Vy_w(:);
                Vz_w = Vz_red(m_win); Vz_w = Vz_w(:);
                Vx_i(nn) = sum(Vx_w .* ker);
                Vy_i(nn) = sum(Vy_w .* ker);
                Vz_i(nn) = sum(Vz_w .* ker);
            end

            eta_n   = k_sp*phi_n;
            d_coord = coord_t_Q - eta_n;
            Om_e = tschebyscheff_window(d_coord, N_win, eta_bar);
            Dr_e = dirichlet_kernel(d_coord, N_p);
            wts  = Om_e .* Dr_e .* vld;

            Ex_osi(i,j) = sum(Vx_i .* wts) * exp(-1j*phase_t_Q);
            Ey_osi(i,j) = sum(Vy_i .* wts) * exp(-1j*phase_t_Q);
            Ez_osi(i,j) = sum(Vz_i .* wts) * exp(-1j*phase_t_Q);
        end
    end
    fprintf('  OSI terminado en %.1fs\n', toc(t_osi));

    % Upsampling
    Lx=cfg.plane.Lx; Ly=cfg.plane.Ly; Nx=cfg.plane.Nx; Ny=cfg.plane.Ny;
    dx=Lx/Nx; dy=Ly/Ny;
    x = ((0:Nx-1)-floor(Nx/2))*dx;
    y = ((0:Ny-1)-floor(Ny/2))*dy;
    [X,Y] = meshgrid(x,y);

    Ex = interp2(x_osi,y_osi,Ex_osi,X,Y,'spline',0);
    Ey = interp2(x_osi,y_osi,Ey_osi,X,Y,'spline',0);
    Ez = interp2(x_osi,y_osi,Ez_osi,X,Y,'spline',0);

    nf.X=X; nf.Y=Y; nf.Ex=Ex; nf.Ey=Ey; nf.Ez=Ez;
    nf.dx=dx; nf.dy=dy; nf.z0=z0;
    nf.lambda=lambda; nf.k=k; nf.eta=eta; nf.name='espiral_reconstruido';
end