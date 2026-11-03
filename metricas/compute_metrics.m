function met = compute_metrics(ff, ref, cfg)
    theta_deg = ff.theta_vec * 180/pi;
    cuts = cfg.metrics.cuts_deg;
    n = numel(cuts);
    met.cuts_deg = cuts;
    met.HPBW_ff = nan(1,n);  met.HPBW_ref = nan(1,n);
    met.pk_ff = nan(1,n);    met.pk_ref = nan(1,n);

    for ii = 1:n
        [~, i] = min(abs(ff.phi_vec - deg2rad(cuts(ii))));
        [met.HPBW_ff(ii),  met.pk_ff(ii)]  = compute_hpbw(theta_deg, ff.P_ff_norm(:,i));
        [met.HPBW_ref(ii), met.pk_ref(ii)] = compute_hpbw(theta_deg, ref.P(:,i));
    end

    fprintf('\n===== HPBW (-3 dB) =====\n');
    fprintf(' phi | HPBW_ff  HPBW_ref  Err_abs  Err_rel%%\n');
    for ii = 1:n
        e_a = met.HPBW_ff(ii)-met.HPBW_ref(ii);
        if isnan(met.HPBW_ref(ii)), e_r = NaN;
        else, e_r = 100*abs(e_a)/met.HPBW_ref(ii); end
        fprintf(' %3d | %7.2f  %8.2f  %+7.2f   %6.2f\n', ...
            cuts(ii), met.HPBW_ff(ii), met.HPBW_ref(ii), e_a, e_r);
    end
    fprintf('========================\n\n');
end