classdef VonMises < plasticity.flowrule.FlowRule

  
%===============================================================================
properties (SetAccess = protected)
  m_
  sigma_f_
end  


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------
% Constructor
  function self = VonMises(data)
    self@plasticity.flowrule.FlowRule(data);
    self.sigma_f_ = data.sigma_f;
    self.m_ =  [  1  -1/2 -1/2   0    0    0 
                -1/2   1  -1/2   0    0    0
                -1/2 -1/2   1    0    0    0
                  0    0    0    3    0    0
                  0    0    0    0    3    0
                  0    0    0    0    0    3  ] * (self.sigma_f_)^(-2);
  end
%-------------------------------------------------------------------------------
  function m = getMatrix(self)
    m       = self.m_;
  end  
%-------------------------------------------------------------------------------
end

end






























