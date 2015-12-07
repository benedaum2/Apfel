% ------------------------------------------------------------------
% This file is part of SOOFEAM -
%         Software for Object Oriented Finite Element Analysis in Matlab.
%
% SOOFEAM is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% SOOFEAM is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with SOOFEAM.  If not, see <http://www.gnu.org/licenses/>.
% ------------------------------------------------------------------

classdef Model < handle
%===============================================================================
properties( SetAccess = protected )
  dim_;
  node_cell_ = {};
  element_type_cell_ = {};  
  element_cell_ = {};
  material_cell_ = {};
  bc_cell_ = {};
  dirichlet_bc_cell_ = {};
  neumann_bc_cell_ = {};
end
  

%===============================================================================
methods
%-------------------------------------------------------------------------------    
% Constructor      
  function self = Model(dim)
    self.dim_ = dim;
  end
%-------------------------------------------------------------------------------
  function addNode( self, node )
    self.node_cell_{node.getNumber()} = node;
  end
%-------------------------------------------------------------------------------
  function addElementType(self, et)
    self.element_type_cell_{et.number} = et;
  end
%-------------------------------------------------------------------------------
  function addElement(self, element)
    self.element_cell_{element.getNumber()} = element;
  end
%-------------------------------------------------------------------------------
  function addMaterial(self, mat)
    self.material_cell_{mat.number} = mat;
  end
%-------------------------------------------------------------------------------
  function addBc(self, bc)
    self.bc_cell_{bc.getNumber()} = bc;
    if bc.getType == bc.DIRICHLET_
      self.dirichlet_bc_cell_{end + 1} = bc;
    elseif bc.getType == bc.NEUMANN_
      self.neumann_bc_cell_{end + 1} = bc;
    end
  end
%-------------------------------------------------------------------------------
  function dim = getDim(self)
    dim = self.dim_;
  end
%-------------------------------------------------------------------------------
  function node = getNode(self, number)
    node = self.node_cell_{number};
  end
%-------------------------------------------------------------------------------
  function node_amount = getNodeAmount(self)
    node_amount = length(self.node_cell_);
  end
%-------------------------------------------------------------------------------       
  function element = getElement(self, number)
    element = self.element_cell_{number};
  end
%-------------------------------------------------------------------------------
  function element_amount = getElementAmount(self)
    element_amount = length(self.element_cell_);
  end
%-------------------------------------------------------------------------------    
  function element_type = getElementType(self, number)
    element_type = self.element_type_cell_{number};
  end
%-------------------------------------------------------------------------------
  function mat = getMaterial(self, number)
    mat = self.material_cell_{number};
  end
%-------------------------------------------------------------------------------
  function bc = getBc(self, number)
    bc = self.bc_cell_{number};
  end
%-------------------------------------------------------------------------------
  function bc_amount = getBcAmount(self)
    bc_amount = length(self.bc_cell_);
  end
%-------------------------------------------------------------------------------
  function bc = getDirichletBc(self, number)
    bc = self.dirichlet_bc_cell_{number};
  end
%-------------------------------------------------------------------------------
  function bc_amount = getDirichletBcAmount(self)
    bc_amount = length(self.dirichlet_bc_cell_);
  end
%-------------------------------------------------------------------------------
  function bc = getNeumannBc(self, number)
    bc = self.neumann_bc_cell_{number};
  end
%-------------------------------------------------------------------------------
  function bc_amount = getNeumannBcAmount(self)
    bc_amount = length(self.neumann_bc_cell_);
  end    
%-------------------------------------------------------------------------------
end

end



























