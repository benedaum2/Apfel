classdef NewtonCotes < model.integration.Integration
  
%===============================================================================
methods (Static, Access = public)
%-------------------------------------------------------------------------------  
  function getTable_r = getTable(order)
    r = -1:2/order:1;
    switch order
      case 1
        w(1) =  1;
        w(2) =  1;
      case 2
        w(1) =  1/3;
        w(2) =  4/3;
        w(3) =  1/3;
      case 3
        w(1) =  1/4;
        w(2) =  3/4;
        w(3) =  3/4;
        w(4) =  1/4;
      case 4       
        w(1) =  7/45;
        w(2) = 32/45;
        w(3) = 12/45;
        w(4) = 32/45;
        w(5) =  7/45;
      case 5
        w(1) = 19/144;
        w(2) = 75/144;
        w(3) = 50/144;
        w(4) = 50/144;
        w(5) = 75/144;
        w(6) = 19/144;
      case 6
        w(1) =  41/420;
        w(2) = 216/420;
        w(3) =  27/420;
        w(4) = 272/420;
        w(5) =  27/420;
        w(6) = 216/420;
        w(7) =  41/420;
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
  function self = NewtonCotes(order, dim)
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






















