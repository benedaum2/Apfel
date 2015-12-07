classdef PlasticityPoint < handle

%===============================================================================
properties( SetAccess = protected, Constant )
  EPSILON_ = 1E-15;
end

properties (SetAccess = protected)
  number_
  element_
  int_point_
  lcs_pp_
  sig_n1_
  cd_lam_
  pl_flag_
end

%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = PlasticityPoint(number, element, int_point)
    self.number_  = number;
    self.element_ = element;
    self.int_point_ ... 
                  = int_point;
                
    self.sig_n1_   = zeros(6,1);
    self.cd_lam_   = 0;
    self.pl_flag_  = 0;
  end
%-------------------------------------------------------------------------------
  function linkTo(self, lcs_pp)
    self.lcs_pp_  = lcs_pp;
    self.sig_n1_  = lcs_pp.sig_n1_;
  end    
%-------------------------------------------------------------------------------
  function int_pt = getIntPoint(self)
    int_pt        = self.int_point_;
  end  
%-------------------------------------------------------------------------------
  function cd_sig = getCDSig(self)
    cd_sig        = self.sig_n1_ - self.getSigN();
  end
%-------------------------------------------------------------------------------
  function setSigN1(self, sig_n1)
    self.sig_n1_  = sig_n1;
  end
%-------------------------------------------------------------------------------
  function cd_lam = getCDLam(self)
    % cd_lam        = self.lam_n1_ - self.getLamN();
    % cd_lam        = self.lam_n1_;
    % assert (cd_lam >= 0, 'lambda not >= 0')
    cd_lam        = self.cd_lam_;
  end
%-------------------------------------------------------------------------------
  function addToCDLam(self, d_lam)
    self.cd_lam_  = self.cd_lam_ + d_lam;
  end
%-------------------------------------------------------------------------------  
% calc current iteration total strain difference to last converged state
  function cd_eps = getCDEps(self)
    cd_eps        = self.getEpsN1() - self.getEpsN();
  end  
%-------------------------------------------------------------------------------
  function sig_trial = getSigTrial(self)
    sig_trial     = self.getSigN() + self.getC() * self.getCDEps();
  end
%-------------------------------------------------------------------------------
  function sig_n1 = getSigN1(self)
    sig_n1        = self.sig_n1_;
  end    
%-------------------------------------------------------------------------------
% calculate epsilon plastic for post processing
  function eps_pla = getEpsPla(self)
    eps_pla       = self.getEpsN1() - self.getC() \ self.getSigN1();
  end
