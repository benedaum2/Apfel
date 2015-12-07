classdef LagrangeTriangle < model.shape.Shape

%===============================================================================  
properties(Constant)
  MAX_ORDER_IMPLEMENTED_ = 3;
end   
    
  
%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = LagrangeTriangle(order)
    self@model.shape.Shape(2, order);
  end
%-------------------------------------------------------------------------------
% getValues_r = ...
% = [h_1, h_2, ... , h_q];
  function getValues_r = getValues(self, ref_coords)
    % h = getValues_r
    % h = [h_1, h_2, ... , h_q];
    assertCoordsDimension(self, ref_coords);
    r             = ref_coords(1);
    s             = ref_coords(2);    
    node_spacing  = 1/self.order_; 
    getValues_r = zeros(1, self.getNodeAmount());
    for index = 1:length(getValues_r)
      l_order = self.getLagrangeOrder(index);
      l_1 = model.shape.LagrangePolynom(l_order(1), l_order(1), 0, node_spacing*l_order(1));
      l_2 = model.shape.LagrangePolynom(l_order(2), l_order(2), 0, node_spacing*l_order(2));
      l_3 = model.shape.LagrangePolynom(l_order(3), l_order(3), 0, node_spacing*l_order(3));
      getValues_r(index) = ...
        l_1.getValue(r)*l_2.getValue(s)*l_3.getValue(1 - r - s);
    end
  end
%-------------------------------------------------------------------------------
% getDerivatives_r = ...
% = [dh_1/dr, dh_2/dr, ... , dh_q/dr; 
%    dh_1/ds, dh_2/ds, ... , dh_q/ds]
  function getDerivatives_r = getDerivatives(self, ref_coords)
    assertCoordsDimension(self, ref_coords);    
    r             = ref_coords(1);
    s             = ref_coords(2);    
    node_spacing  = 1/self.order_;      
    getDerivatives_r = zeros(self.dim_, self.getNodeAmount());
    for index = 1:length(getDerivatives_r(1,:))
      l_order = self.getLagrangeOrder(index);      
      l_1 = model.shape.LagrangePolynom(l_order(1), l_order(1), 0, node_spacing*l_order(1));
      l_2 = model.shape.LagrangePolynom(l_order(2), l_order(2), 0, node_spacing*l_order(2));
      l_3 = model.shape.LagrangePolynom(l_order(3), l_order(3), 0, node_spacing*l_order(3));
      getDerivatives_r(1, index) = ... % to differentiate with respect to r
        l_1.getDerivative(r)*l_2.getValue(s)*l_3.getValue(1 - r - s) - ...
        l_1.getValue(r)*l_2.getValue(s)*l_3.getDerivative(1 - r - s);
      getDerivatives_r(2, index) = ... % to differentiate with respect to s
        l_1.getValue(r)*l_2.getDerivative(s)*l_3.getValue(1 - r - s) - ...
        l_1.getValue(r)*l_2.getValue(s)*l_3.getDerivative(1 - r - s);      
    end
  end
%-------------------------------------------------------------------------------
  function getPerimeterNodes_r = getPerimeterNodes(self)
    n = self.order_;
    corner_1 = 1;
    corner_2 = 2;
    corner_3 = 3;
    edge_1 = 4:n+2;
    edge_2 = n+3:2*n+1;
    edge_3 = 2*n+2:3*n;
    getPerimeterNodes_r = ...
      [corner_1, edge_1, corner_2, edge_2, corner_3, edge_3];
  end
%-------------------------------------------------------------------------------  
end

%===============================================================================
methods (Access = private)
%-------------------------------------------------------------------------------    
  function assertCoordsDimension(self, ref_coords)
    assert(all(size(ref_coords) == [self.dim_, 1]), ...
      'enter ref_coords as a 2 row column vector');
  end
%-------------------------------------------------------------------------------    
  function getLagrangeOrder_r = getLagrangeOrder(self, nodenumber)
    n = self.order_;
    switch n
      case 1
        table = [0, 0, 1; 1, 0, 0; 0, 1, 0];
      case 2
        table = [0, 0, 2; 2, 0, 0; 0, 2, 0; 
                 1, 0, 1; 1, 1, 0; 0, 1, 1];
      case 3
        table = [0, 0, 3; 3, 0, 0; 0, 3, 0;
                 1, 0, 2; 2, 0, 1; 2, 1, 0;
                 1, 2, 0; 0, 2, 1; 0, 1, 2;
                 1, 1, 1];
      otherwise
        error('order not supported')
    end
    getLagrangeOrder_r = table(nodenumber, :);
  end 
%-------------------------------------------------------------------------------    
  function getNodeAmount_r = getNodeAmount(self)
    getNodeAmount_r = 0;
    for j = 1:self.order_ + 1
      for i = 1:j
        getNodeAmount_r = getNodeAmount_r + 1;
      end
    end
  end   
%-------------------------------------------------------------------------------
% determine order by comparing node_amount to arithmetical series
%   function setOrder(self, node_amount)
%     sum = 0;
%     add = 1;
%     while true
%       sum = sum + add;
%       if sum == node_amount
%         break;
%       end
%       add = add + 1;
%       self.order_ = add - 1;
%       assert(self.order_ <= self.MAX_ORDER_IMPLEMENTED_, ...
%         'requested order not avalible');
%     end
%     
%   end
%-------------------------------------------------------------------------------  
end  

end



























