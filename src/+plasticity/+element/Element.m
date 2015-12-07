classdef Element < handle

%===============================================================================
properties (SetAccess = protected)
  last_conv_state_;
  flow_rule_;
  plast_pts_ = {};
end

%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = Element(flow_rule)
    assert(isa(flow_rule, 'plasticity.flowrule.FlowRule'), ...
      'invalid flow rule specified');
    self.flow_rule_ = flow_rule;
  end
%-------------------------------------------------------------------------------
  function linkTo(self, lcv)
    self.last_conv_state_ = lcv;
  end
%-------------------------------------------------------------------------------
  function lcs = getLastConvState(self)
    lcs = self.last_conv_state_;
  end
%-------------------------------------------------------------------------------
  function pl_pt = getPlasticityPoint(self, num)
    pl_pt = self.plast_pts_{num};
  end  
%-------------------------------------------------------------------------------  
  function flow_rule = getFlowRule(self)
    flow_rule = self.flow_rule_;
  end
%-------------------------------------------------------------------------------  
end


%===============================================================================
methods (Abstract, Access = public)
  f_int = getFInt(self)
end
%-------------------------------------------------------------------------------

end
































