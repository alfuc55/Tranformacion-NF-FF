function [nf, info] = procesar_E_field_HFSS(in_file, out_dir, cfg)
% Procesa un .fld de HFSS -> Ex_matrix.txt, Ey_matrix.txt, Ez_matrix.txt,
% mesh_params.txt en out_dir. Devuelve nf listo.
    if ~isfile(in_file), error('No existe: %s', in_file); end
    if ~isfolder(out_dir), mkdir(out_dir); end

    fid = fopen(in_file, 'r');
    grid_header = '';
    while true
        line = fgetl(fid);
        if ~ischar(line), fclose(fid); error('No "Grid Output" en %s', in_file); end
        if contains(line,'Grid Output','IgnoreCase',true), grid_header=line; break; end
    end
    fgetl(fid);  % header de columnas
    C = textscan(fid, '%f %f %f %f %f %f %f %f %f');
    fclose(fid);

    x = C{1}; y = C{2};
    Ex = complex(C{4},C{5}); Ey = complex(C{6},C{7}); Ez = complex(C{8},C{9});
    N = numel(x);

    info = local_parse_header(grid_header);
    fprintf('  Grid HFSS: %s\n', grid_header);
    fprintf('    x:[%.2e,%.2e] dx=%.2e | y:[%.2e,%.2e] dy=%.2e | z0=%.2e\n', ...
        info.x_min,info.x_max,info.dx, info.y_min,info.y_max,info.dy, info.z_min);

    tol=1e-6; xu=uniquetol(x,tol); yu=uniquetol(y,tol);
    Nx=numel(xu); Ny=numel(yu);
    assert(Nx*Ny==N, 'Malla no rectangular N=%d vs %d', N, Nx*Ny);
    dx=xu(2)-xu(1); dy=yu(2)-yu(1); z0=info.z_min;

    ix = round((x-xu(1))/dx)+1;
    iy = round((y-yu(1))/dy)+1;
    lin = (ix-1)*Ny+iy;
    Ex_m=complex(zeros(Ny,Nx)); Ey_m=complex(zeros(Ny,Nx)); Ez_m=complex(zeros(Ny,Nx));
    Ex_m(lin)=Ex; Ey_m(lin)=Ey; Ez_m(lin)=Ez;

    fEx   = fullfile(out_dir,'Ex_matrix.txt');
    fEy   = fullfile(out_dir,'Ey_matrix.txt');
    fEz   = fullfile(out_dir,'Ez_matrix.txt');
    fMesh = fullfile(out_dir,'mesh_params.txt');

    local_write(fEx, Ex_m); local_write(fEy, Ey_m); local_write(fEz, Ez_m);
    fid = fopen(fMesh,'w'); fprintf(fid,'%.12e\n%.12e\n%.12e\n',dx,dy,z0); fclose(fid);

    fprintf('    Escrito: %s (%dx%d)\n', fEx, Ny, Nx);
    fprintf('    Escrito: %s\n', fMesh);

    xg = ((0:Nx-1)-floor(Nx/2))*dx;  yg = ((0:Ny-1)-floor(Ny/2))*dy;
    [Xg,Yg] = meshgrid(xg,yg);
    nf.X=Xg; nf.Y=Yg; nf.Ex=Ex_m; nf.Ey=Ey_m; nf.Ez=Ez_m;
    nf.dx=dx; nf.dy=dy; nf.z0=z0;
    nf.lambda = cfg.lambda; nf.k = 2*pi/cfg.lambda; nf.eta = 376.730313668;
    nf.name = 'medicion';
end

function info = local_parse_header(h)
    m1=regexp(h,'Min:\s*\[([^\]]+)\]','tokens','once');
    m2=regexp(h,'Max:\s*\[([^\]]+)\]','tokens','once');
    m3=regexp(h,'Grid Size:\s*\[([^\]]+)\]','tokens','once');
    if isempty(m1)||isempty(m2)||isempty(m3)
        error('No Min/Max/Grid Size en: %s', h);
    end
    [v1,u1]=local_pb(m1{1}); [v2,u2]=local_pb(m2{1}); [v3,u3]=local_pb(m3{1});
    uu=[u1 u2 u3]; ne=uu(~cellfun(@isempty,uu));
    unit = 'm'; if ~isempty(ne), unit=ne{1}; end
    f = local_um(unit);
    info.x_min=v1(1)*f; info.x_max=v2(1)*f; info.dx=v3(1)*f;
    info.y_min=v1(2)*f; info.y_max=v2(2)*f; info.dy=v3(2)*f;
    info.z_min=v1(3)*f; info.z_max=v2(3)*f; info.dz=v3(3)*f;
end
function [vals,units]=local_pb(s)
    t=regexp(s,'([-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?)\s*([a-zA-Zμµ]*)','tokens');
    vals=zeros(1,numel(t)); units=cell(1,numel(t));
    for i=1:numel(t), vals(i)=str2double(t{i}{1}); units{i}=t{i}{2}; end
end
function f=local_um(u)
    switch lower(strtrim(u))
        case {'m',''},f=1; case 'cm',f=1e-2; case 'mm',f=1e-3;
        case {'um','μm','µm'},f=1e-6; case 'nm',f=1e-9;
        case 'in',f=0.0254; case 'mil',f=25.4e-6; otherwise, f=1;
    end
end
function local_write(fname,M)
    [nr,nc]=size(M);
    fe='%.12e%+.12ei';
    if nc>1, fr=[repmat([fe ' '],1,nc-1) fe '\n']; else, fr=[fe '\n']; end
    fid=fopen(fname,'w'); assert(fid>0,'No se pudo crear %s',fname);
    args=zeros(1,2*nc);
    for i=1:nr
        args(1:2:end)=real(M(i,:)); args(2:2:end)=imag(M(i,:));
        fprintf(fid,fr,args);
    end
    fclose(fid);
end