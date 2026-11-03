function [hpbw, theta_peak] = compute_hpbw(theta_deg, P_norm)
% COMPUTE_HPBW  Ancho de haz de media potencia (-3 dB en potencia).
%
%   [hpbw, theta_peak] = compute_hpbw(theta_deg, P_norm)
%
%   - Interpola linealmente los cruces a 0.5*Pmax por izquierda y derecha.
%   - Si el pico cae en un borde (broadside o dipolo), aplica simetria.
%   - Devuelve NaN si el lobulo no cruza -3 dB dentro del rango.

    P_norm    = P_norm(:);
    theta_deg = theta_deg(:);

    [Pmax, idx_peak] = max(P_norm);
    theta_peak = theta_deg(idx_peak);
    thr        = Pmax / 2;

    % Cruce a la izquierda
    theta_L = NaN;
    for i = idx_peak:-1:2
        if P_norm(i) >= thr && P_norm(i-1) < thr
            t1 = theta_deg(i-1); p1 = P_norm(i-1);
            t2 = theta_deg(i);   p2 = P_norm(i);
            theta_L = t1 + (thr - p1) * (t2 - t1) / (p2 - p1);
            break;
        end
    end

    % Cruce a la derecha
    theta_R = NaN;
    for i = idx_peak:numel(P_norm)-1
        if P_norm(i) >= thr && P_norm(i+1) < thr
            t1 = theta_deg(i);   p1 = P_norm(i);
            t2 = theta_deg(i+1); p2 = P_norm(i+1);
            theta_R = t1 + (thr - p1) * (t2 - t1) / (p2 - p1);
            break;
        end
    end

    % Componer HPBW
    if ~isnan(theta_L) && ~isnan(theta_R)
        hpbw = theta_R - theta_L;
    elseif ~isnan(theta_R)          % pico en borde izquierdo (broadside)
        hpbw = 2 * (theta_R - theta_peak);
    elseif ~isnan(theta_L)          % pico en borde derecho (dipolo)
        hpbw = 2 * (theta_peak - theta_L);
    else
        hpbw = NaN;
    end
end