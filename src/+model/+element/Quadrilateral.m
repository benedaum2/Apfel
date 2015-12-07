classdef Quadrilateral < model.element.Plate
% defines a plane quadrilateral element
  
%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------
% Constructor
  function self = Quadrilateral(number, nodes, et, mat)
    self@model.element.Plate(number, nodes, et, mat);   
    assert(isfield(et, 'el_order'), ...
      'no element order specified');
    self.order_ = et.el_order;    
    s_handle    = str2func(strcat('model.shape.', et.shape));
    self.shape_ = s_handle(self.order_);
    assert(isfield(et, 'int_order'), ...
      'no integration order specified');
    assert(length(et.int_order) == 2, ...
      'specify integration order in both directions')
    assert(all(et.int_order >= self.order_), ...
     'integration order has to be equal or greater than the element order');
    if isfield(et, 'newton_cotes') && et.newton_cotes == 1
      self.integration_ = ...
        model.integration.NewtonCotes(et.int_order, self.dim_);      
    else   
      self.integration_ = ...
        model.integration.OrthogonalDomain(et.int_order, self.dim_);
    end
  end
%-------------------------------------------------------------------------------
end


%===============================================================================
methods (Access = private)
%-------------------------------------------------------------------------------
%   function xxx(self, xxx)
%   end
%-------------------------------------------------------------------------------
end


end