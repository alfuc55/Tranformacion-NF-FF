function M = read_cplx_matrix(fname, nr, nc)
    if nargin < 2, nr = []; nc = []; end
    M = [];
    try
        M = readmatrix(fname);
        if ~isempty(M) && ~isreal(M)
            if isempty(nr) || isequal(size(M),[nr nc]), return; end
        end
    catch
        M = [];
    end
    fid = fopen(fname, 'r');
    if fid < 0, error('No se pudo abrir %s', fname); end
    content = fread(fid, '*char').';  fclose(fid);
    content = strrep(content, sprintf('\r\n'), sprintf('\n'));
    content = strtrim(content);
    lines = strsplit(content, sprintf('\n'));
    M = str2num(['[' strjoin(lines, '; ') ']']); %#ok<ST2NM>
    if ~isempty(nr)
        assert(isequal(size(M),[nr nc]), ...
            'Se esperaba %dx%d, se obtuvo %dx%d', nr, nc, size(M,1), size(M,2));
    end
end