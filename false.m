function root = false(f, xl, xu, tol)
    if f(xl) * f(xu) >= 0
        error('f(xl) and f(xu) must have opposite signs.');
    end
      root=0;
    error = 10000; 

    % تطبيق طريقة False Position
    while error > tol
        xr = xl - (f(xl) * (xu - xl)) / (f(xu) - f(xl));
        error = abs((xr - root) / xr) * 100; 
          root=xr;
        if f(xr) == 0
            break;
        elseif f(xl) * f(xr) < 0
            xu = xr;
        else
            xl = xr;
        end
    end

    fprintf('Final Error = %.4f%%\n', error);

    root = xr;
end
