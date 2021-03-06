classdef Hill_sample < plasticity.flowrule.FlowRule

  
%===============================================================================
properties (SetAccess = protected)
  h_
end  


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------
% Constructor
  function self = Hill_sample(data)
    self@plasticity.flowrule.FlowRule(data);
    self.h_ = zeros(6);
    
    % self.h_(1,1) =  ;
    % self.h_(2,2) =  ;
    % self.h_(3,3) =  ;
    % self.h_(4,4) =  ;
    % self.h_(5,5) =  ;
    % self.h_(6,6) =  ;    
    % 
    % self.h_(1,2) =  ;
    % self.h_(1,3) =  ;
    % self.h_(2,3) =  ;
    % self.h_(2,1) = self.h_(1,2);
    % self.h_(3,1) = self.h_(1,3);
    % self.h_(3,2) = self.h_(2,3);    
    % 
    % self.h_(1,4) =  ;
    % self.h_(2,4) =  ;
    % self.h_(3,4) =  ;
    % self.h_(4,1) = self.h_(1,4);
    % self.h_(4,2) = self.h_(2,4);
    % self.h_(4,3) = self.h_(3,4);
    %
    % self.h_(5,6) =  ;
    % self.h_(6,5) = self.h_(5,6);    
    
    % phi = pi/4, 100 = sig_F = X/2 = Y = Z transverse isotrop
    % self.h_(1,1) =  4.3750000000e-5;
    % self.h_(2,2) =  4.3750000000e-5;
    % self.h_(3,3) =  1.0000000000e-4;
    % self.h_(4,4) =  1.5000000000e-4;
    % self.h_(5,5) =  2.2500000000e-4;
    % self.h_(6,6) =  2.2500000000e-4;    
    % 
    % self.h_(1,2) =  6.2500000000e-6;
    % self.h_(1,3) = -5.0000000000e-5;
    % self.h_(2,3) = -5.0000000000e-5;
    % self.h_(2,1) = self.h_(1,2);
    % self.h_(3,1) = self.h_(1,3);
    % self.h_(3,2) = self.h_(2,3);    
    % 
    % self.h_(1,4) = -3.7500000000e-5;
    % self.h_(2,4) = -3.7500000000e-5;
    % self.h_(3,4) =  7.5000000000e-5;
    % self.h_(4,1) = self.h_(1,4);
    % self.h_(4,2) = self.h_(2,4);
    % self.h_(4,3) = self.h_(3,4);    
    % 
    % self.h_(5,6) = -1.5000000000e-4;
    % self.h_(6,5) = self.h_(5,6);     
    
    % phi = pi/4, 100 = sig_F = X/5 = Y = Z transverse isotrop    
    % self.h_(1,1) =  2.8000000000e-5;
    % self.h_(2,2) =  2.8000000000e-5;
    % self.h_(3,3) =  1.0000000000e-4;
    % self.h_(4,4) =  1.0800000000e-4;
    % self.h_(5,5) =  2.0400000000e-4;
    % self.h_(6,6) =  2.0400000000e-4;    
    % 
    % self.h_(1,2) =  2.2000000000e-5;
    % self.h_(1,3) = -5.0000000000e-5;
    % self.h_(2,3) = -5.0000000000e-5;
    % self.h_(2,1) = self.h_(1,2);
    % self.h_(3,1) = self.h_(1,3);
    % self.h_(3,2) = self.h_(2,3);    
    % 
    % self.h_(1,4) = -4.8000000000e-5;
    % self.h_(2,4) = -4.8000000000e-5;
    % self.h_(3,4) =  9.6000000000e-5;
    % self.h_(4,1) = self.h_(1,4);
    % self.h_(4,2) = self.h_(2,4);
    % self.h_(4,3) = self.h_(3,4);
    % 
    % self.h_(5,6) = -1.9200000000e-4;
    % self.h_(6,5) = self.h_(5,6);    
    
    % phi = pi/5, 100 = sig_F = X/5 = Y = Z transverse isotrop    
