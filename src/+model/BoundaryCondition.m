classdef BoundaryCondition < handle

%===============================================================================
properties (Constant)
  FREE_ = 'f'
  DIRICHLET_ = 'd';
  NEUMANN_ = 'n';  
end  
  
  
%===============================================================================
properties (SetAccess = protected)
  number_;
  node_;
  type_; 
  dir_;           % one of 'x', 'y', 'z'
  final_;
end  


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------
% Constructor
  function self = BoundaryCondition(number, node, type, dir, final)
    self.number_  = number;
    self.node_    = node;   
    self.type_    = type;
    self.dir_     = dir;
    self.final_   = final;
  end
%-------------------------------------------------------------------------------
  function getNumber_r = getNumber(self)
    getNumber_r = self.number_;
  end
%-------------------------------------------------------------------------------
  function getNode_r = getNode(self)
    getNode_r = self.node_;
  end  
%-------------------------------------------------------------------------------
  function getType_r = getType(self)
    getType_r = self.type_;
  end
%-------------------------------------------------------------------------------
  function getDirIndex_r = getDirIndex(self)
    switch self.dir_ 
      case 'x'
        getDirIndex_r = 1;
      case 'y'
        getDirIndex_r = 2;
      case 'z'
        getDirIndex_r = 3;
      otherwise
        error('corrupt boundary condition')
    end
  end  
%-------------------------------------------------------------------------------
  function current_r = getCurrent(self, time)
    assert(time > 0 && time <= 1, 'timeintervall is (0, 1]');
    current_r = self.final_*time;
  end  
%-------------------------------------------------------------------------------
  function draw(self, size) 
    if self.type_ == self.DIRICHLET_
      color = 'r';
    elseif self.type_ == self.NEUMANN_
      color = 'b';
    else
      error('corrupt boundary condition')
    end    
    
    patch_coords = 0;
    coords = self.node_.getMatCoords()';
    coords = coords(1:2); %only for 2d
    switch self.dir_ 
      case 'x'
        patch_coords = [ ...
          coords, ...
          coords - [(sqrt(3)/2)*size; (1/2)*size], ...
          coords - [(sqrt(3)/2)*size;-(1/2)*size]  ]';        
      case 'y'  
        patch_coords = [ ...
          coords, ...
          coords - [ (1/2)*size; (sqrt(3)/2)*size], ...
          coords - [-(1/2)*size; (sqrt(3)/2)*size]  ]';      
    end
    if any(any(patch_coords ~= 0))
      patch(patch_coords(:, 1), patch_coords(:, 2), zeros(3, 1), ...
      'FaceColor', color, 'EdgeColor', color);
    end
  end  
%-------------------------------------------------------------------------------
end

end































