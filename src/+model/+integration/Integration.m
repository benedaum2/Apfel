classdef Integration < handle
  
%===============================================================================
properties (SetAccess = protected)
  int_points_ = {}
  order_
end  


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% constructor
  function self = Integration(order)
    self.order_ = order;
  end
%-------------------------------------------------------------------------------
  function getIntPoints_r = getIntPoints(self)
    getIntPoints_r = self.int_points_;
  end
%-------------------------------------------------------------------------------  
end

%===============================================================================
methods (Static, Abstract, Access = public)
  getTable_r = getTable(self)
  getRefDomainFactor_r = getRefDomainFactor(self)
end
%-------------------------------------------------------------------------------

end