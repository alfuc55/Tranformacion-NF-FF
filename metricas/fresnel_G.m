% fresnel_G.m
function G = fresnel_G(z)
    z=double(z); z2=z.^2; c=-1j*pi/2; term=z; G=term;
    for n=1:300, term = term.*c.*z2.*(2*n-1)./(n*(2*n+1)); G = G + term; end
end

% build_angular_grid.m
function [tv, pv, PHI, THETA] = build_angular_grid(nt, np)
    tv = linspace(0, pi/2-1e-6, nt);
    pv = linspace(-pi, pi, np);
    [PHI, THETA] = meshgrid(pv, tv);
end

% compute_hpbw.m  (identica a la tuya)
% read_cplx_matrix.m  (identica a la tuya)
% tschebyscheff_window.m  (identica)
% dirichlet_kernel.m  (identica)
% ellipsoidal_params.m  (identica)