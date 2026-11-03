function G = fresnel_G(z)
    z=double(z); z2=z.^2; c=-1j*pi/2; term=z; G=term;
    for n=1:300, term = term.*c.*z2.*(2*n-1)./(n*(2*n+1)); G = G + term; end
end