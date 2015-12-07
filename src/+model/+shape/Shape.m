classdef Shape < handle
  
%===============================================================================   
properties (SetAccess = protected)
  order_;
  dim_;
end  


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = Shape(dim, order)
    self.dim_   = dim;    
    self.order_ = order;    
  end
%-------------------------------------------------------------------------------
  function getOrder_r = getOrder(self)
    getOrder_r = self.order_;
  end
%-------------------------------------------------------------------------------  
end

%===============================================================================
methods (Abstract, Access = public)
  getValues_r = getValues(self, ref_coords)
  getDerivatives_r = getDerivatives(self, ref_coords)
  getPerimeterNodes_r = getPerimeterNodes(self)
end


end