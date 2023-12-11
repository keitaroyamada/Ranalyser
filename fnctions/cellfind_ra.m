function [idx, varargout] = cellfind_ra(target, findstring, varargin)
%find in CELLtype
%target: cell
%findstring:　strings
%varargin:　(full match, 0: partial match)
    %======================================================================
    %lenght of data 
    N = size(target);
    if N(1)<N(2)
        target = transpose(target);
        N=N(2);
    else
        N=N(1);
    end

    idx=[];
    val=[];
    
    %if cell
    if iscell(target)==1
        for i=1:N
            if cell2mat(varargin)==1
                %full match
                if strcmp(target{i,1}, findstring)==1
                    idx = [idx; i];
                end
            else
                if (strfind(target{i,1}, findstring)) > 0
                    idx = [idx; i];
                end
            end
        end
        val = [val;cellstr(target(idx,1))];
        %val = 
        if nargout==2
            varargout{1} = val;
        end
        return
    end
    
    %if string
    if isstring(target)==1
        for i=1:N
            if cell2mat(varargin)==1
                %if full match
                if strcmp(target(i,1), findstring)==1
                    idx = [idx; i];
                end
            else
                if (strfind(target(i,1), findstring)) > 0
                    idx = [idx; i];
                end
            end
        end
        val = [val; target(idx,1)];
        if nargout==2
            varargout{1} = val;
        end
        return
    end
    
    %if num
    if isnumeric(target)==1
        if ischar((findstring))==1
            findstring = str2double(findstring);
        end
        idx = find(target==findstring);
        val = target(idx);
        if nargout==2
            varargout{1} = val;
        end
        return
    else
        %if unsuspected type
        idx = [];
        val = [];
        disp('Please input type of cell, string, numeric')
        return
    end
end

