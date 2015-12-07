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

classdef Increment < handle
%===============================================================================
properties( SetAccess = protected )
  number_
  model_ 
  delta_time_ % time differenve to previous increment
  time_       % total time
  k_glo_      % stores k_glo_ so it doesnot have to be calculatet more 
              % then once. use assembleKGlobal() to recalculate and 
              % getKGlobal() to retrieve
  u_hat_
end


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor      
  function self = Increment(number, model, delta_time, time)
    self.number_      = number;
    self.model_       = model;
    self.delta_time_  = delta_time;
    self.time_        = time;
  end
%-------------------------------------------------------------------------------
  function time = getTime(self)
    time = self.time_;
  end  
%-------------------------------------------------------------------------------
  function model = getModel(self)
    model = self.model_;
  end  
%-------------------------------------------------------------------------------
% access member k_glo_ without recalculation
  function getKGlobal_r = getKGlobal(self)
    getKGlobal_r = self.k_glo_;
  end
%-------------------------------------------------------------------------------
% assemble u_hat_
  function getUHat_r = getUHat(self)
    dim         = self.model_.getDim();
    self.u_hat_ = zeros(dim*self.model_.getNodeAmount(), 1);
    for node_index = 1:self.model_.getNodeAmount()
      node = self.model_.getNode(node_index);
      for dir_index = 1:dim
        hat_index = (node_index - 1)*dim + dir_index;
        self.u_hat_(hat_index) = ...
          node.getSpaCoord(dir_index) - node.getMatCoord(dir_index);
      end
    end
    getUHat_r = self.u_hat_;
  end  
%-------------------------------------------------------------------------------
% assemble k_glo_ from the stiffness matrices of the individual elements
  function assembleKGlobal(self)
    dim         = self.model_.getDim();
    self.k_glo_ = zeros(dim*self.model_.getNodeAmount());

    for el_index = 1:self.model_.getElementAmount()
      element   = self.model_.element_cell_{el_index};
      k_loc     = element.getK();
      
      for row_index = 1:element.getNodeAmount()
        loc_row_skip = (row_index - 1)*dim;
        glo_row_skip = (element.getNode(row_index).getNumber() - 1)*dim;
        for col_index = 1:element.getNodeAmount()
          loc_col_skip = (col_index - 1)*dim;
          glo_col_skip = (element.getNode(col_index).getNumber() - 1)*dim;
          self.k_glo_(glo_row_skip + 1:glo_row_skip + dim, ...
                      glo_col_skip + 1:glo_col_skip + dim) ...
          = ...
          self.k_glo_(glo_row_skip + 1:glo_row_skip + dim, ...
                      glo_col_skip + 1:glo_col_skip + dim) ...                      
          + ...
          k_loc      (loc_row_skip + 1:loc_row_skip + dim, ...
                      loc_col_skip + 1:loc_col_skip + dim);
        end
      end
    end    
    % disp(horzcat(class(self), '/k_glo_ assembled ...'));    
  end  
%-------------------------------------------------------------------------------
% assemble external force vector
  function F_ext = assembleFExt(self)
    dim             = self.model_.getDim;
    F_ext = zeros(dim*self.model_.getNodeAmount(), 1);

    for node_index = 1:self.model_.getNodeAmount()
      node = self.model_.getNode(node_index);
      for dir_index = 1:dim
        bc = node.getBc(dir_index);
        if bc == 0
          continue;
        end        
        if bc.getType == bc.NEUMANN_
          F_ext((node_index - 1)*dim + dir_index) = ...
            bc.getCurrent(self.time_);
        end
      end
    end
  end
%-------------------------------------------------------------------------------
% assemble external displacement vector (nodes with dirichlet bcs)
  function u_ext = assembleUExt(self)
    dim             = self.model_.getDim;
    u_ext  = zeros(dim*self.model_.getNodeAmount(), 1);
    
    for node_index = 1:self.model_.getNodeAmount()
      node = self.model_.getNode(node_index);
      for dir_index = 1:dim
        bc = node.getBc(dir_index);
        if bc == 0
          continue;
        end          
        if bc.getType == bc.DIRICHLET_
          u_ext((node_index - 1)*dim + dir_index) = ...
            bc.getCurrent(self.delta_time_);
        end
      end
    end
  end
%-------------------------------------------------------------------------------
% insert rows with dirichlet bcs to argument vector.
  function vector_r = insertDirichlet(self, vector)
    dim             = self.model_.getDim;
    vector_r  = zeros(dim*self.model_.getNodeAmount(), 1);
    v_index   = 1;    
    
    for node_index = 1:self.model_.getNodeAmount()
      node      = self.model_.getNode(node_index);
      for dir_index = 1:dim
        r_skip    = (node_index - 1)*dim;
        bc        = node.getBc(dir_index);
        if (bc == 0 || bc.getType == bc.NEUMANN_)
          vector_r(r_skip + dir_index) = vector(v_index);
          v_index = v_index + 1;
        elseif bc.getType == bc.DIRICHLET_
          vector_r(r_skip + dir_index) = bc.getCurrent(self.delta_time_);         
        end
      end
    end
  end
%-------------------------------------------------------------------------------
% remove rows/cols with dirichlet bcs from argument object. 
% for both vector and matrix
  function obj = removeDirichlet(self, obj)
    dim             = self.model_.getDim;

    % reverse iteration
    for node_index = self.model_.getNodeAmount():-1:1
      node = self.model_.getNode(node_index);
      for dir_index = dim:-1:1
        bc = node.getBc(dir_index);
        if bc == 0
          continue;
        end
        if bc.getType == bc.DIRICHLET_
          obj((node_index - 1)*dim + dir_index, :) =  [];      
          if size(obj, 2) ~= 1
            obj(:, (node_index - 1)*dim + dir_index) =  [];         
          end
        end
      end
    end
  end  
%-------------------------------------------------------------------------------
% update nodal spatial configuration
  function addToSpatial(self, u_hat)
    dim             = self.model_.getDim;
   
    for node_index = 1:self.model_.getNodeAmount()
      node = self.model_.getNode(node_index);
      for dir_index = 1:dim
        hat_index = (node_index - 1)*dim + dir_index;
        node.addToSpatial(u_hat(hat_index), dir_index);
      end
    end
  end
%-------------------------------------------------------------------------------
end

%===============================================================================
methods (Abstract, Access = public)
  solve(self)
end

end











