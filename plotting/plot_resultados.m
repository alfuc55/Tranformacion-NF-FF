function plot_resultados(nf, ff, ref, met, cfg)
    lambda = nf.lambda;  z0 = nf.z0;
    dx = nf.dx;  dy = nf.dy;
    X  = nf.X;   Y  = nf.Y;
    Nx = size(nf.Ex,2);  Ny = size(nf.Ex,1);
    E_mag = sqrt(abs(nf.Ex).^2 + abs(nf.Ey).^2 + abs(nf.Ez).^2);

    [PHI_FF, THETA_FF] = meshgrid(ff.phi_vec, ff.theta_vec);
    X_pat = ff.P_ff_norm .* sin(THETA_FF) .* cos(PHI_FF);
    Y_pat = ff.P_ff_norm .* sin(THETA_FF) .* sin(PHI_FF);
    Z_pat = ff.P_ff_norm .* cos(THETA_FF);
    X_ref = ref.P .* sin(THETA_FF) .* cos(PHI_FF);
    Y_ref = ref.P .* sin(THETA_FF) .* sin(PHI_FF);
    Z_ref = ref.P .* cos(THETA_FF);
    theta_deg = ff.theta_vec * 180/pi;

    % ---- Figura 1: NF + FF + referencia ----
    figure('Name','NF, FF y referencia','Color','w');
    tiledlayout(1,3,'TileSpacing','compact','Padding','compact');

    nexttile;
    surf(X/lambda, Y/lambda, (z0/lambda)*ones(size(X)), E_mag, ...
         'EdgeColor','none','FaceAlpha',0.85);
    colorbar;
    Emax = max(E_mag(:));
    if Emax>0 && isfinite(Emax), caxis([0 Emax]); end
    xlabel('x/\lambda'); ylabel('y/\lambda'); zlabel('z/\lambda');
    title(sprintf('NF: |E| en z_0 (%s)', nf.name));
    axis tight; grid on; view(45,30);

    info = sprintf(['N_x=%d, N_y=%d\n' ...
                    'L_x=%.2f\\lambda, L_y=%.2f\\lambda\n' ...
                    'd_x=\\lambda/%.1f, d_y=\\lambda/%.1f\n' ...
                    'z_0=%.2f\\lambda'], ...
        Nx, Ny, Nx*dx/lambda, Ny*dy/lambda, lambda/dx, lambda/dy, z0/lambda);
    xl = xlim; yl = ylim;
    text(xl(1)+0.03*(xl(2)-xl(1)), yl(1)+0.03*(yl(2)-yl(1)), z0/lambda, info, ...
        'VerticalAlignment','bottom','HorizontalAlignment','left', ...
        'BackgroundColor','w','EdgeColor','k','FontSize',7,'Interpreter','tex');

    nexttile;
    surf(X_pat, Y_pat, Z_pat, ff.P_ff_norm, 'EdgeColor','none');
    axis equal; colorbar;
    xlabel('x'); ylabel('y'); zlabel('z');
    title(sprintf('FF reconstruido\n(%s)', ff.method_name));
    view(45,30); grid on;

    nexttile;
    surf(X_ref, Y_ref, Z_ref, ref.P, 'EdgeColor','none');
    axis equal; colorbar;
    xlabel('x'); ylabel('y'); zlabel('z');
    title(sprintf('Referencia\n(%s)', ref.name));
    view(45,30); grid on;
    colormap(jet);

    % ---- Figura 2: cortes con -3 dB ----
    cuts = met.cuts_deg;
    figure('Name','Cortes NF-FF vs referencia','Color','w');
    tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
    for ii = 1:numel(cuts)
        [~, idx_phi] = min(abs(ff.phi_vec - deg2rad(cuts(ii))));
        nexttile;
        h_ff = plot(theta_deg, ff.P_ff_norm(:,idx_phi), 'b-', 'LineWidth', 2);
        hold on;
        h_rf = plot(theta_deg, ref.P(:,idx_phi), 'r--', 'LineWidth', 2);
        h_db = yline(0.5, 'k:', '-3 dB', 'LineWidth', 1.2, ...
                     'LabelHorizontalAlignment','left');
        if ~isnan(met.HPBW_ff(ii))
            hl = met.pk_ff(ii)-met.HPBW_ff(ii)/2;
            hr = met.pk_ff(ii)+met.HPBW_ff(ii)/2;
            if hl>=0 && hl<=90, plot(hl,0.5,'bo','MarkerFaceColor','b','MarkerSize',7); end
            if hr>=0 && hr<=90, plot(hr,0.5,'bo','MarkerFaceColor','b','MarkerSize',7); end
        end
        if ~isnan(met.HPBW_ref(ii))
            hl = met.pk_ref(ii)-met.HPBW_ref(ii)/2;
            hr = met.pk_ref(ii)+met.HPBW_ref(ii)/2;
            if hl>=0 && hl<=90, plot(hl,0.5,'rs','MarkerFaceColor','r','MarkerSize',7); end
            if hr>=0 && hr<=90, plot(hr,0.5,'rs','MarkerFaceColor','r','MarkerSize',7); end
        end
        grid on; xlabel('\theta (grados)'); ylabel('Patron normalizado');
        title(sprintf('Corte \\phi = %d^\\circ', cuts(ii)));
        legend([h_ff h_rf h_db], {'NF\rightarrowFF','Referencia','-3 dB'}, ...
               'Location','northeast');
        xlim([0 90]); ylim([-0.05 1.05]);
        if isnan(met.HPBW_ff(ii)) || isnan(met.HPBW_ref(ii))
            txt = 'HPBW = NaN';
        else
            txt = sprintf('HPBW_{FF}=%.2f^\\circ\nHPBW_{ref}=%.2f^\\circ\n\\Delta=%.2f^\\circ', ...
                met.HPBW_ff(ii), met.HPBW_ref(ii), met.HPBW_ff(ii)-met.HPBW_ref(ii));
        end
        text(50, 0.20, txt, 'HorizontalAlignment','left', ...
             'BackgroundColor','w','EdgeColor','k','FontSize',9,'Interpreter','tex');
        hold off;
    end

    % ---- Figura 3: barras ----
    figure('Name','Comparacion HPBW','Color','w');
    X_bar = 1:numel(cuts);
    hb = bar(X_bar, [met.HPBW_ff(:), met.HPBW_ref(:)], 'grouped');
    hb(1).FaceColor = [0.20 0.45 0.85];
    hb(2).FaceColor = [0.85 0.30 0.30];
    set(gca,'XTick',X_bar, 'XTickLabel', ...
        arrayfun(@(a) sprintf('\\phi=%d^\\circ',a), cuts, 'UniformOutput',false));
    ylabel('HPBW (-3 dB) [grados]');
    title('HPBW: NF\rightarrowFF vs referencia');
    legend('NF\rightarrowFF','Referencia','Location','northwest');
    grid on;
end