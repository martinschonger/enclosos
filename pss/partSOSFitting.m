% The following function is the SOS + linear optimization formulating the
% PSS polynomial with the help of YALMIP and SeDuMi.
%
function PSSCoeffs = partSOSFitting(n, x, p, c, f, B, K) %#ok<STOUT>
    % The following string should not be produced after the spdvar xi's,
    % otherwise you may get a strange string with x61 or x82 etc.
    tmpStr = "Goal=[sos(p";
    tmpStr = tmpStr + join(arrayfun(@(idx) "-s" + idx + "B*(" + string(x(idx)) + "-(" + B(idx, 1) + "))*((" + B(idx ,2)+ ")-" + string(x(idx)) + ")", 1:n), "") + "),\n";
    tmpStr = tmpStr + join(arrayfun(@(idx) "sos(s" + idx + "B)", 1:n), ",\n") + ",\n";
    tmpStr = tmpStr + join(arrayfun(@(idx) ...
        string(subs(p, x, K(idx, :))) + ">=1", 1:size(K, 1)), ",\n") + "];";
    % back to the expected order of the lines.
    for idx = 1:n
        eval("sdpvar " + string(x(idx)));
    end
    for idx = 1:length(c)
        eval("sdpvar " + string(c(idx)));
    end
    eval("p=" + string(p));
    eval("F=" + string(f));
    for idx1 = 1:n
        eval("[s" + idx1 + "B,c" + idx1 + "B]=polynomial([" + join(arrayfun(@(idx2) string(x(idx2)), 1:n)) + "],0)");
    end
    eval(sprintf(tmpStr));
    eval("solvesos(Goal, F, [], ["+ ...
        join(arrayfun(@(idx) "c" + idx + "B;", 1:n), "") + ...
        join(arrayfun(@(idx) string(c(idx)), 1:length(c)), ";") + "])");
    eval("PSSCoeffs=[" + join(arrayfun(@(idx) "value(" + string(c(idx)) + ")", 1:length(c)), ",") + "]");
end