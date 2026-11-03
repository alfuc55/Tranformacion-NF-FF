function [theta_vec, phi_vec, PHI, THETA] = build_angular_grid(nt, np)
    theta_vec = linspace(0, pi/2-1e-6, nt);
    phi_vec   = linspace(-pi, pi, np);
    [PHI, THETA] = meshgrid(phi_vec, theta_vec);
end