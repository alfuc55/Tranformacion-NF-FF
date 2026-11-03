function cfg = solicitar_malla_rectangular(cfg)
    opts = {'Lx, Ly, Nx, Ny  ->  dx, dy se calculan', ...
            'Lx, Ly, dx, dy  ->  Nx, Ny se calculan', ...
            'dx, dy, Nx, Ny  ->  Lx, Ly se calculan'};
    [ix, ok] = listdlg('PromptString','Como especificar la malla:', ...
        'SelectionMode','single','ListString',opts,'ListSize',[360 80]);
    if ~ok, error('Cancelado.'); end

    lam = cfg.lambda;
    Ld = cfg.plane.Lx/lam;  Nd = cfg.plane.Nx;
    Lyd= cfg.plane.Ly/lam;  Nyd= cfg.plane.Ny;
    dxd= Ld/Nd;             dyd= Lyd/Nyd;
    z0d= cfg.plane.z0/lam;

    switch ix
        case 1
            a = inputdlg({'Lx/lambda:','Ly/lambda:','Nx:','Ny:','z0/lambda:'}, ...
                'Malla (Lx,Ly,Nx,Ny)',1,{num2str(Ld,'%.4g'),num2str(Lyd,'%.4g'), ...
                num2str(Nd),num2str(Nyd),num2str(z0d,'%.4g')});
            if isempty(a), error('Cancelado.'); end
            cfg.plane.Lx=str2double(a{1})*lam;  cfg.plane.Ly=str2double(a{2})*lam;
            cfg.plane.Nx=max(4,round(str2double(a{3})));
            cfg.plane.Ny=max(4,round(str2double(a{4})));
            cfg.plane.z0=str2double(a{5})*lam;
        case 2
            a = inputdlg({'Lx/lambda:','Ly/lambda:','dx/lambda:','dy/lambda:','z0/lambda:'}, ...
                'Malla (Lx,Ly,dx,dy)',1,{num2str(Ld,'%.4g'),num2str(Lyd,'%.4g'), ...
                num2str(dxd,'%.4g'),num2str(dyd,'%.4g'),num2str(z0d,'%.4g')});
            if isempty(a), error('Cancelado.'); end
            Lx=str2double(a{1})*lam; Ly=str2double(a{2})*lam;
            dx=str2double(a{3})*lam;  dy=str2double(a{4})*lam;
            cfg.plane.z0=str2double(a{5})*lam;
            cfg.plane.Nx=max(4,round(Lx/dx));
            cfg.plane.Ny=max(4,round(Ly/dy));
            cfg.plane.Lx=cfg.plane.Nx*dx;
            cfg.plane.Ly=cfg.plane.Ny*dy;
        case 3
            a = inputdlg({'dx/lambda:','dy/lambda:','Nx:','Ny:','z0/lambda:'}, ...
                'Malla (dx,dy,Nx,Ny)',1,{num2str(dxd,'%.4g'),num2str(dyd,'%.4g'), ...
                num2str(Nd),num2str(Nyd),num2str(z0d,'%.4g')});
            if isempty(a), error('Cancelado.'); end
            dx=str2double(a{1})*lam; dy=str2double(a{2})*lam;
            cfg.plane.Nx=max(4,round(str2double(a{3})));
            cfg.plane.Ny=max(4,round(str2double(a{4})));
            cfg.plane.z0=str2double(a{5})*lam;
            cfg.plane.Lx=cfg.plane.Nx*dx;
            cfg.plane.Ly=cfg.plane.Ny*dy;
    end

    dx = cfg.plane.Lx/cfg.plane.Nx;
    dy = cfg.plane.Ly/cfg.plane.Ny;
    fprintf('\n[rect] Nx=%d, Ny=%d | Lx=%.2fλ, Ly=%.2fλ | dx=λ/%.1f, dy=λ/%.1f | z0=%.2fλ\n\n', ...
        cfg.plane.Nx, cfg.plane.Ny, cfg.plane.Lx/lam, cfg.plane.Ly/lam, ...
        lam/dx, lam/dy, cfg.plane.z0/lam);
end