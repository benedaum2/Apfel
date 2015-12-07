classdef Node < handle

%===============================================================================  
properties(Access = protected)
  number_
  mat_coords_;
  spa_coords_;
  associated_bcs_ = {};
  dimension_;
end


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = Node(number, mat_coords, spa_coords)
    if nargin == 2
      spa_coords = mat_coords;
    end
    self.number_ = number;
    self.mat_coords_ = mat_coords;
    self.spa_coords_ = spa_coords;
    self.dimension_ = length(mat_coords);  
  end
%-------------------------------------------------------------------------------    
% Clone
  function clone_r = clone(self)
    clone_r = model.Node(self.number_, self.mat_coords_, self.spa_coords_);
    for index = 1:length(self.associated_bcs_)
      clone_r.addBc(self.associated_bcs_{index});
    end
  end
%-------------------------------------------------------------------------------
  function addBc(self, bc)
    for bc_index = 1:length(self.associated_bcs_)
      compare_bc = self.associated_bcs_{bc_index};
      assert(compare_bc.getDirIndex() ~= bc.getDirIndex(), ...
        strcat('conflicting boundary conditions,', ...
          'bc: ', num2str(bc_index), ...
          '->bc: ', num2str(bc.getNumber())));
    end
    self.associated_bcs_{length(self.associated_bcs_) + 1} = bc;
  end
%-------------------------------------------------------------------------------
  function getBc_r = getBc(self, dir_index)
    getBc_r = 0;
    for bc_index = 1:length(self.associated_bcs_)
      bc = self.associated_bcs_{bc_index};
      if bc.getDirIndex() == dir_index
        getBc_r = bc;
      end
    end    
  end
%-------------------------------------------------------------------------------
  function getNumber_r = getNumber(self)
    getNumber_r = self.number_;
  end
%-------------------------------------------------------------------------------
  function getMatCoord_r = getMatCoord(self, dir_index)
    getMatCoord_r = self.mat_coords_(dir_index);
  end
%-------------------------------------------------------------------------------
  function getMatCoords_r = getMatCoords(self)
    getMatCoords_r = self.mat_coords_;
  end  
%-------------------------------------------------------------------------------
  function getSpaCoord_r = getSpaCoord(self, dir_index)
    getSpaCoord_r = self.spa_coords_(dir_index);
  end
%-------------------------------------------------------------------------------  
  function getSpaCoords_r = getSpaCoords(self)
    getSpaCoords_r = self.spa_coords_;
  end   
%-------------------------------------------------------------------------------
  function getDimension_r = getDimension(self)
    getDimension_r = self.dimension_;
  end
%-------------------------------------------------------------------------------
  function addToSpatial(self, u, dir_index)
    self.spa_coords_(dir_index) = self.spa_coords_(dir_index) + u;
  end
%-------------------------------------------------------------------------------
  function setSpaCoord(self, spa_coord, dir_index)
    self.spa_coords_(dir_index) = spa_coord;
  end  
%-------------------------------------------------------------------------------
  function setMaterialToSpatial(self)
    self.mat_coords_ = self.spa_coords_;
  end  
%-------------------------------------------------------------------------------
  function drawNumber(self)
    pos = [self.mat_coords_(1:2), 0];
    text('Position', pos, 'String', [' ', num2str(self.number_)], ...
      'Color', 'blue');
  end
%-------------------------------------------------------------------------------
end
  
  
end









