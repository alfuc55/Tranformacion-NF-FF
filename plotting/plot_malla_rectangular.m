function plot_malla_rectangular(nf)
    X=nf.X; Y=nf.Y; lambda=nf.lambda; z0=nf.z0;
    dx=nf.dx; dy=nf.dy; [Ny,Nx]=size(X);
    Lx=Nx*dx; Ly=Ny*dy;

    x_lim = [min(X(:))-dx/2, max(X(:))+dx/2];
    y_lim = [min(Y(:))-dy/2, max(Y(:))+dy/2];
    px = 0.10*diff(x_lim); py = 0.10*diff(y_lim);

    figure('Name','Vista de la malla','Color','w');
    hold on; grid on; box on; axis equal;

    rectangle('Position',[x_lim(1),y_lim(1),diff(x_lim),diff(y_lim)], ...
        'EdgeColor',[0 0.30 0.70],'LineWidth',2);

    ml = 40;
    if Nx<=ml, xl = X(1,:); else, xl = X(1,1:ceil(Nx/ml):end); end
    if Ny<=ml, yl = Y(:,1); else, yl = Y(1:ceil(Ny/ml):end,1); end
    for xv = unique(xl)
        plot([xv xv],[y_lim(1) y_lim(2)],'-','Color',[.78 .78 .78],'LineWidth',0.5);
    end
    for yv = unique(yl)
        plot([x_lim(1) x_lim(2)],[yv yv],'-','Color',[.78 .78 .78],'LineWidth',0.5);
    end

    th = linspace(0,2*pi,300);
    plot(lambda/2*cos(th), lambda/2*sin(th), 'r--','LineWidth',1.5);
    plot(lambda  *cos(th), lambda  *sin(th), 'r:' ,'LineWidth',1.2);

    if Nx*Ny<=5000
        plot(X(:), Y(:), '.', 'Color',[.35 .35 .35],'MarkerSize',4);
    else
        sx=ceil(Nx/60); sy=ceil(Ny/60);
        plot(X(1:sy:end,1:sx:end), Y(1:sy:end,1:sx:end), '.', ...
            'Color',[.35 .35 .35],'MarkerSize',2);
    end
    plot(0,0,'k+','MarkerSize',14,'LineWidth',2);

    info = sprintf(['N_x=%d, N_y=%d\nL_x=%.3f\\lambda, L_y=%.3f\\lambda\n' ...
                    'd_x=\\lambda/%.2f, d_y=\\lambda/%.2f\nz_0=%.3f\\lambda\n' ...
                    'Total = %d muestras'], ...
        Nx, Ny, Lx/lambda, Ly/lambda, lambda/dx, lambda/dy, z0/lambda, Nx*Ny);
    text(x_lim(1)+0.03*diff(x_lim), y_lim(2)-0.03*diff(y_lim), info, ...
        'VerticalAlignment','top','HorizontalAlignment','left', ...
        'BackgroundColor','w','EdgeColor','k','FontSize',9,'Interpreter','tex');

    xlabel('x / \lambda'); ylabel('y / \lambda');
    title(sprintf('Malla rectangular (%dx%d)', Nx, Ny));
    xlim([x_lim(1)-px, x_lim(2)+px]); ylim([y_lim(1)-py, y_lim(2)+py]);
    hold off;
end