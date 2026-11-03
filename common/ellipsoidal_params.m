function [eta_val, Psi_val] = ellipsoidal_params(rho, a, b, d, k)
    f   = sqrt(a^2-b^2);
    ecc = f/a;
    r1 = sqrt(rho.^2+(d-f).^2);
    r2 = sqrt(rho.^2+(d+f).^2);
    u  = (r1-r2)/(2*f);
    v  = (r1+r2)/(2*a);
    u  = max(min(u,1),-1);

    [~, E_comp] = ellipke(ecc^2);
    phi_asin = asin(u);
    E_inc = arrayfun(@(p) integral(@(t) sqrt(1-ecc^2*sin(t).^2),0,p), phi_asin);
    eta_val = (pi/2)*(E_inc/E_comp);

    arg_acos = acos(sqrt((1-ecc^2)./(v.^2-ecc^2)));
    term1 = v .* sqrt((v.^2-1)./(v.^2-ecc^2));
    E_inc2 = arrayfun(@(p) integral(@(t) sqrt(1-ecc^2*sin(t).^2),0,p), arg_acos);
    Psi_val = k*a*(term1 - E_inc2);
end