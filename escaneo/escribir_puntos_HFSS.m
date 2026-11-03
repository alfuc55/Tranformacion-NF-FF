function escribir_puntos_HFSS(fname, pts, geom, cfg) %#ok<INUSD>
    un = lower(cfg.files.spiral_units);
    switch un
        case 'mm', f = 1e3;
        case 'm',  f = 1;
        otherwise, error('Unidad no soportada: %s', un);
    end
    z0 = cfg.plane.z0;

    fid = fopen(fname, 'w');
    assert(fid>0, 'No se pudo crear %s', fname);
    fprintf(fid, '%% Puntos espirales para HFSS\n');
    fprintf(fid, '%% Modelo: %s | Antena: %s\n', cfg.espiral.modelo, cfg.antena.type);
    fprintf(fid, '%% z0 = %.6f m | Unidades: %s | Total: %d\n', z0, un, numel(pts.xs));
    fprintf(fid, 'x_%s,y_%s,z_%s\n', un, un, un);
    for i = 1:numel(pts.xs)
        fprintf(fid, '%.6f,%.6f,%.6f\n', pts.xs(i)*f, pts.ys(i)*f, z0*f);
    end
    fclose(fid);
    fprintf('  Escritos %d puntos en %s\n', numel(pts.xs), fname);
end