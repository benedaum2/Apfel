classdef SerendipityTriangle < model.shape.Shape

%===============================================================================  
properties(Constant)
  MAX_ORDER_IMPLEMENTED_ = 2;
end  
    
  
%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = SerendipityTriangle(order)
    self@model.shape.Shape(2, order);
  end
%-------------------------------------------------------------------------------
% getValues_r = ...
% = [h_1, h_2, ... , h_q];
  function getValues_r = getValues(self, ref_coords)

    assertCoordsDimension(self, ref_coords);
    switch self.order_
      case 1
        getValues_r = valueFirstOrder(self, ref_coords);
      case 2
        getValues_r = valueSecondOrder(self, ref_coords);
      otherwise
        error('requested order is not implemented');
    end
  end
%-------------------------------------------------------------------------------  
% getDerivatives_r = ...
% = [dh_1/dr, dh_2/dr, ... , dh_q/dr; 
%    dh_1/ds, dh_2/ds, ... , dh_q/ds]
  function getDerivatives_r = getDerivatives(self, ref_coords) 
    assertCoordsDimension(self, ref_coords);   
    switch self.order_
      case 1
        getDerivatives_r = derivativeFirstOrder(self, ref_coords);
      case 2
        getDerivatives_r = derivativeSecondOrder(self, ref_coords); 
      otherwise
        error('requested order is not implemented');
    end
  end 
%-------------------------------------------------------------------------------
  function getPerimeterNodes_r = getPerimeterNodes(self)
    switch self.order_
      case 1
        getPerimeterNodes_r = [1, 2, 3];
      case 2
        getPerimeterNodes_r = [1, 4, 2, 5, 3, 6];
      otherwise
    end
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
  function valueFirstOrder_r = valueFirstOrder(self, ref_coords) %#ok<INUSL>
    r = ref_coords(1);
    s = ref_coords(2);
    valueFirstOrder_r = [ 1 - r - s; r; s];
  end
%-------------------------------------------------------------------------------
  function valueSecondOrder_r = valueSecondOrder(self, ref_coords) %#ok<INUSL>
    r = ref_coords(1);
    s = ref_coords(2);
    valueSecondOrder_r = [
      1 - 3*r - 3*s + 2*r^2 + 4*r*s + 2*s^2;
      -r + 2*r^2;
      -s + 2*s^2;
      4*(1 - r - s)*r;
      4*r*s;
      4*(1 - r - s)*s;
    ];
  end
%-------------------------------------------------------------------------------
  function derivativeFirstOrder_r = derivativeFirstOrder(self, ref_coords) %#ok<INUSD>
    derivativeFirstOrder_r = [
      -1, 1, 0;
      -1, 0, 1];
  end
%-------------------------------------------------------------------------------
  function derivativeSecondOrder_r = derivativeSecondOrder(self, ref_coords)  %#ok<INUSL>
    r = ref_coords(1);
    s = ref_coords(2);
    derivativeSecondOrder_r = [
      -3 + 4*r + 4*s, -1 + 4*r,        0, 4 - 8*r - 4*s, 4*s,          -4*s;
      -3 + 4*r + 4*s,        0, -1 + 4*s,          -4*r, 4*r, 4 - 4*r - 8*s];
  end
%-------------------------------------------------------------------------------
%   function setOrder(self, node_amount)
%     switch node_amount
%       case 3 % first order
%         self.order_ = 1;
%       case 6 % second order
%         self.order_ = 2;
%       otherwise
%         error('invalid number of nodes provided');
%     end        
%   end
%-------------------------------------------------------------------------------  
end  

end



























