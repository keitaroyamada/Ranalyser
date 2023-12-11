function [idx] = cumpercentile_ra(data,p)
    [sorted_data, srted_idx] = sort(data);%min->max

    Dcum     = cumsum(sorted_data);
    Dcumrate = Dcum./Dcum(end);
    
    idx = zeros(numel(p),1);
    for i=1:numel(p)
        if p(i)>1
            continue
        else
            idx(i) = knnsearch(Dcumrate,p(i));
        end
    end
end