%     self.h_(1,1) =  1.5458980337e-5;
%     self.h_(2,2) =  4.5124611797e-5;
%     self.h_(3,3) =  1.0000000000e-4;
%     self.h_(4,4) =  9.8832815730e-5;
%     self.h_(5,5) =  2.6333126292e-4;
%     self.h_(6,6) =  1.4466873708e-4;    
%     
%     self.h_(1,2) =  1.9708203932e-5;
%     self.h_(1,3) = -3.5167184270e-5;
%     self.h_(2,3) = -6.4832815730e-5;
%     self.h_(2,1) = self.h_(1,2);
%     self.h_(3,1) = self.h_(1,3);
%     self.h_(3,2) = self.h_(2,3);    
%     
%     self.h_(1,4) = -3.1543866727e-5;
%     self.h_(2,4) = -5.9757558837e-5;
%     self.h_(3,4) =  9.1301425564e-5;
%     self.h_(4,1) = self.h_(1,4);
%     self.h_(4,2) = self.h_(2,4);
%     self.h_(4,3) = self.h_(3,4);
%     
%     self.h_(5,6) = -1.8260285113e-4;
%     self.h_(6,5) = self.h_(5,6);       
    
    % phi = pi/5, 100 = sig_F = X/2 = Y = Z transverse isotrop   
    self.h_(1,1) = 3.3952328389e-5;
    self.h_(2,2) = 5.7128602967e-5;
    self.h_(3,3) = 1.0000000000e-4;
    self.h_(4,4) = 1.4283813729e-4;
    self.h_(5,5) = 2.7135254916e-4;
    self.h_(6,6) = 1.7864745084e-4;    
    
    self.h_(1,2) =  4.4595343223e-6;
    self.h_(1,3) = -3.8411862711e-5;
    self.h_(2,3) = -6.1588137289e-5;
    self.h_(2,1) = self.h_(1,2);
    self.h_(3,1) = self.h_(1,3);
    self.h_(3,2) = self.h_(2,3);    
    
    self.h_(1,4) = -2.4643645881e-5;
    self.h_(2,4) = -4.6685592841e-5;
    self.h_(3,4) =  7.1329238722e-5;
    self.h_(4,1) = self.h_(1,4);
    self.h_(4,2) = self.h_(2,4);
    self.h_(4,3) = self.h_(3,4);
    
    self.h_(5,6) = -1.4265847744e-4;
    self.h_(6,5) = self.h_(5,6);     
    
    % phi = 0, 100 = sig_F = X/2 = Y = Z transverse isotrop   
%     self.h_(1,1) =  2.5000000000e-5;
%     self.h_(2,2) =  1.0000000000e-4;
%     self.h_(3,3) =  1.0000000000e-4;
%     self.h_(4,4) =  7.5000000000e-5;
%     self.h_(5,5) =  3.7500000000e-4;
%     self.h_(6,6) =  7.5000000000e-5;    
%     
%     self.h_(1,2) =  -1.2500000000e-5;
%     self.h_(1,3) =  -1.2500000000e-5;
%     self.h_(2,3) =  -8.7500000000e-5;
%     self.h_(2,1) = self.h_(1,2);
%     self.h_(3,1) = self.h_(1,3);
%     self.h_(3,2) = self.h_(2,3);    
%     
%     self.h_(1,4) =  0;
%     self.h_(2,4) =  0;
%     self.h_(3,4) =  0;
%     self.h_(4,1) = self.h_(1,4);
%     self.h_(4,2) = self.h_(2,4);
%     self.h_(4,3) = self.h_(3,4);
%     
%     self.h_(5,6) =  0;
%     self.h_(6,5) = self.h_(5,6);     
  end
%-------------------------------------------------------------------------------
  function h = getMatrix(self)
    h       = self.h_;
  end  
%-------------------------------------------------------------------------------
end

%===============================================================================
methods (Access = private)
%-------------------------------------------------------------------------------
%   function dispDescription(self)
%     if self.h_(2, 3) == self.h_(1, 2)
%       fg = 1;
%     end
%     if self.h_(1, 2) == self.h_(1, 3)
%       gh = 1;
%     end
%     if self.h_(1, 2) == self.h_(2, 3)
%       hf = 1;
%     end    
%     
%     
%     disp(horzcat(class(self)  ' ', type));
%   end  
%-------------------------------------------------------------------------------

end

end


























