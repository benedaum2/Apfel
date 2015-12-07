classdef IntPoint < handle
  
%===============================================================================
properties (SetAccess = protected)
  ref_coords_
  weight_
end  


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% constructor
  function self = IntPoint(ref_coords, weight)
    self.ref_coords_ = ref_coords;
    self.weight_ = weight;
  end
%-------------------------------------------------------------------------------
  function getRefCoords_r = getRefCoords(self)
    getRefCoords_r = self.ref_coords_;
  end
%-------------------------------------------------------------------------------
  function getRefCoord_r = getRefCoord(self, dir)
    getRefCoord_r = self.ref_coords_(dir);
  end  
%-------------------------------------------------------------------------------
  function getWeight_r = getWeight(self)
    getWeight_r = self.weight_;
  end
%-------------------------------------------------------------------------------
end


end