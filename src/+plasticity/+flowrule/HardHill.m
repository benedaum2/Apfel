classdef HardHill < plasticity.flowrule.FlowRule

  
%===============================================================================
properties (SetAccess = protected)
  h_
end  


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------
% Constructor
  function self = HardHill(data)
    self@plasticity.flowrule.FlowRule(data);
    self.h_ =  [ 0.00012330,-0.000073300,-0.000050000,0.000026904,0.,0.
 -0.000073300,0.00012330,-0.000050000,-0.000026904,0.,0.
 -0.000050000,-0.000050000,0.00010000,0.,0.,0.
  0.000026904,-0.000026904,0.,0.00033107,0.,0.
  0.,0.,0.,0.,0.00042426,0.
  0.,0.,0.,0.,0.,0.00042426 ];    
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

























