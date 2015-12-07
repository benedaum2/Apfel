classdef Hill < plasticity.flowrule.FlowRule

  
%===============================================================================
properties (SetAccess = protected)
  h_
end  


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------
% Constructor
  function self = Hill(data)
    self@plasticity.flowrule.FlowRule(data);
    %f = data.f; g = data.g; h = data.h; l = data.l; m = data.m; n = data.n;
    f = data.f; g = data.g; h = data.h; l = data.l; m = data.m; n = data.n;
    self.h_ =  [ g+h  -h   -g    0    0    0 
                 -h   h+f  -f    0    0    0
                 -g   -f   f+g   0    0    0
                  0    0    0   2*n   0    0
                  0    0    0    0   2*l   0
                  0    0    0    0    0   2*m ];
    % self.dispDescription();
  end
%-------------------------------------------------------------------------------
  function h = getMatrix(self)
    h       = self.h_;
  end  
%-------------------------------------------------------------------------------
end

%===============================================================================
methods (Access = private)
%-------------------------------------------------------------------------------
%   function dispDescription(self)
%     if self.h_(2, 3) == self.h_(1, 2)
%       fg = 1;
%     end
%     if self.h_(1, 2) == self.h_(1, 3)
%       gh = 1;
%     end
%     if self.h_(1, 2) == self.h_(2, 3)
%       hf = 1;
%     end    
%     
%     
%     disp(horzcat(class(self), ' ', type));
%   end  
%-------------------------------------------------------------------------------

end

end


























