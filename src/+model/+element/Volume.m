classdef Volume < model.element.Element
% Base class for all spatial elements

%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = Volume(number, nodes, et, mat)
    self@model.element.Element(number, nodes, et, mat, 3);
  end
%-------------------------------------------------------------------------------
  function getC_r = getC(self)
    E     = self.mat_.E;
    nu    = self.mat_.nu;
    G     = E/(2 + 2*nu);
    rho   = nu/(1 - 2*nu);
    rho_1 = rho + 1;
    
    C = 2*G * [
      rho_1 rho   rho   0   0   0;
      rho   rho_1 rho   0   0   0;
      rho   rho   rho_1 0   0   0;
      0     0     0     1/2 0   0;
      0     0     0     0   1/2 0;
      0     0     0     0   0   1/2;
    ];
    getC_r = C;
  end
%-------------------------------------------------------------------------------
% B = 
% = [ ... , dh_i/dx,       0,       0, ...
%     ... ,       0, dh_i/dy,       0, ...
%     ... ,       0,       0, dh_i/dz, ... 
%     ... , dh_i/dy, dh_i/dx,       0, ...
%     ... ,       0, dh_i/dz, dh_i/dy, ...
%     ... , dh_i/dz,       0, dh_i/dx, ... ]
  function getB_r = getB(self, ref_coords)
% B_i = 
%   = [dh_i/dx,       0,       0;
%            0, dh_i/dy,       0;
%            0,       0, dh_i/dz;
%      dh_i/dy, dh_i/dx,       0;
%            0, dh_i/dz, dh_i/dy;
%      dh_i/dz,       0, dh_i/dx; ]
%
% B = [    B_1,    ... ,     B_q  ]
%
% B_i = [  s_1,       0,       0; 
%            0,     s_2,       0; 
%            0,       0,     s_3; 
%          s_2,     s_1,       0; 
%            0,     s_3,     s_2; 
%          s_3,       0,     s_1; ]
%
% s_j = sum(dh_i/dr_k*dr_k/dx_j, k=1..3)
%
% dr_k/dx_j = J_inv(k, j)
%
% dhdr = ...
%   = [dh_1/dr, dh_2/dr,   ...  , dh_q/dr; 
%      dh_1/ds, dh_2/ds,   ...  , dh_q/ds;
%      dh_1/dt, dh_2/dt,   ...  , dh_q/dt]
% J = ...
%   = [dr/dx dr/dy dr/dz; 
%      ds/dx ds/dy ds/dz;
%      dt/dx dt/dy dt/dz]
    getB_r  = zeros(2*self.dim_, self.dim_*length(self.nodes_));
    J_inv   = self.getInvJ(ref_coords);
    dhdr    = self.shape_.getDerivatives(ref_coords);
    for i = 1:length(self.nodes_)
      s     = J_inv'*dhdr(:,i);      
      B_i = [s(1)    0    0;
                0 s(2)    0;
                0    0 s(3);
             s(2) s(1)    0;
                0 s(3) s(2);
             s(3)    0 s(1)];
     getB_r(:,(i - 1)*3 + 1:(i - 1)*3 + 3) = B_i;
    end   
  end
%-------------------------------------------------------------------------------  
  function k = getK(self)
    k = zeros(self.dim_ * length(self.nodes_));
    c = getC(self);
    int_points = self.integration_.getIntPoints;
    f = self.integration_.getRefDomainFactor();
    
    for index = 1:length(int_points)
      int_point   = int_points{index};
      ref_coords  = int_point.getRefCoords();
      w_i         = int_point.getWeight();
      b           = getB(self, ref_coords);
      detJ        = getDetJ(self, ref_coords);    
      
      k = k + f * w_i * ( b' * c * b * detJ );
    end
  end
%-------------------------------------------------------------------------------
  function drawMat(self, options)
    peri_nodes = self.shape_.getPerimeterNodes();
    patch_nodes = zeros(self.dim_, length(peri_nodes));
    point_nodes = zeros(self.dim_, length(self.nodes_));
    % exterior Nodes
    for index = 1:length(peri_nodes)    
      local_nodenumber = peri_nodes(index);
      patch_nodes(:, index) = self.nodes_{local_nodenumber}.getMatCoords();
    end
    % interior
    for index = 1:length(self.nodes_)
      point_nodes(:, index) = self.nodes_{index}.getMatCoords();
    end
    patch(patch_nodes(1, :), patch_nodes(2, :), ...
      zeros (length(patch_nodes), 1), options{1:end});
    plot(point_nodes(1,:), point_nodes(2,:), 'o');
  end   
%-------------------------------------------------------------------------------
  function drawScaledSpa(self, scale, options) 
    peri_nodes = self.shape_.getPerimeterNodes();
    patch_mat_nodes = zeros(self.dim_, length(peri_nodes));
    for index = 1:length(peri_nodes)    
      local_nodenumber = peri_nodes(index);
      patch_mat_nodes(:, index) = self.nodes_{local_nodenumber}.getMatCoords();
    end
    patch_spa_nodes = zeros(self.dim_, length(peri_nodes));
    for index = 1:length(peri_nodes)    
      local_nodenumber = peri_nodes(index);
      patch_spa_nodes(:, index) = self.nodes_{local_nodenumber}.getSpaCoords();
    end
    patch_nodes = patch_mat_nodes + (patch_spa_nodes - patch_mat_nodes)*scale;
    patch(patch_nodes(1, :), patch_nodes(2, :), ...
     zeros (length(patch_nodes), 1), options{1:end});
  end
%-------------------------------------------------------------------------------
end

end