classdef Hexahedron < model.element.Hexahedron & plasticity.element.Element

%===============================================================================
properties (SetAccess = protected)
end

%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = Hexahedron(number, nodes, et, mat, flow_rule)
    self@model.element.Hexahedron(number, nodes, et, mat);
    self@plasticity.element.Element(flow_rule);
    for index = 1:self.getIntPointAmount()
      int_point = self.getIntPoint(index);
      self.plast_pts_{index} = ...
        plasticity.PlasticityPoint(index, self, int_point);
    end    
  end
%-------------------------------------------------------------------------------
  function k = getK(self)
    k = zeros(self.dim_ * length(self.nodes_));
    int_points = self.integration_.getIntPoints;
    f = self.integration_.getRefDomainFactor();
    
    for index = 1:length(int_points)
      int_point   = int_points{index};
      ref_coords  = int_point.getRefCoords();
      pp          = self.getPlasticityPoint(index);      
      c_con       = pp.getCCon();
      w_i         = int_point.getWeight();
      b           = getB(self, ref_coords);
      det_j       = getDetJ(self, ref_coords);    
      
      k = k + f * w_i * ( b' * c_con * b * det_j );
    end
  end
%-------------------------------------------------------------------------------
  function f_int = getFInt(self)
    f_int         = zeros(self.dim_ * length(self.nodes_), 1);
    int_points    = self.integration_.getIntPoints;
    f             = self.integration_.getRefDomainFactor();
    
    for index = 1:length(int_points)
      int_point   = int_points{index};
      ref_coords  = int_point.getRefCoords();
      w_i         = int_point.getWeight();
      b           = self.getB(ref_coords);
      pp          = self.getPlasticityPoint(index);
      sig_n1      = pp.getSigN1();
      det_j       = getDetJ(self, ref_coords);      
      
      f_int = f_int + f * w_i * ( b' * sig_n1 * det_j);
    end
  end  
%-------------------------------------------------------------------------------  
end

end
































