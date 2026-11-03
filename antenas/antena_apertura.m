function nf = antena_apertura(cfg)
    Lx=cfg.plane.Lx; Ly=cfg.plane.Ly; Nx=cfg.plane.Nx; Ny=cfg.plane.Ny;
    dx=Lx/Nx; dy=Ly/Ny; z0=cfg.plane.z0;
    k=cfg.k; lambda=cfg.lambda; eta=cfg.eta;
    a_ap=cfg.antena.a_ap; b_ap=cfg.antena.b_ap;

    x = ((0:Nx-1)-floor(Nx/2))*dx;
    y = ((0:Ny-1)-floor(Ny/2))*dy;
    [X,Y] = meshgrid(x,y);
    RHO = hypot(X,Y); R = sqrt(X.^2+Y.^2+z0^2);
    sin_t = RHO./R;  cos_t = z0./R;  PHI = atan2(Y,X);

    beta = k/2;
    k1 = k*sin_t.*cos(PHI);  k2 = k*sin_t.*sin(PHI);
    sq = sqrt(2*pi*beta);
    u1=(2*beta*(-a_ap/2)-k1)/sq; u2=(2*beta*(a_ap/2)-k1)/sq;
    v1=(2*beta*(-b_ap/2)-k2)/sq; v2=(2*beta*(b_ap/2)-k2)/sq;
    Gu=fresnel_G(u2)-fresnel_G(u1); Gv=fresnel_G(v2)-fresnel_G(v1);
    p1=sqrt(pi/(2*beta)).*exp(1j*k1.^2/(4*beta));
    p2=sqrt(pi/(2*beta)).*exp(1j*k2.^2/(4*beta));
    pref = 1j*exp(-1j*k*R)./(2*lambda*R).*(1+cos_t);
    Et =  pref.*cos(PHI).*(p1.*Gu).*(p2.*Gv);
    Ep = -pref.*sin(PHI).*(p1.*Gu).*(p2.*Gv);
    Er = zeros(size(R));

    cphi = zeros(size(RHO)); sphi = zeros(size(RHO));
    m = RHO>0;  cphi(m)=X(m)./RHO(m); sphi(m)=Y(m)./RHO(m);
    nf.Ex = Er.*sin_t.*cphi + Et.*cos_t.*cphi - Ep.*sphi;
    nf.Ey = Er.*sin_t.*sphi + Et.*cos_t.*sphi + Ep.*cphi;
    nf.Ez = Er.*cos_t - Et.*sin_t;

    nf.X=X; nf.Y=Y; nf.dx=dx; nf.dy=dy; nf.z0=z0;
    nf.lambda=lambda; nf.k=k; nf.eta=eta; nf.name='apertura';
end