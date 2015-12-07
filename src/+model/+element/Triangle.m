classdef Triangle < model.element.Plate
% defines a plane triangle element
  
%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------
% Constructor
  function self = Triangle(number, nodes, et, mat)
    self@model.element.Plate(number, nodes, et, mat);
    assert(isfield(et, 'el_order'), ...
      'no element order specified');
    assert(length(et.el_order) == 1, ...
      'specify exactly one element order')
    self.order_ = et.el_order;
    s_handle    = str2func(strcat('model.shape.', et.shape));
    self.shape_ = s_handle(self.order_);
    assert(isfield(et, 'int_order'), ...
      'no integration order specified');
    assert(length(et.int_order) == 1, ...
      'specify exactly one integration order')
    assert(et.int_order >= self.order_, ...
      'integration order has  to be equal or greater than the element order');
    self.integration_ = model.integration.TriangularDomain(et.int_order);
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