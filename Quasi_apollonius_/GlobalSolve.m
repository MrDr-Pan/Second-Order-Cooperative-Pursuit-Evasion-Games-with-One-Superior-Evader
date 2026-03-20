function varargout = GlobalSolve(varargin)
n = varargin{2};
obj_fun = varargin{1};
start_num = 100;
if(nargin==2)
    lb = -inf(1,n);
    ub = inf(1,n);
end
if(nargin==4)
    lb = varargin{3};
    ub = varargin{4};
end
if(nargin==5)
    if isempty(varargin{3})
        lb = -inf(1,n);
    else
        lb = varargin{3};
    end
    
    if isempty(varargin{4})
        ub = inf(1,n);
    else
        ub = varargin{4};
    end
    
    start_num = varargin{5};
end
options = optimoptions('particleswarm','display','off');
x0 = particleswarm(@(x)sum(obj_fun(x).^2),n,lb,ub,options);
opts = optimoptions(@lsqnonlin,'FunctionTolerance',1e-30,'StepTolerance',1e-30,'OptimalityTolerance',1e-60);
problem  = createOptimProblem('lsqnonlin','x0',x0,'objective',obj_fun,'lb',lb,'ub',ub,'options',opts);
gs = MultiStart('FunctionTolerance',1e-2,'XTolerance',1e-2);
[x,~,exitflag,~,allmins] = gs.run(problem,start_num);
fval = obj_fun(x);
if n==1
    for ii = 1:numel(allmins)
        multiSol(ii) = allmins(ii).X;
    end
    multiSol = sort(multiSol);
    for ii = 1:numel(allmins)
        multiFval{ii} = obj_fun(multiSol(ii));
    end
else
    for ii = 1:numel(allmins)
        multiSol{ii} = allmins(ii).X;
        multiFval{ii} = obj_fun(multiSol{ii});
    end
end
switch nargout
    case 1
        varargout{1} = x;
    case 2
        varargout{1} = x;
        varargout{2} = fval;
    case 3
        varargout{1} = x;
        varargout{2} = fval;
        varargout{3} = exitflag;
    case 4
        varargout{1} = x;
        varargout{2} = fval;
        varargout{3} = exitflag;
        varargout{4} = multiSol;
    case 5
        varargout{1} = x;
        varargout{2} = fval;
        varargout{3} = exitflag;
        varargout{4} = multiSol;
        varargout{5} = multiFval;
end

function [c ceq] = constrain(x,f)
ceq = f(x);
c =[];
   
