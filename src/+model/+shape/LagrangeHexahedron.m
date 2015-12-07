classdef LagrangeHexahedron < model.shape.Shape
%===============================================================================  
%
%                                                               <mnk>  
%         o--------o--------o--- ... --------o--------o--------o
%        /                                                    /|(n-1,m-1,k-1)
%      ...                                                  ...|
%      /                                                    /  |
%     o                                                    o
%    /                                                    (n-1,m-1,0)
%   o--------o--------o--- ... --------o--------o--------o
%   |<mn+m>                                              |<mn>
%   |                                                    |
%   |                                                    |
%                            (mod(p-1,n),floor(p-1/n),0)                           
%  ...                      o                           ...
%                            <q>
%   |(0,2,0)  (1,2,0)  (2,2,0)                           |
%   o        o        o                                  o
%   |<2n+1>   <2n+2>   <2n+3>                            |<3n>
%   |                                                    |
%   |(0,1,0)  (1,1,0)  (2,1,0)                           |(n-1,1,0)
%   o        o        o                                  o
%   |<1n+1>   <1n+2>   <1n+3>                            |<2n>
%   |                                                    |
%   |(0,0,0)  (1,0,0)  (2,0,0)                           |(n-1,0,0)
%   o--------o--------o--- ... --------o--------o--------o  
%    <0n+1>   <0n+2>   <0n+3>                             <1n>
%
%    <>  ... nodenumber
%    ()  ... lagrangeorder
%    n-1 ... self.order_(1)
%    m-1 ... self.order_(2)
%    k-1 ... self.order_(3)
%
%===============================================================================  
properties(Constant)

end   
    
  
%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = LagrangeHexahedron(order)
    self@model.shape.Shape(3, order);
    assert(length(order) == 3, ...
      'specify element order in all directions')
    self.order_ = order;
  end
%-------------------------------------------------------------------------------
% getValues_r = [h_1 h_2 ... h_q];
  function getValues_r = getValues(self, ref_coords)
    r             = ref_coords(1);
    s             = ref_coords(2);
    t             = ref_coords(3);
    getValues_r   = zeros(1, self.getNodeAmount());
    for index = 1:length(getValues_r)
      l_order = self.getLagrangeOrder(index);
      poly_r = model.shape.LagrangePolynom(l_order(1), self.order_(1), -1, 1);
      poly_s = model.shape.LagrangePolynom(l_order(2), self.order_(2), -1, 1);
      poly_t = model.shape.LagrangePolynom(l_order(3), self.order_(3), -1, 1);
      getValues_r(index) = ...
        poly_r.getValue(r)*poly_s.getValue(s)*poly_t.getValue(t);
    end
  end
%-------------------------------------------------------------------------------
% getDerivatives_r = ...
% = [dh_1/dr dh_2/dr ... dh_q/dr; 
%    dh_1/ds dh_2/ds ... dh_q/ds;
%    dh_1/dt dh_2/dt ... dh_q/dt]
  function getDerivatives_r = getDerivatives(self, ref_coords)
    r                 = ref_coords(1);
    s                 = ref_coords(2);
    t                 = ref_coords(3);
    getDerivatives_r  = zeros(3, self.getNodeAmount());
    for index = 1:length(getDerivatives_r)
      l_order = self.getLagrangeOrder(index);
      poly_r = model.shape.LagrangePolynom(l_order(1), self.order_(1), -1, 1);
      poly_s = model.shape.LagrangePolynom(l_order(2), self.order_(2), -1, 1);
      poly_t = model.shape.LagrangePolynom(l_order(3), self.order_(3), -1, 1);      
      getDerivatives_r(1, index) = ...
        poly_r.getDerivative(r)*poly_s.getValue(s)*poly_t.getValue(t);
      getDerivatives_r(2, index) = ...
        poly_r.getValue(r)*poly_s.getDerivative(s)*poly_t.getValue(t);
      getDerivatives_r(3, index) = ...
        poly_r.getValue(r)*poly_s.getValue(s)*poly_t.getDerivative(t);
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
  function getLagrangeOrder_r = getLagrangeOrder(self, nodenumber)
    p = nodenumber;
    n = self.order_(1) + 1;
    m = self.order_(2) + 1;
    
    q = mod(p-1, n*m) + 1; % node number for k = 1
    a = mod((q-1), n);
    b = floor((q-1)/n);
    c = floor((p-1)/(n*m));
    %getLagrangeOrder_r = [a, b, c];
    getLagrangeOrder_r = [a, b, c];

%     switch nodenumber
%       case 1
%         getLagrangeOrder_r = [0, 0, 1];
%       case 2
%         getLagrangeOrder_r = [1, 0, 1];
%       case 3
%         getLagrangeOrder_r = [0, 1, 1];
%       case 4
%         getLagrangeOrder_r = [1, 1, 1];
%       case 5
%         getLagrangeOrder_r = [0, 0, 0];
%       case 6
%         getLagrangeOrder_r = [1, 0, 0];
%       case 7
%         getLagrangeOrder_r = [0, 1, 0];
%       case 8
%         getLagrangeOrder_r = [1, 1, 0];          
%     end
  end 
%-------------------------------------------------------------------------------    
  function getNodeAmount_r = getNodeAmount(self)
    getNodeAmount_r = ...
      (self.order_(1) + 1) * (self.order_(2) + 1) * (self.order_(3) + 1);
  end   
%-------------------------------------------------------------------------------
end  

end



