%-------------------------------------------------------------------------------
% calculate kappa for post processing
  function kappa = getKappa(self)
    kappa         = sqrt((2/3) * (self.getEpsPla())' * self.getEpsPla());
  end
%-------------------------------------------------------------------------------
  function c_con = getCCon(self)
    c             = self.getC();
    % f_prime       = self.getFPrime();
    f_prime       = ...
      2 * self.element_.getFlowRule().getMatrix() * self.getSigN1();
    c_tilde       = self.getCTilde();

    if abs(self.getCDLam()) <= self.EPSILON_
      c_con         = c;
    else
      c_con         = c_tilde ... 
        - (c_tilde*f_prime*f_prime'*c_tilde)/(f_prime'*c_tilde*f_prime);
    end
  end    
%-------------------------------------------------------------------------------
  function f_part_lam = getFPartialLam(self)
    m             = self.element_.getFlowRule().getMatrix();
    sig_trial     = self.getSigTrial();
    a             = (eye(6) + 2 * self.getCDLam() * self.getC() * m);
    %[v,d]         = eig(a);
    %a_inv2        = v*(d^-2)*v';
    a_inv2        = a^-2;
    f_part_lam    = ...
      -((a_inv2*2*self.getC()*m*sig_trial)' * m * (a \ sig_trial))*2;
  end
%-------------------------------------------------------------------------------
% handle with care
  function addProportionate(self)   
    self.sig_n1_  = self.getC() * self.getCDEps() + self.getSigN();
  end  
%-------------------------------------------------------------------------------
  function generalReturn(self)
    m             = self.element_.getFlowRule().getMatrix();
    sig_trial     = self.getSigTrial();
    a             = (eye(6) + 2 * self.getCDLam() * self.getC() * m);
    f             = (a\sig_trial)'*m*(a\sig_trial) - 1;
    
    %if f <= 0 + self.EPSILON_ && ~self.pl_flag_
    if f <= 0 && ~self.pl_flag_
      iterate       = 0;
    else
      iterate       = 1;
      self.pl_flag_ = 1;
    end
    
    iteration = 0;
    
    while (iterate)
      iteration     = iteration + 1;
      a             = (eye(6) + 2 * self.getCDLam() * self.getC() * m);
      f             = (a\sig_trial)'*m*(a\sig_trial) - 1;


%       if abs(f) <= 0 + 1E-12 % abs is important
%         %fprintf(' \n');              
%         self.dispIterationInfo(iteration, f);
%         break;
%       end
      
      if (abs(f) <= 0 + 1E-10) % && self.pl_flag_  % abs is important
        %disp('flag');
        self.dispIterationInfo(iteration, f);
        break;
      end      
      
      d_lam         = - f / self.getFPartialLam();
      self.addToCDLam(d_lam);
      assert(iteration < 100, horzcat( ...
        'max iterations exceeded ', ...
        'cd_lam: ', num2str(self.getCDLam()), ...
        ' log10(f): ',  num2str(log10(abs(f)), '%2.2f') ...
      ));

      % fprintf(' %.2e', f);
        
    end
    
    self.setSigN1( ...
      (eye(6) + 2*self.getCDLam() * self.getC() * m) \ sig_trial ...
    );  
  end
%-------------------------------------------------------------------------------
%   function f_prime = getFPrime(self)
%     f_prime       = self.element_.getFlowRule().getFPartialSigma( ...
%       self.getSigN1() ...
%     );
%   end
%-------------------------------------------------------------------------------
  function sig_v = getSigV(self)
    sig_v = self.element_.getFlowRule().getSigmaV(self.sig_n1_);
  end
%-------------------------------------------------------------------------------
  function drawNumber(self, scale)
    x_hat_mat   = self.element_.getLocalXHat('mat');
    x_hat_spa   = self.element_.getLocalXHat('spa');
    x_hat       = x_hat_mat + (x_hat_spa - x_hat_mat).*scale;
    h           = self.element_.getH(self.int_point_.getRefCoords());
    coords      = h*x_hat;
    string      = horzcat('<', num2str(self.number_), '> ');
    text('Position', coords, 'String', string, ...
      'HorizontalAlignment', 'right', 'Color', 'red');
  end
%-------------------------------------------------------------------------------
  function drawScaledSpaKappa(self, scale, options)
    x_hat_mat   = self.element_.getLocalXHat('mat');
    x_hat_spa   = self.element_.getLocalXHat('spa');
    x_hat       = x_hat_mat + (x_hat_spa - x_hat_mat).*scale;
    h           = self.element_.getH(self.int_point_.getRefCoords());
    coords      = h*x_hat;
    plot(coords(1), coords(2), 'd', options{1:end});    
    if self.getKappa() > 0 + self.EPSILON_
      string      = horzcat(' ', num2str(self.getKappa(), '%.2e'));
      text('Position', coords, 'String', string, options{1:end});         
    end
  end
%-------------------------------------------------------------------------------
  function drawScaledSpaLambda(self, scale, options)
    x_hat_mat   = self.element_.getLocalXHat('mat');
    x_hat_spa   = self.element_.getLocalXHat('spa');
    x_hat       = x_hat_mat + (x_hat_spa - x_hat_mat).*scale;
    h           = self.element_.getH(self.int_point_.getRefCoords());
    coords      = h*x_hat;
    plot(coords(1), coords(2), 'd', options{1:end});    
    if self.cd_lam_ ~= 0 %+ self.EPSILON_
      string      = horzcat(' ', num2str(self.cd_lam_, '%.1e'));
      text('Position', coords, 'String', string, options{1:end});      
    end
  end  
%-------------------------------------------------------------------------------  
  function drawScaledSpaFilled(self, scale, options)
    x_hat_mat   = self.element_.getLocalXHat('mat');
    x_hat_spa   = self.element_.getLocalXHat('spa');
    x_hat       = x_hat_mat + (x_hat_spa - x_hat_mat).*scale;
    h           = self.element_.getH(self.int_point_.getRefCoords());
    coords      = h*x_hat;
    if self.cd_lam_ > 0 + self.EPSILON_
      plot(coords(1), coords(2), 'd', options{1:end}, ...
        'MarkerEdgeColor', 'magenta', 'MarkerFaceColor', 'magenta');
    else
      plot(coords(1), coords(2), 'd', options{1:end});          
    end
  end  
%-------------------------------------------------------------------------------
  function drawScaledSpaSigma(self, scale, options)
    x_hat_mat   = self.element_.getLocalXHat('mat');
    x_hat_spa   = self.element_.getLocalXHat('spa');
    x_hat       = x_hat_mat + (x_hat_spa - x_hat_mat).*scale;
    h           = self.element_.getH(self.int_point_.getRefCoords());
    coords      = h*x_hat;
    plot(coords(1), coords(2), 'd', options{1:end});    
    string      = horzcat(' ', num2str(self.getSigV(), '%3.1f'));
    text('Position', coords, 'String', string, options{1:end});
  end
%-------------------------------------------------------------------------------
  function drawScaledSpaSigmaV(self, scale, options)
    x_hat_mat   = self.element_.getLocalXHat('mat');
    x_hat_spa   = self.element_.getLocalXHat('spa');
    x_hat       = x_hat_mat + (x_hat_spa - x_hat_mat).*scale;
    h           = self.element_.getH(self.int_point_.getRefCoords());
    coords      = h*x_hat;
    plot(coords(1), coords(2), 'd', options{1:end});
    string      = horzcat(' ', num2str((self.getSigV() - 1), '%1.2f'));
    text('Position', coords, 'String', string, options{1:end});
  end
%-------------------------------------------------------------------------------
end


%===============================================================================
methods (Access = protected) % debug (Access = private)
%-------------------------------------------------------------------------------
% calc current iteration total strain
  function eps_n1 = getEpsN1(self)
    ref_coords    = self.int_point_.getRefCoords();
    eps_n1        = self.element_.getEpsilon(ref_coords);
    if (self.element_.getDim == 2 && self.element_.isPlainStrain())
      eps_n1        = [eps_n1(1) eps_n1(2) 0 eps_n1(3) 0 0]';
    end
  end  
%-------------------------------------------------------------------------------
  function eps_n = getEpsN(self)
    eps_n         = self.lcs_pp_.getEpsN1();
  end
%-------------------------------------------------------------------------------  
  function sig_n = getSigN(self)
    sig_n         = self.lcs_pp_.sig_n1_;
  end
%-------------------------------------------------------------------------------
  function c  = getC(self)
    %c             = self.element_.getC();
    E     = self.element_.mat_.E;
    nu    = self.element_.mat_.nu;
    G     = E/(2 + 2*nu);
    rho   = nu/(1 - 2*nu);
    rho_1 = rho + 1;
    
    c = 2*G * [
      rho_1 rho   rho   0   0   0;
      rho   rho_1 rho   0   0   0;
      rho   rho   rho_1 0   0   0;
      0     0     0     1/2 0   0;
      0     0     0     0   1/2 0;
      0     0     0     0   0   1/2;
    ];
  end  
%-------------------------------------------------------------------------------
  function c_tilde = getCTilde(self)
    % f_prime2      = self.element_.getFlowRule().getFPartialSigma2(); %ToDo
    f_prime2      = 2 * self.element_.getFlowRule().getMatrix();
    c_tilde       = inv( inv(self.getC()) + self.getCDLam() * f_prime2 );
  end  
%-------------------------------------------------------------------------------
  function dispIterationInfo(self, iteration, residuum)
    disp(horzcat( ...
      class(self), ...
      ' (',             num2str(self.element_.getNumber(), '%02.f'), ...
      ') <',            num2str(self.number_, '%02.f'), ...
      '> -',            num2str(iteration, '%02.f'), ...
      '- cd_lam: ',     num2str(self.cd_lam_, '%.2e'), ...
      ' log10(res): ',  num2str(log10(abs(residuum)), '%2.2f') ...
    ));
    if self.cd_lam_ < 0
      disp(horzcat(class(self), ' ~~~ warning: cd_lam < 0 ~~~'));
    end
  end  
%-------------------------------------------------------------------------------
end

end
































