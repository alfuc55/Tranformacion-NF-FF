function nf = antena_medicion_HFSS(cfg)
    fEx   = resolve_data_file(cfg, cfg.files.Ex);
    fEy   = resolve_data_file(cfg, cfg.files.Ey);
    fEz   = resolve_data_file(cfg, cfg.files.Ez);
    fMesh = resolve_data_file(cfg, cfg.files.mesh_params);

    fprintf('  Leyendo:\n    %s\n    %s\n    %s\n    %s\n', fEx,fEy,fEz,fMesh);
    Ex = read_cplx_matrix(fEx);
    Ey = read_cplx_matrix(fEy);
    Ez = read_cplx_matrix(fEz);
    [Ny, Nx] = size(Ex);

    mp = readmatrix(fMesh);
    dx = mp(1); dy = mp(2); z0 = mp(3);
    fprintf('  mesh_params: dx=%.4e, dy=%.4e, z0=%.4e\n', dx, dy, z0);

    x = ((0:Nx-1)-floor(Nx/2))*dx;
    y = ((0:Ny-1)-floor(Ny/2))*dy;
    [X,Y] = meshgrid(x,y);

    nf.X=X; nf.Y=Y; nf.Ex=Ex; nf.Ey=Ey; nf.Ez=Ez;
    nf.dx=dx; nf.dy=dy; nf.z0=z0;
    nf.lambda=cfg.lambda; nf.k=cfg.k; nf.eta=cfg.eta; nf.name='medicion';
end