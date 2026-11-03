function nf = antena_dipolo(cfg)
    Lx=cfg.plane.Lx; Ly=cfg.plane.Ly; Nx=cfg.plane.Nx; Ny=cfg.plane.Ny;
    dx=Lx/Nx; dy=Ly/Ny; z0=cfg.plane.z0;
    k=cfg.k; eta=cfg.eta; I0=cfg.antena.I0; l=cfg.antena.l;

    x = ((0:Nx-1)-floor(Nx/2))*dx;
    y = ((0:Ny-1)-floor(Ny/2))*dy;
    [X,Y] = meshgrid(x,y);

    RHO = hypot(X,Y); R = sqrt(X.^2+Y.^2+z0^2);
    sin_t = RHO./R;  cos_t = z0./R;  PHI = atan2(Y,X);

    Er = eta*I0*l ./ (2*pi*R.^2) .* cos_t .* (1+1./(1j*k*R)) .* exp(-1j*k*R);
    Et = 1j*eta*k*I0*l ./ (4*pi*R) .* sin_t .* ...
         (1+1./(1j*k*R)-1./(k*R).^2) .* exp(-1j*k*R);
    Ep = zeros(size(R));

    cphi = zeros(size(RHO)); sphi = zeros(size(RHO));
    m = RHO>0;  cphi(m)=X(m)./RHO(m); sphi(m)=Y(m)./RHO(m);

    nf.Ex = Er.*sin_t.*cphi + Et.*cos_t.*cphi - Ep.*sphi;
    nf.Ey = Er.*sin_t.*sphi + Et.*cos_t.*sphi + Ep.*cphi;
    nf.Ez = Er.*cos_t - Et.*sin_t;

    nf.X=X; nf.Y=Y; nf.dx=dx; nf.dy=dy; nf.z0=z0;
    nf.lambda=cfg.lambda; nf.k=k; nf.eta=eta; nf.name='dipolo';
end