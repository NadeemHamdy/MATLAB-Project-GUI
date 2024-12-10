function x =gaussElimination(A,b)
n = size(A, 1);

for i = 1:n

    [~, idx] = max(abs(A(i:n, i)));
    idx = idx + i - 1;
    if idx ~= i

        A([i, idx], :) = A([idx, i], :);
        b([i, idx]) = b([idx, i]);
    end

    for j = i+1:n
        factor = A(j, i) / A(i, i);
        A(j, :) = A(j, :) - factor * A(i, :);
        b(j) = b(j) - factor * b(i);
    end
end
x = zeros(n, 1);
for i = n:-1:1
    x(i) = (b(i) - A(i, i+1:end) * x(i+1:end)) / A(i, i);
end
