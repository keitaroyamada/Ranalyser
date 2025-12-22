function [Tobs,p,Tperm] = cvm2_perm(x,y,B,seed)
    % Two-sample Cramér–von Mises + permutation test
    % x,y : vectors
    % B   : #permutations (e.g., 5000)
    % seed: optional
    
    if nargin<3 || isempty(B), B = 10000; end
    if nargin>=4 && ~isempty(seed), rng(seed); end
    
    x = x(:); 
    y = y(:);
    n = numel(x); 
    m = numel(y);
    z = [x; y];
    N = n + m;
    
    [z_sorted, ord] = sort(z);
    initial_lab = [true(n,1); false(m,1)];
    labX_sorted = initial_lab(ord);

    Tobs  = cvm_stat(z_sorted, labX_sorted, n, m);
    
    Tperm = zeros(B,1);
    for b = 1:B
        idx = randperm(N);
        lab = false(N,1);
        lab(idx(1:n)) = true;              % keep group sizes fixed

        Tperm(b) = cvm_stat(z_sorted, lab(ord), n, m);
    end
    
    p = (sum(Tperm >= Tobs) + 1) / (B + 1); % right-tail, +1 correction
end

function T = cvm_stat(z, labX, n, m)    
    Fx = cumsum(labX)  / n;
    Fy = cumsum(~labX) / m;
    
    [~, ~, ic] = unique(z,'stable');
    w = accumarray(ic,1);
    [~, jump_idx] = unique(z,'last');
    d = Fx(jump_idx) - Fy(jump_idx);
    T = (n*m/(n+m)) * sum(w .* d.^2) / sum(w); % discrete CvM on pooled grid
end