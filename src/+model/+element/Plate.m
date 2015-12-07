classdef Plate < model.element.Element

%===============================================================================
properties (SetAccess = protected)
  plain_strain_;
  thickness_;  
end

%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = Plate(number, nodes, et, mat)
    self@model.element.Element(number, nodes, et, mat, 2);
    
    if isfield(et, 'plain_strain')
      assert(~isfield(et, 'thickness'), ...
        'specify either "plain_strain" or "thickness", not both')      
      self.thickness_     = 1;
      self.plain_strain_  = 1;
    elseif isfield(et, 'thickness')
      assert(~isfield(et, 'plain_strain'), ...
        'specify either "plain_strain" or "thickness", not both')
      assert(et.thickness ~= 0, ...
        '"thickness" must not be 0')
      self.thickness_     = et.thickness;
      self.plain_strain_  = 0;      
    else
      error('specify one of "plain_strain" or "thickness"') 
    end
  end
%-------------------------------------------------------------------------------  
  function isPlainStrain_r = isPlainStrain(self)
    isPlainStrain_r = self.plain_strain_;
  end
%-------------------------------------------------------------------------------
  function getC_r = getC(self)
    if isPlainStrain(self)
      getC_r = getPlainStrainC(self);
    else
      getC_r = getPlainStressC(self);
    end
  end
%-------------------------------------------------------------------------------
% B = 
% = [ ... , dh_i/dx,       0, ...
%     ... ,       0, dh_i/dy, ...
%     ... , dh_i/dy, dh_i/dx, ... ]
  function getB_r = getB(self, ref_coords)
% B_i = 
%   = [dh_i/dx,       0;
%            0, dh_i/dy;
%      dh_i/dy, dh_i/dx ]
%
% B = [    B_1,    ... ,     B_q  ]
%
% B = [    s_1,       0; 
%            0,     s_2; 
%          s_2,     s_1 ]
%
% s_j = sum(dh_i/dr_k*dr_k/dx_j, k=1..3)
%
% dr_k/dx_j = J_inv(k, j)
%
% dhdr = ...
%   = [dh_1/dr, dh_2/dr,   ...  , dh_q/dr; 
%      dh_1/ds, dh_2/ds,   ...  , dh_q/ds]
    getB_r = zeros(3, self.dim_*length(self.nodes_));
    J_inv  = self.getInvJ(ref_coords);
    dhdr   = self.shape_.getDerivatives(ref_coords);
    for i = 1:length(self.nodes_)
      s    = J_inv'*dhdr(:,i);
      %s = J_inv*dhdr(:,i);
      B_i = [s(1)    0;
                0 s(2);
             s(2) s(1)];
     getB_r(:,(i - 1)*2 + 1:(i - 1)*2 + 2) = B_i;
    end
  end  
%-------------------------------------------------------------------------------  
  function k = getK(self)
    k = zeros(self.dim_ * length(self.nodes_));
    c = getC(self);
    h = self.thickness_;
    int_points = self.integration_.getIntPoints;
    f = self.integration_.getRefDomainFactor();
    
    for index = 1:length(int_points)
      int_point   = int_points{index};
      ref_coords  = int_point.getRefCoords();      
      w_i         = int_point.getWeight();
      b           = getB(self, ref_coords);      
      detJ        = getDetJ(self, ref_coords);    
      
      k = k + f * w_i * ( b' * c * b * h * detJ );
    end
  end
%-------------------------------------------------------------------------------  
end


%===============================================================================
methods (Access = private)
%-------------------------------------------------------------------------------    
  function getPlainStrainC_r = getPlainStrainC(self)
    E =   self.mat_.E;
    nu =  self.mat_.nu;    
    C = E/((1 + nu)*(1 - 2*nu)) * [
      1 - nu, nu,     0;
      nu,     1 - nu, 0;
      0,      0,      (1 - 2*nu)/2
    ];
  
    getPlainStrainC_r = C;    
  end
%-------------------------------------------------------------------------------
  function getPlainStressC_r = getPlainStressC(self)
    E =   self.mat_.E;
    nu =  self.mat_.nu;    
    C = E/(1 - nu^2) * [
      1,  nu, 0;
      nu, 1,  0;
      0,  0,  (1 - nu)/2
    ];
  
    getPlainStressC_r = C;      
  end
%-------------------------------------------------------------------------------
end

end







