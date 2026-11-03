function pts = leer_escaneo_espiral(cfg, pts, geom) %#ok<INUSD>
% Lee el .fld de HFSS con muestras complejas sobre los puntos de la espiral.
% Asume mismo orden que el .txt exportado.
    fname = fullfile(cfg.data_dir, cfg.files.hfss_spiral);
    fid = fopen(fname, 'r');
    assert(fid>0, 'No se pudo abrir %s', fname);

    % Saltar lineas no numericas
    while true
        ln = fgetl(fid);
        if ~ischar(ln), error('EOF antes de datos en %s', fname); end
        ln = strtrim(ln);
        if isempty(ln) || ln(1)=='%' || ln(1)=='#', continue; end
        % Si empieza con letra, es header
        if isletter(ln(1)), continue; end
        fseek(fid, -length(ln)-2, 'cof');  % reposicionar
        break;
    end
    C = textscan(fid, '%f %f %f %f %f %f %f %f %f');
    fclose(fid);

    Exs = complex(C{4}, C{5});
    Eys = complex(C{6}, C{7});
    Ezs = complex(C{8}, C{9});

    if numel(Exs) ~= numel(pts.xs)
        error('Puntos no coinciden: txt=%d, fld=%d', numel(pts.xs), numel(Exs));
    end
    pts.Exs = Exs; pts.Eys = Eys; pts.Ezs = Ezs;
    fprintf('  Leidos %d campos desde %s\n', numel(Exs), fname);
end