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

classdef IncrementPlasticity < analysis.Increment
%===============================================================================
properties( SetAccess = protected, Constant )
  EPSILON_ = 1E-15;
end
  
%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor      
  function self = IncrementPlasticity(number, model, delta_time, time)
    self@analysis.Increment(number, model, delta_time, time);
  end
%-------------------------------------------------------------------------------
  function [success, updated_model] = solve(self)
    disp(horzcat(class(self), ' ===', num2str(self.number_), '==='));

    f_ext       = self.assembleFExt();
%     if any(f_ext ~= zeros(size(f_ext)))
%       disp(horzcat(class(self), '/warning: ~~~neumann bcs ~= 0 detected~~~'));
%     end
    

    u_ext       = self.assembleUExt();
    self.addToSpatial(u_ext);
      
    
    format compact;
    
    if self.number_ == 1 % first step linear
    for pp_index = 1:self.model_.getPlasticityPointAmount()
      pp = self.model_.getPlasticityPoint(pp_index);  
      pp.addProportionate();
    end
    f_int       = self.assembleFInt();
    self.equilibrate(f_int, f_ext);  
    end
    
    iteration   = 0;
    iterate     = 1;
    e_unb       = +inf;        

    
    while ( iterate )
      iteration   = iteration + 1;
      disp(horzcat(class(self), ' ---', num2str(iteration), '--- '));
           
      self.generalReturn();        
      f_int       = self.assembleFInt();
      
      e_unb_old   = e_unb;
      e_unb       = self.equilibrate(f_int, f_ext);

      disp(horzcat(class(self), ' log10(e_unb): ', num2str(log10(abs(e_unb)), '%2.2f')));
      
      if abs(e_unb_old) <= abs(e_unb)
        updated_model = self.model_;
        success     = 0;        
        return;
      end

      if abs(e_unb) < self.EPSILON_
        iterate     = 0;
      end      
      
    end   
       
    updated_model = self.model_;
    success     = 1;
  end 
%-------------------------------------------------------------------------------
% assemble f_int from the individual elements
  function f_int = assembleFInt(self)   
    dim         = self.model_.getDim();
    f_int       = zeros(dim*self.model_.getNodeAmount(), 1);

    for el_index = 1:self.model_.getElementAmount()
      element   = self.model_.getElement(el_index);
      f_loc     = element.getFInt();
      
      for row_index = 1:element.getNodeAmount()
        loc_row_skip = (row_index - 1)*dim;
        glo_row_skip = (element.getNode(row_index).getNumber() - 1)*dim;
        f_int (glo_row_skip + 1:glo_row_skip + dim) ...
        = ...
        f_int (glo_row_skip + 1:glo_row_skip + dim) ...
        + ...
        f_loc (loc_row_skip + 1:loc_row_skip + dim);
      end
    end
  end
%-------------------------------------------------------------------------------
% insert zeros for rows with dirichlet bcs to argument vector.
  function vector = insertZeros(self, vector)
    u_ext       = self.assembleUExt();   
    vector      = self.insertDirichlet(vector) - u_ext;
  end
%-------------------------------------------------------------------------------

end

%===============================================================================
methods (Access = protected)
%-------------------------------------------------------------------------------  
  function generalReturn(self)
    for pp_index = 1:self.model_.getPlasticityPointAmount()
      pp = self.model_.getPlasticityPoint(pp_index); 
      pp.generalReturn();
    end  
  end
%-------------------------------------------------------------------------------
  function e_unb = equilibrate(self, f_int, f_ext)
    self.assembleKGlobal();
    k           = self.getKGlobal();
    k_reg       = self.removeDirichlet(k);

    psi         = f_int - f_ext;
    psi_reg     = self.removeDirichlet(psi);

    delta_u_reg = - k_reg \ psi_reg;
    %delta_u_reg = 0;

    delta_u     = self.insertZeros(delta_u_reg);
    self.addToSpatial(delta_u);
    e_unb       = delta_u_reg' * psi_reg;
  end  
%-------------------------------------------------------------------------------
end

end
























