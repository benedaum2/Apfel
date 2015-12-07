classdef OrthogonalDomain < model.integration.Integration
  
%===============================================================================
methods (Static, Access = public)
%-------------------------------------------------------------------------------  
  function getTable_r = getTable(order)
    switch order
      case 1
        r(1) =  0.000000000000000;
        w(1) =  2.000000000000000;
      case 2
        %r(1) = -0.577350269189626;
        r(1) = -sqrt(1/3);
        r(2) = -r(1);            
        
        w(1) =  1.000000000000000;  
        w(2) =  w(1);        
      case 3
        r(1) = -0.774596669241483;    
        r(2) =  0.000000000000000;
        r(3) = -r(1);
        
        w(1) =  0.555555555555555;
        w(2) =  0.888888888888888;
        w(3) =  w(1);
      case 4
        r(1) = -0.861136311594953;
        r(2) = -0.339981043584856;
        r(3) = -r(2);
        r(4) = -r(1);
        
        w(1) = 0.347854845137454;
        w(2) = 0.652145154862546;
        w(3) = w(2);
        w(4) = w(1);
      otherwise
        error('order not implemented');
    end
    getTable_r = [r; w];
  end
%-------------------------------------------------------------------------------
end

  
%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% constructor
  function self = OrthogonalDomain(order, dim)
    self@model.integration.Integration(order);
    switch dim
      case 1 
        self.createIntPoints1d(order)
      case 2
        self.createIntPoints2d(order)
      case 3
        self.createIntPoints3d(order)
    end
  end
%-------------------------------------------------------------------------------
  function getRefDomainFactor_r = getRefDomainFactor(self)
    getRefDomainFactor_r = 1;
  end
%-------------------------------------------------------------------------------  
end
  
%===============================================================================
methods (Access = private)  
%-------------------------------------------------------------------------------
  function createIntPoints1d(self, order)
    t  = self.getTable(order(1));
    r  = t(1,:);
    w  = t(2,:);
    self.int_points_ = cell(1, length(r));
    for index = 1:length(self.int_points_)
      self.int_points_{index} = ...
        model.integration.IntPoint(r(index), w(index));
    end    
  end
%-------------------------------------------------------------------------------
  function createIntPoints2d(self, order)
    ti = self.getTable(order(1));
    tj = self.getTable(order(2));
    r  = ti(1,:);
    wi = ti(2,:);
    s  = tj(1,:);
    wj = tj(2,:);
    self.int_points_ = cell(1, length(r)*length(s));
    for i = 1:length(r)
      for j = 1:length(s)
        self.int_points_{length(s)*(i-1)+j} = ...
          model.integration.IntPoint([r(i); s(j)], wi(i)*wj(j));
      end
    end
  end  
%-------------------------------------------------------------------------------
  function createIntPoints3d(self, order)
    table_i = self.getTable(order(1));
    table_j = self.getTable(order(2));
    table_k = self.getTable(order(3));        
    r  = table_i(1,:);
    wi = table_i(2,:);
    s  = table_j(1,:);
    wj = table_j(2,:);
    t  = table_k(1,:);
    wk = table_k(2,:);
    self.int_points_ = cell(1, length(r)*length(s)*length(t));
    l  = 1;
    for i = 1:length(r)
      for j = 1:length(s)
        for k = 1:length(t)
          self.int_points_{l} = ...
            model.integration.IntPoint([r(i); s(j); t(k)], wi(i)*wj(j)*wk(k));
          l = l + 1;
        end
      end
    end  
  end
%-------------------------------------------------------------------------------
end

end






















