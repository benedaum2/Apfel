classdef Element < handle

  
%===============================================================================
properties (SetAccess = protected)
  number_;
  order_;
  nodes_ = {};
  shape_;
  integration_;
  et_;
  mat_;
  dim_;
end  


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------
% Constructor
  function self = Element(number, nodes, et, mat, dim)
    assert(isa(nodes, 'cell'), 'nodes not of type cell');
    assert(isfield(et, 'shape'), 'no shapefunctions specified');
    self.number_  = number;
    self.nodes_   = nodes;
    self.et_   = et;
    self.mat_  = mat;    
    self.dim_  = dim;
    for index = 1:length(nodes)
      assert(nodes{index}.getDimension() == self.dim_, ...
        'node dimension mismatch');
    end
  end
%-------------------------------------------------------------------------------    
% Clone
% Basic clone behavior for all subclasses
  function clone_r = clone(self)
    % handle = @functionname
    subclass_handle = str2func(class(self));
    
    % clone the nodes
    cloned_nodes = cell(1, length(self.nodes_));
    for index = 1:length(self.nodes_)
      cloned_nodes{index} = self.nodes_{index}.clone();
    end    
    
    clone_r = ...
      subclass_handle(self.number_, cloned_nodes, self.et_, self.mat_);
  end
%-------------------------------------------------------------------------------
  function dim = getDim(self)
    dim = self.dim_;
  end
%-------------------------------------------------------------------------------
  function getNumber_r = getNumber(self)
    getNumber_r = self.number_;
  end
%-------------------------------------------------------------------------------
  function getNode_r = getNode(self, node_index)
    getNode_r = self.nodes_{node_index};
  end  
%-------------------------------------------------------------------------------
  function getNodes_r = getNodes(self)
    getNodes_r = self.nodes_;
  end
%-------------------------------------------------------------------------------
  function getNodeAmount_r = getNodeAmount(self)
    getNodeAmount_r = length(self.nodes_);
  end
%-------------------------------------------------------------------------------
  function getEt_r = getEt(self)
    getEt_r = self.et_;
  end
%-------------------------------------------------------------------------------
  function getIntPoint_r = getIntPoint(self, number)
    int_points = self.integration_.getIntPoints();
    getIntPoint_r = int_points{number};
  end
%-------------------------------------------------------------------------------
  function getIntPoints_r = getIntPoints(self)
    getIntPoints_r = self.integration_.getIntPoints();
  end
%-------------------------------------------------------------------------------
  function getIntPointAmount_r = getIntPointAmount(self)
    getIntPointAmount_r = length(self.integration_.getIntPoints());
  end
%-------------------------------------------------------------------------------  
  function getOrder_r = getOrder(self)
    getOrder_r = self.order_;
  end
%-------------------------------------------------------------------------------
  function getLocalXHat_r = getLocalXHat(self, config)
    dim             = self.dim_;
    x_hat           = zeros(length(self.nodes_)*dim, 1);
    for no_index = 1:length(self.nodes_)
      node          = self.nodes_{no_index};
      if strcmp(config, 'mat')
        coords = node.getMatCoords();
      elseif strcmp(config, 'spa')
        coords = node.getSpaCoords();
      else
        error('config has to be one of "mat" or "spa"')
      end
      for dim_index = 1:dim
        x_hat((no_index - 1)*dim + dim_index ) =  coords(dim_index);
      end
    end
    getLocalXHat_r  = x_hat;
  end
%-------------------------------------------------------------------------------
  function getLocalUHat_r = getLocalUHat(self)
    x_hat_mat       = getLocalXHat(self, 'mat');
    x_hat_spa       = getLocalXHat(self, 'spa');
    getLocalUHat_r  = x_hat_spa - x_hat_mat;
  end
%-------------------------------------------------------------------------------
  function epsilon_r = getEpsilon(self, ref_coords)
    B               = self.getB(ref_coords);
    u_hat           = self.getLocalUHat();
    epsilon_r       = B*u_hat;
  end
