function plot_malla_espiral(pts, geom, cfg)
% PLOT_MALLA_ESPIRAL  Vista esquematica del plano de medicion con malla espiral.
%
%   Similar a plot_malla_rectangular, pero para el escaneo espiral.
%   Muestra: AUT, espiral (color por vuelta), scan zone, FFT grid,
%   circulos lambda/2 y lambda, caja de parametros.

    lam    = cfg.lambda;
    z0     = cfg.plane.z0;
    Lx     = cfg.plane.Lx;
    Ly     = cfg.plane.Ly;
    R_scan = cfg.espiral.R_scan;
    a_geo  = geom.a_geo;
    b_geo  = geom.b_geo;

    xs = pts.xs(:);
    ys = pts.ys(:);

    % Numero de vuelta acumulado (para colorear)
    phi_u    = unwrap(atan2(ys, xs));
    n_vuelta = (phi_u - phi_u(1)) / (2*pi);

    % --- Figura ---
    fig = figure('Name', 'Vista de la malla espiral', 'Color', 'w');
    ax  = axes(fig); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
    axis(ax, 'equal');

    th = linspace(0, 2*pi, 400);

    % --- 1) AUT (elipse a_geo x b_geo) ---
    plot(ax, a_geo*cos(th), b_geo*sin(th), 'k-', 'LineWidth', 2.5);

    % --- 2) Circulos lambda/2 y lambda ---
    plot(ax, lam/2*cos(th), lam/2*sin(th), 'r--', 'LineWidth', 1.2);
    plot(ax, lam  *cos(th), lam  *sin(th), 'r:',  'LineWidth', 1.0);

    % --- 3) Espiral (color por vuelta) ---
    scatter(ax, xs, ys, 18, n_vuelta, 'filled');

    % Inicio y fin
    plot(ax, xs(1), ys(1), 'go', 'MarkerSize', 13, 'MarkerFaceColor', 'g', ...
         'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    plot(ax, xs(end), ys(end), 'rs', 'MarkerSize', 12, 'MarkerFaceColor', 'r', ...
         'MarkerEdgeColor', 'k', 'LineWidth', 1.0);

    % --- 4) Borde del scan zone ---
    plot(ax, R_scan*cos(th), R_scan*sin(th), 'b-', 'LineWidth', 2);

    % --- 5) Borde del FFT grid ---
    rectangle(ax, 'Position', [-Lx/2, -Ly/2, Lx, Ly], ...
              'EdgeColor', [0.20 0.45 0.85], 'LineWidth', 1.5, 'LineStyle', '--');

    % --- 6) Caja de parametros ---
    lim = max([R_scan, Lx/2]) * 1.18;
    xlim(ax, [-lim, lim]); ylim(ax, [-lim, lim]);

    info = sprintf([ ...
        'Modelo: %s\n' ...
        'a = %.3f\\lambda,  b = %.3f\\lambda\n' ...
        'z_0 = %.3f\\lambda\n' ...
        'R_{scan} = %.3f\\lambda\n' ...
        'L_x = L_y = %.3f\\lambda\n' ...
        'N_{espiral} = %d muestras\n' ...
        'Vueltas = %.1f'], ...
        cfg.espiral.modelo, a_geo/lam, b_geo/lam, z0/lam, R_scan/lam, ...
        Lx/lam, numel(xs), n_vuelta(end));

    text(ax, -lim*0.95, lim*0.95, info, ...
         'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', ...
         'BackgroundColor', 'w', 'EdgeColor', 'k', 'FontSize', 9, ...
         'Interpreter', 'tex');

    xlabel(ax, 'x / \lambda'); ylabel(ax, 'y / \lambda');
    title(ax, sprintf('Escaneo espiral (%s) - %d muestras, %.1f vueltas', ...
                      cfg.espiral.modelo, numel(xs), n_vuelta(end)));

    % --- 7) Leyenda ---
    h1 = plot(ax, nan, nan, 'k-', 'LineWidth', 2.5);
    h2 = plot(ax, nan, nan, 'r--', 'LineWidth', 1.2);
    h3 = plot(ax, nan, nan, 'r:',  'LineWidth', 1.0);
    h4 = plot(ax, nan, nan, 'b-',  'LineWidth', 2);
    h5 = plot(ax, nan, nan, '--',  'Color', [0.20 0.45 0.85], 'LineWidth', 1.5);
    h6 = plot(ax, nan, nan, 'go',  'MarkerSize', 10, 'MarkerFaceColor', 'g');
    h7 = plot(ax, nan, nan, 'rs',  'MarkerSize', 9,  'MarkerFaceColor', 'r');

    legend(ax, [h1 h2 h3 h4 h5 h6 h7], ...
        {'AUT', 'Radio \lambda/2', 'Radio \lambda', ...
         'Scan zone (R_{scan})', 'FFT grid (L_x \times L_y)', ...
         'Inicio', 'Fin'}, ...
        'Location', 'southoutside', 'Orientation', 'horizontal', 'NumColumns', 4);

    colormap(ax, parula);
    cb = colorbar(ax);
    cb.Label.String = 'Numero de vuelta';

    hold(ax, 'off');
end