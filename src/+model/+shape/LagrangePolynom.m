classdef LagrangePolynom < handle

%===============================================================================  
% properties(Access = private)
properties
  order_
  index_
  a_ % lower boundary of the reference intervall
  b_ % upper boundary of the reference intervall
  supporting_points_
end  
    
  
%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
% create a LaGrange Polynom with equal distributed supporting points
  function self = LagrangePolynom(subscript, superscript, a, b)
    assert(subscript <= superscript, 'index has to be less or equal to order');
    self.index_             = subscript;
    self.order_             = superscript;
    node_spacing            = (b - a)/self.order_;
    self.supporting_points_ = a:node_spacing:b;
    self.a_                 = a;
    self.b_                 = b;
  end
%-------------------------------------------------------------------------------
  function getValue_r = getValue(self, xi)
    getValue_r = 1;
    for count = 1:length(self.supporting_points_)
      if (count ~= self.index_ + 1)
        getValue_r = getValue_r * ...
          (xi - self.supporting_points_(count)) /...
          (self.supporting_points_(self.index_ + 1) - self.supporting_points_(count));
      end
    end    
  end
%-------------------------------------------------------------------------------  
  function getDerivative_r = getDerivative(self, xi) 
    independent_part = 1;
    for ind_count = 1:length(self.supporting_points_)
      if (ind_count ~= self.index_ + 1)
        independent_part = independent_part * 1/...
          (self.supporting_points_(self.index_ + 1) - self.supporting_points_(ind_count));
      end
    end 
    dependent_part = 0;
    for dep_count = 1:length(self.supporting_points_)
      if (dep_count ~= self.index_ + 1)
        product = 1;
        for prod_count = 1:self.order_ + 1
          if (prod_count ~= self.index_ + 1) && (prod_count ~= dep_count)
            product = product * (xi - self.supporting_points_(prod_count));
          end
        end
        dependent_part = dependent_part + product;
      end
    end
    getDerivative_r = independent_part * dependent_part;
  end
%-------------------------------------------------------------------------------    
end

end



























