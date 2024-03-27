% Automatically converts a YALMIP object into an anonymous 
% MATLAB function. Takes a **string** with the name of the sdpvar. 

function f = yalmip2matlabFun(name)
    str = evalin('caller', ['sdisplay(' name ')']);
    vstr = strrep(str, '*', '.*');
    vstr = strrep(vstr, '/', './');
    vstr = strrep(vstr, '^', '.^');
    vstr = vstr{1};
    W = evalin('caller','whos');
    for i = 1:size(W,1)
        % Reproduce symbolic internal variables (same size as sdpvars)
        % NOTE: more efficient if selecting the ones on which p depends
        % the following regexp gets only variable names!!
        % [tokens, matches] = regexp(string, '([a-zA-Z][a-zA-Z_0-9]*)', ...
        %                     'tokens', 'match')
        if strcmp(W(i).class,'sdpvar') || strcmp(W(i).class,'ncvar')
            cmd = [W(i).name '= sym(''' W(i).name ''',' mat2str(W(i).size), ');'];
            eval(cmd); 
        end
    end
    
    % Replace name with value when not Nan
    [matches, fi, li] = regexp(vstr, ...
        '([a-zA-Z][a-zA-Z_0-9]*)(\((\d+,?\s*)+\))*', 'match');
    for i = 1:length(matches)
        isinternal = regexp(matches{i}, '^internal.*');
        if(isinternal)
            cmd = ['value(recover' matches{i}(9:end) ');'];
            internalvaridx = regexp(matches{i}, 'internal((\d+,?\s*)+\)', 'tokens');
            internalvaridx = internalvaridx{1}{1};
            internalvarsize = evalin('caller',['size(recover(' internalvaridx '))']);          
        else
            cmd = ['value(' matches{i} ');'];
        end
        val = evalin('caller', cmd);
        rep = 0;
        if(~isnan(val))
            rep = mat2str(val);
        elseif(isinternal)
            cmd = ['internal' internalvaridx '_ = sym(''internal' internalvaridx '_'',' mat2str(internalvarsize), ');'];
            eval(cmd); 
            rep = ['internal' internalvaridx '_'];
        end
        
        if(rep~=0)
            displ = -li(i)+fi(i)+length(rep)-1;
            vstr = [vstr(1:(fi(i)-1)) rep vstr(li(i)+1:end)];
            fi = fi+displ;
            li = li+displ;
        end
    end
    f = matlabFunction(eval(vstr));
end