function root = false(f, xl, xu, tol)
    % التحقق من صحة القيم الابتدائية
    if f(xl) * f(xu) >= 0
        error('f(xl) and f(xu) must have opposite signs.');
    end
      root=0;
    % تعريف الخطأ الابتدائي
    error = 10000; % تعيين قيمة كبيرة كبداية

    % تطبيق طريقة False Position
    while error > tol
        xr = xl - (f(xl) * (xu - xl)) / (f(xu) - f(xl));
        error = abs((xr - root) / xr) * 100; % حساب الخطأ النسبي
          root=xr;
        % تحديث القيم حسب الإشارة
        if f(xr) == 0
            break;
        elseif f(xl) * f(xr) < 0
            xu = xr;
        else
            xl = xr;
        end
    end

    % طباعة الخطأ النسبي النهائي
    fprintf('Final Error = %.4f%%\n', error);

    % النتيجة النهائية
    root = xr;
end
