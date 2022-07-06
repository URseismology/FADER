function jr = findfirsttrace(R)    

jr = 1;
    for ir = 1:size(R,1)
        if sum(isnan(R(ir,:))) < 1 && sum(abs(R(ir,:)) < 1e-3)
            break;
        end
        jr = jr + 1;
    end