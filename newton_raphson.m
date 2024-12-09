function root = newton_raphson(f, f_prime, x0, tol, max_iter)
    x = x0;
    for iter = 1:max_iter
        % Compute next iteration
        fx = f(x);
        fpx = f_prime(x);

        % Check for division by zero
        if fpx == 0
            error('Derivative is zero. Cannot continue.');
        endif

        x_new = x - fx / fpx;

        % Check convergence
        if abs(x_new - x) < tol
            root = x_new;
            return;
        endif

        x = x_new;
    endfor

    % If max iterations reached
    warning('Maximum iterations reached without convergence');
    root = x;
end
