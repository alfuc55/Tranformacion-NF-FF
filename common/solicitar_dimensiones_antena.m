function cfg = solicitar_dimensiones_antena(cfg)
    if strcmpi(cfg.antena.type, 'medicion'), return; end
    lam = cfg.lambda;

    switch lower(cfg.antena.type)
        case 'dipolo'
            ans_ = inputdlg({'Longitud l / lambda:', 'Corriente I0 [A]:'}, ...
                'Dimensiones del dipolo', 1, ...
                { num2str(cfg.antena.l/lam,'%.4g'), num2str(cfg.antena.I0,'%.4g') });
            if isempty(ans_), error('Cancelado.'); end
            cfg.antena.l  = str2double(ans_{1}) * lam;
            cfg.antena.I0 = str2double(ans_{2});
            fprintf('  Dipolo: l=%.4fλ, I0=%.3g A\n', cfg.antena.l/lam, cfg.antena.I0);

        case 'apertura'
            ans_ = inputdlg({'Ancho a / lambda:', 'Alto b / lambda:'}, ...
                'Dimensiones de la apertura', 1, ...
                { num2str(cfg.antena.a_ap/lam,'%.4g'), num2str(cfg.antena.b_ap/lam,'%.4g') });
            if isempty(ans_), error('Cancelado.'); end
            cfg.antena.a_ap = str2double(ans_{1}) * lam;
            cfg.antena.b_ap = str2double(ans_{2}) * lam;
            fprintf('  Apertura: a=%.3fλ, b=%.3fλ\n', ...
                cfg.antena.a_ap/lam, cfg.antena.b_ap/lam);
    end
end