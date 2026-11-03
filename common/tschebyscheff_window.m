function w = tschebyscheff_window(x, M, xbar)
% TSCHEBYSCHEFF_WINDOW  Ventana de Tschebyscheff para OSI.
%
%   w = tschebyscheff_window(x, M, xbar)
%
%   x     : vector de distancias (rad) respecto al centro
%   M     : numero de terminos del kernel (par; se redondea a par)
%   xbar  : semi-ancho de la ventana principal (rad)
%
%   Fuera de |x| < xbar, w = 0 (soporte finito).
%   Dentro,  w(x) = T_M( -1 + 2*cos(x/2)^2 / cos(xbar/2)^2 ) / T_M( -1 + 2/cos(xbar/2)^2 )

    if mod(M, 2) == 1, M = M + 1; end
    w = zeros(size(x));
    mk = abs(x) < xbar;
    if xbar < 1e-12
        w(mk) = 1;
        return;
    end
    xi = x(mk);
    v      = cos(xi/2) ./ cos(xbar/2);
    arg_TM = -1 + 2*v.^2;
    arg_0  = -1 + 2 / cos(xbar/2)^2;
    TM  = cosh(M * acosh(max(arg_TM, 1)));
    TM0 = cosh(M * acosh(max(arg_0,  1)));
    w(mk) = TM / TM0;
end