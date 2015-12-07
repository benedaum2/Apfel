classdef TriangularDomain < model.integration.Integration

%===============================================================================
methods (Static, Access = public)
%-------------------------------------------------------------------------------  
  function getTable_r = getTable(order)
    switch order
      case 1
        r(1) = 0.3333333333333;
        s(1) = 0.3333333333333;
        w(1) = 1.0000000000000;
      case 2
        r(1) = 0.1666666666667; 
        r(2) = 0.6666666666667; 
        r(3) = r(1);            
        
        s(1) = r(1); w(1) = 0.3333333333333;  
        s(2) = r(1); w(2) = w(1);        
        s(3) = r(2); w(3) = w(1);
      case 3
        r(1) = 0.1012865073235;
        r(2) = 0.7974269853531;
        r(3) = r(1);           
        r(4) = 0.4701420641051;
        r(5) = r(4);           
        r(6) = 0.0597158717898;
        r(7) = 0.3333333333333;
        
        s(1) = r(1); w(1) = 0.1259391805448; 
        s(2) = r(1); w(2) = w(1);        
        s(3) = r(2); w(3) = w(1);        
        s(4) = r(6); w(4) = 0.1323941527885;
        s(5) = r(4); w(5) = w(4);
        s(6) = r(4); w(6) = w(4);        
        s(7) = r(7); w(7) = 0.2250000000000; 
      case 99
        r(1) = 0.0000000000000;         
        r(2) = 0.5000000000000; 
        r(3) = r(2);
        
        s(1) = r(2); w(1) = 0.3333333333333;  
        s(2) = r(2); w(2) = w(1);        
        s(3) = r(1); w(3) = w(1);        
      otherwise
        error('order not implemented');
    end
    getTable_r = [r; s; w];
  end
%-------------------------------------------------------------------------------
end

  
%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% constructor
  function self = TriangularDomain(order)
    self@model.integration.Integration(order);
    t = self.getTable(order);
    r = t(1,:);
    s = t(2,:);
    w = t(3,:);
    self.int_points_ = cell(1, length(r));
    for index = 1:length(self.int_points_)
      self.int_points_{index} = ...
        model.integration.IntPoint( [r(index); s(index)], w(index));
    end
  end
%-------------------------------------------------------------------------------
  function getRefDomainFactor_r = getRefDomainFactor(self)
    getRefDomainFactor_r = 0.5;
  end
%-------------------------------------------------------------------------------
end


end