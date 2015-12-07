classdef LagrangeQuadrilateral < model.shape.Shape
%===============================================================================  
%
%                                                         (n-1,m-1)
%   o--------o--------o--- ... --------o--------o--------o
%   |<mn+m>                                              |<mn>
%   |                                                    |
%   |                                                    |
%                            (mod(p-1,n),floor(p-1/n))   |
%  ...                      o                           ...
%                            <p>
%   |(0,2)    (1,2)    (2,2)                             |                    
%   o        o        o                                  o
%   |<2n+1>   <2n+2>   <2n+3>                            |<3n>
%   |                                                    |
%   |(0,1)    (1,1)    (2,1)                             |(n-1,1)
%   o        o        o                                  o
%   |<1n+1>   <1n+2>   <1n+3>                            |<2n>
%   |                                                    |
%   |(0,0)    (1,0)    (2,0)                             |(n-1,0)
%   o--------o--------o--- ... --------o--------o--------o  
%    <0n+1>   <0n+2>   <0n+3>                             <1n>
%
%    <>  ... nodenumber
%    ()  ... lagrangeorder
%    n-1 ... self.order_(1)
%    m-1 ... self.order_(2)
%
%===============================================================================  
properties(Constant)

end   
    
  
%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = LagrangeQuadrilateral(order)
    self@model.shape.Shape(2, order);
    assert(length(order) == 2, ...
      'specify element order in both directions')    
    self.order_ = order;
  end
%-------------------------------------------------------------------------------
% getValues_r = ...
% = [h_1, h_2, ... , h_q];
  function getValues_r = getValues(self, ref_coords) 
    assertCoordsDimension(self, ref_coords);
    r             = ref_coords(1);
    s             = ref_coords(2);    
    getValues_r = zeros(1, self.getNodeAmount());
    for index = 1:length(getValues_r)
      l_order = self.getLagrangeOrder(index);
      poly_r = model.shape.LagrangePolynom(l_order(1), self.order_(1), -1, 1);
      poly_s = model.shape.LagrangePolynom(l_order(2), self.order_(2), -1, 1);
      getValues_r(index) = ...
        poly_r.getValue(r)*poly_s.getValue(s);
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
    getDerivatives_r = zeros(2, self.getNodeAmount());
    for index = 1:length(getDerivatives_r)
      l_order = self.getLagrangeOrder(index);
      poly_r = model.shape.LagrangePolynom(l_order(1), self.order_(1), -1, 1);
      poly_s = model.shape.LagrangePolynom(l_order(2), self.order_(2), -1, 1);
      getDerivatives_r(1, index) = ...
        poly_r.getDerivative(r)*poly_s.getValue(s);
      getDerivatives_r(2, index) = ...
        poly_r.getValue(r)*poly_s.getDerivative(s);
    end    
  end
%-------------------------------------------------------------------------------
  function getPerimeterNodes_r = getPerimeterNodes(self)
    n = self.order_(1) + 1;
    m = self.order_(2) + 1;
    
    % counterclockwise
    corner_1 = 1;
    corner_2 = n;
    corner_3 = m*n;
    corner_4 = (m-1)*n+1;    
    
    bottom_edge = corner_1:+1:corner_2 - 1;
    right_edge  = corner_2:+n:corner_3 - n;
    top_edge    = corner_3:-1:corner_4 + 1;
    left_edge   = corner_4:-n:corner_1 + n;

    getPerimeterNodes_r = ...
      [bottom_edge, right_edge, top_edge, left_edge];
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
    p = nodenumber;
    n = self.order_(1) + 1;
    getLagrangeOrder_r = [mod((p-1),n), floor((p-1)/n)];
  end 
%-------------------------------------------------------------------------------    
  function getNodeAmount_r = getNodeAmount(self)
    getNodeAmount_r = (self.order_(1) + 1) * (self.order_(2) + 1);
  end   
%-------------------------------------------------------------------------------
end  

end



























