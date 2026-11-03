function [xs, ys, Exs, Eys, Ezs] = leer_escaneo_espiral(cfg)
% LEER_ESCANEO_ESPIRAL  Lee el .fld de HFSS con muestras complejas
% en los puntos de la espiral.
%
%   Formato esperado (9 columnas):
%       x  y  z  Ex_r  Ex_i  Ey_r  Ey_i  Ez_r  Ez_i
%   Se ignoran lineas que no empiezan con numero (comentarios, cabeceras).
    fname = cfg.files.hfss_spiral;
    fid = fopen(fname, 'r');
    assert(fid > 0, 'No se pudo abrir %s', fname);

    % Saltar lineas no numericas
    while true
        ln = fgetl(fid);
        if ~ischar(ln), error('EOF antes de datos en %s', fname); end
        ln = strtrim(ln);
        if isempty(ln) || ln(1)=='%' || ln(1)=='#', continue; end
        if any(isletter(ln(1:min(end,3)))), continue; end  % header
        frewind_pos = ftell(fid);
        % Reposicionar para releer esta linea
        fseek(fid, frewind_pos - length(ln) - 2, 'bof');
        break;
    end

    C = textscan(fid, '%f %f %f %f %f %f %f %f %f');
    fclose(fid);

    xs  = C{1};  ys = C{2};
    Exs = complex(C{4}, C{5});
    Eys = complex(C{6}, C{7});
    Ezs = complex(C{8}, C{9});

    fprintf('  Leidos %d puntos espirales desde %s\n', numel(xs), fname);
end