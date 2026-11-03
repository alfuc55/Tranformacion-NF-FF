function plot_malla_rectangular(nf)
% PLOT_MALLA_RECTANGULAR  Vista esquematica de la malla rectangular.
%
%   Muestra: borde del extent, lineas de grilla (submuestreadas si son
%   demasiadas), circulos de referencia lambda/2 y lambda, y un cuadro con
%   todos los parametros de la malla.

    X = nf.X; Y = nf.Y;
    lambda = nf.lambda;
    z0     = nf.z0;
    dx = nf.dx;  dy = nf.dy;
    [Ny, Nx] = size(X);

    Lx = Nx * dx;
    Ly = Ny * dy;

    x_lim = [min(X(:)) - dx/2, max(X(:)) + dx/2];
    y_lim = [min(Y(:)) - dy/2, max(Y(:)) + dy/2];
    pad_x = 0.10 * diff(x_lim);
    pad_y = 0.10 * diff(y_lim);

    fig = figure('Name', 'Vista de la malla rectangular', 'Color', 'w');
    ax  = axes(fig);
    hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on'); axis(ax, 'equal');

    % --- 1) Borde de la malla ---
    rectangle(ax, 'Position', [x_lim(1), y_lim(1), diff(x_lim), diff(y_lim)], ...
        'EdgeColor', [0.00 0.30 0.70], 'LineWidth', 2);

    % --- 2) Lineas de grilla (submuestreadas) ---
    max_lines = 40;
    if Nx <= max_lines, x_lines = X(1,:);
    else,               x_lines = X(1, 1:ceil(Nx/max_lines):end);
    end
    if Ny <= max_lines, y_lines = Y(:,1);
    else,               y_lines = Y(1:ceil(Ny/max_lines):end, 1);
    end
    for xv = unique(x_lines)
        plot(ax, [xv xv], [y_lim(1) y_lim(2)], '-', ...
            'Color', [0.78 0.78 0.78], 'LineWidth', 0.5);
    end
    for yv = unique(y_lines)
        plot(ax, [x_lim(1) x_lim(2)], [yv yv], '-', ...
            'Color', [0.78 0.78 0.78], 'LineWidth', 0.5);
    end

    % --- 3) Referencia: circulos lambda/2 y lambda ---
    th = linspace(0, 2*pi, 300);
    plot(ax, lambda/2*cos(th), lambda/2*sin(th), 'r--', 'LineWidth', 1.5);
    plot(ax, lambda  *cos(th), lambda  *sin(th), 'r:' , 'LineWidth', 1.2);

    % --- 4) Puntos (submuestreados si son muchos) ---
    if Nx*Ny <= 5000
        plot(ax, X(:), Y(:), '.', 'Color', [0.35 0.35 0.35], 'MarkerSize', 4);
    else
        sx = ceil(Nx/60); sy = ceil(Ny/60);
        plot(ax, X(1:sy:end, 1:sx:end), Y(1:sy:end, 1:sx:end), ...
            '.', 'Color', [0.35 0.35 0.35], 'MarkerSize', 2);
    end

    % --- 5) Centro (0,0) ---
    plot(ax, 0, 0, 'k+', 'MarkerSize', 14, 'LineWidth', 2);

    % --- 6) Caja de parametros ---
    info = sprintf(['N_x = %d,  N_y = %d\n' ...
                    'L_x = %.3f\\lambda,  L_y = %.3f\\lambda\n' ...
                    'd_x = \\lambda/%.2f,  d_y = \\lambda/%.2f\n' ...
                    'z_0 = %.3f\\lambda\n' ...
                    'Total = %d muestras'], ...
        Nx, Ny, Lx/lambda, Ly/lambda, ...
        lambda/dx, lambda/dy, z0/lambda, Nx*Ny);
    text(ax, x_lim(1) + 0.03*diff(x_lim), y_lim(2) - 0.03*diff(y_lim), info, ...
        'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', ...
        'BackgroundColor', 'w', 'EdgeColor', 'k', 'FontSize', 9, ...
        'Interpreter', 'tex');

    xlabel(ax, 'x / \lambda'); ylabel(ax, 'y / \lambda');
    title(ax, sprintf('Vista de la malla rectangular (%dx%d)', Nx, Ny));

    xlim(ax, [x_lim(1)-pad_x, x_lim(2)+pad_x]);
    ylim(ax, [y_lim(1)-pad_y, y_lim(2)+pad_y]);

    % --- 7) Leyenda ---
    h1 = plot(ax, nan, nan, '-', 'Color', [0.00 0.30 0.70], 'LineWidth', 2);
    h2 = plot(ax, nan, nan, '-', 'Color', [0.78 0.78 0.78], 'LineWidth', 0.5);
    h3 = plot(ax, nan, nan, 'r--', 'LineWidth', 1.5);
    h4 = plot(ax, nan, nan, 'r:' , 'LineWidth', 1.2);
    legend(ax, [h1 h2 h3 h4], ...
        {'Borde de malla', 'Lineas de grilla', ...
         'Radio \lambda/2', 'Radio \lambda'}, ...
        'Location', 'southoutside', 'Orientation', 'horizontal');

    hold(ax, 'off');
end