function [idx] = cumpercentile_ra(data, p)
    [sorted_data, ~] = sort(data);%min->max
    sorted_data = sorted_data(find(~isnan(sorted_data)));

    Dcum     = cumsum(sorted_data);
    Dcumrate = Dcum./Dcum(end);
    
    idx = zeros(numel(p),1);
    for i=1:numel(p)
        if p(i)>1
            continue
        else
            idx(i) = knnsearch(Dcumrate, p(i));
        end
    end
end

