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

classdef IncrementLinear < analysis.Increment

  
%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor      
  function self = IncrementLinear(model)
    self@analysis.Increment(1, model, 1, 1);
  end
%-------------------------------------------------------------------------------
  function updated_model = solve (self)
    
    disp('IncrementLinear/requesting K ...')
    self.assembleKGlobal()
    k_glo = self.getKGlobal();
    k_reg = self.removeDirichlet(k_glo);
    
    disp('IncrementLinear/requesting F ...')
    f_ext = self.assembleFExt();
    u_ext = self.assembleUExt();
    f_reg = self.removeDirichlet(f_ext - k_glo*u_ext);
    
    disp('IncrementLinear/solving ...')
    u_reg = k_reg \ f_reg;
    
    disp('IncrementLinear/updating ...')
    u_hat = self.insertDirichlet(u_reg);
    self.addToSpatial(u_hat);
    
    updated_model = self.model_;
  end 
%-------------------------------------------------------------------------------

end

end

