%-------------------------------------------------------------------------------
  function sigma_r = getSigma(self, ref_coords)
    C               = self.getC();
    epsilon         = self.getEpsilon(ref_coords);
    sigma_r         = C*epsilon;  
  end  
%-------------------------------------------------------------------------------
  function drawMatGauss(self, options)
    x_hat = getLocalXHat(self, 'mat');
    int_points = self.integration_.getIntPoints;
    for pt_index = 1:length(int_points)
      point = int_points{pt_index};
      H = self.getH(point.getRefCoords());
      pt_coords = H*x_hat;
      plot(pt_coords(1), pt_coords(2), 'd', options{1:end});
    end  
  end
%-------------------------------------------------------------------------------
  function drawScaledSpaGauss(self, scale, sigma, options)
    x_hat_mat = getLocalXHat(self, 'mat');
    x_hat_spa = getLocalXHat(self, 'spa');
    x_hat = x_hat_mat + (x_hat_spa - x_hat_mat).*scale;
    int_points = self.integration_.getIntPoints();
    for pt_index = 1:length(int_points)
      point = int_points{pt_index};
      H = self.getH(point.getRefCoords());
      pt_coords = H*x_hat;
      plot(pt_coords(1), pt_coords(2), 'd', options{1:end});
      if sigma
        getsig = self.getSigma(point.getRefCoords());
        whitespace(1:size(getsig, 1),1) = ' ';
        string = horzcat(whitespace, ...
          num2str(getsig, '%3.1f'));
        text('Position', pt_coords, 'String', string, options{1:end});
      end
    end  
  end
%-------------------------------------------------------------------------------
% J = ...
%   = [dx/dr dx/ds dx/dt; 
%      dy/dr dy/ds dy/dt;
%      dz/dr dz/ds dz/dt]   
  function getJ_r = getJ(self, ref_coords)
    % dhdr = ...
    %   = [dh_1/dr dh_2/dr ... dh_q/dr; 
    %      dh_1/ds dh_2/ds ... dh_q/ds;
    %      dh_1/dt dh_2/dt ... dh_q/dt]    
    dhdr = self.shape_.getDerivatives(ref_coords);
    % x = [x_1 y_1 z_1;
    %      ... ... ...;
    %      x_q ... z_q]
    x    = zeros(length(self.nodes_), self.dim_);
    for row = 1:length(self.nodes_)
      x(row, :) = self.nodes_{row}.getMatCoords;
    end
    getJ_r = (dhdr*x)';
  end    
%-------------------------------------------------------------------------------
  function getDetJ_r = getDetJ(self, ref_coords)
    J = getJ(self, ref_coords);
    getDetJ_r = det(J);
  end  
%-------------------------------------------------------------------------------
% J = ...
%   = [dr/dx dr/dy dr/dz; 
%      ds/dx ds/dy ds/dz;
%      dt/dx dt/dy dt/dz]
  function getInvJ_r = getInvJ(self, ref_coords)
    J = getJ(self, ref_coords);
    getInvJ_r = inv(J);
  end    
%-------------------------------------------------------------------------------
% H = ...
% = [h_1,   0, h_2,   0, ... , h_q,   0;
%      0, h_1,   0, h_2, ... ,   0, h_q]
  function H_r = getH(self, ref_coords)
    dim = self.dim_;
    h = self.shape_.getValues(ref_coords);
    H = zeros(dim, dim*length(self.nodes_));
    
    for row = 1:size(H, 1)
      for col = row:dim:size(H, 2)
        h_index = (col - row + 1) - (dim - 1)*floor((col - 0.01)/dim);
        H(row, col) = h(h_index);
      end
    end
    
    H_r = H;
  end 
%-------------------------------------------------------------------------------
  function testShapeFunctions(self, ref_coords)
    assert(self.shape.getValues(ref_coords) == 1, ...
      '[fail] sum of all shape functions is not equal to 1');
    disp('[ ok ] test passed')
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

%===============================================================================
methods (Abstract, Access = public)
  C_r = getC(self)
  K_r = getK(self)
end
%-------------------------------------------------------------------------------

end