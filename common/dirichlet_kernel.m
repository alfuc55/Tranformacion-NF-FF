function D = dirichlet_kernel(x, M)
% DIRICHLET_KERNEL  Kernel de Dirichlet normalizado.
%
%   D(x) = sin((2M+1) x/2) / ((2M+1) sin(x/2))
%   Con D(0) = 1 (limite).

    xh = x/2;
    D  = sin((2*M+1)*xh) ./ ((2*M+1)*sin(xh) + eps);
    D(abs(xh) < 1e-10) = 1;
end