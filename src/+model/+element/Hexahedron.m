classdef Hexahedron < model.element.Volume
% defines a spatial hexahedron element
  
%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------
% Constructor
  function self = Hexahedron(number, nodes, et, mat)
    self@model.element.Volume(number, nodes, et, mat);   
    assert(isfield(et, 'el_order'), ...
      'no element order specified');
    self.order_ = et.el_order;    
    s_handle    = str2func(strcat('model.shape.', et.shape));
    self.shape_ = s_handle(self.order_);
    assert(isfield(et, 'int_order'), ...
      'no integration order specified');
    assert(length(et.int_order) == 3, ...
      'specify integration order in all directions')
    assert(all(et.int_order >= self.order_), ...
     'integration order has to be equal or greater than the element order');
    self.integration_ = ...
      model.integration.OrthogonalDomain(et.int_order, self.dim_);
  end
%-------------------------------------------------------------------------------
end

end