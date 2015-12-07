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

classdef Model < model.Model
%===============================================================================
properties( SetAccess = protected )
  plast_pt_cell_ = {};  
end
  

%===============================================================================
methods
%-------------------------------------------------------------------------------    
% Constructor      
  function self = Model(dim)
    self@model.Model(dim);
  end
%-------------------------------------------------------------------------------
  function linkTo(self, model)   
    for no_index = 1:self.getNodeAmount()
      for dir_index = 1:self.dim_
        spa_coord = model.getNode(no_index).getSpaCoord(dir_index);
        self.getNode(no_index).setSpaCoord(spa_coord, dir_index);
      end
    end
    for el_index = 1:self.getElementAmount()
      self.getElement(el_index). ...
        linkTo(model.getElement(el_index));
    end
    for pp_index = 1:self.getPlasticityPointAmount()
      self.getPlasticityPoint(pp_index). ...
        linkTo(model.getPlasticityPoint(pp_index));
    end    
  end  
%-------------------------------------------------------------------------------
  function addElement(self, element)
    addElement@model.Model(self, element)
    for index = 1:element.getIntPointAmount()
      self.plast_pt_cell_{end + 1} = element.getPlasticityPoint(index);
    end
  end 
%-------------------------------------------------------------------------------  
  function pl_pt = getPlasticityPoint(self, num)
    pl_pt = self.plast_pt_cell_{num};
  end
%-------------------------------------------------------------------------------
  function pl_pt_amount = getPlasticityPointAmount(self)
    pl_pt_amount = length(self.plast_pt_cell_);
  end
%-------------------------------------------------------------------------------
end

%===============================================================================
methods( Access = protected )
%-------------------------------------------------------------------------------
  function addPlasticityPoint(self, plast_pt)
    self.plast_pt_cell_{self.getPlasticityPointAmount() + 1} = plast_pt;
  end 
%-------------------------------------------------------------------------------  
end

end



























