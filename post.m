function frame = post(a, inc_num)
if nargin < 2
  inc_num   = 1;
end
model = a.getIncrement(inc_num).getModel();
disp(horzcat('post/displaying increment ', num2str(inc_num), ...
  ' of ', num2str(a.getIncrementAmount())));

% scale = 5e1; % trapezoid
% scale = 5e1; %ring (quater) 
% scale = 1e2; %ring (full) 
scale = 1e2; %sample
% scale = 0e1;
show_node_number  = 0;
show_mat          = 1;
show_mat_gauss    = 0;
show_spa          = 1;
show_spa_gauss    = 0;
show_spa_sigma    = 0; % elastic
show_pp_kappa     = 0;
show_pp_lambda    = 0;
show_pp_filled    = 1;
show_pp_sigma     = 0; % plastic
show_pp_sigma_v   = 0; % comparison stress
show_pp_number    = 0;

% show_bc = 0;
show_bc = 1.0;
bc_size = 1.0; % collapse
% bc_size = 1.5; % trapezoid
% bc_size = 2.0; % ring
% bc_size = 4.0; % sample
close;



%scrsz = get(0,'ScreenSize');
%fig = figure('Position',  [scrsz(1)*0   scrsz(4)*0.9 scrsz(3)*0.4 scrsz(4)*0.9]);
fig = figure();
set(gcf, 'Units', 'normalized')
% set(gcf, 'Position', [0.000 0.900 0.350 0.900]) %ring
set(gcf, 'Position', [0.000 0.200 0.350 0.300]) %collapse
% set(gcf, 'Position', [0.000 0.900 0.200 0.800]) %trapezoid
% set(gcf, 'Position', [0.000 0.000 0.350 0.600]) %sample
set(gcf, 'Colormap', jet);
set(gca, 'Units', 'normalized')
set(gca, 'Position', [0.025 0.025 0.950 0.950]) %ring, collapse
% set(gca, 'Position', [0.050 0.050 0.900 0.900]) %trapezoid
% set(gca, 'XLim', [-320, 320] ); set(gca, 'YLim', [-200, 200] ); %sample
hold on;
axis equal;


mat_options = {'FaceColor', 'none', 'EdgeColor', 'blue', 'Marker', 'o'};
spa_options = {'FaceColor', 'none', 'EdgeColor', 'red' , 'Marker', 'o'};
mat_gauss_options = {'Color', 'blue'};
spa_gauss_options = {'Color', 'red'};
pp_kappa_options  = {'Color', 'red'};
pp_lambda_options = {'Color', 'magenta'};
pp_sigma_options  = {'Color', 'red'};
%sigma_options     = {};

if show_node_number
  for no_index = 1:model.getNodeAmount()
    node = model.getNode(no_index);
    node.drawNumber();
  end
end

for el_index = 1:model.getElementAmount()  
  element = model.getElement(el_index);
  if (show_mat)
    element.drawMat(mat_options);
  end
  if (show_spa)
    element.drawScaledSpa(scale, spa_options);
  end
  if (show_mat_gauss)
    element.drawMatGauss(mat_gauss_options);
  end
  if (show_spa_gauss)
    element.drawScaledSpaGauss(scale, show_spa_sigma, spa_gauss_options);
  end
end

for pp_index = 1:model.getPlasticityPointAmount()
  pp = model.getPlasticityPoint(pp_index);
  if (show_pp_number)
    pp.drawNumber(scale);
  end  
  if (show_pp_kappa)
    pp.drawScaledSpaKappa(scale, pp_kappa_options);
  end
  if (show_pp_lambda)
    pp.drawScaledSpaLambda(scale, pp_lambda_options);
  end
  if (show_pp_filled)
    pp.drawScaledSpaFilled(scale, pp_sigma_options);
  end
  if (show_pp_sigma)
    pp.drawScaledSpaSigma(scale, pp_sigma_options);
  end 
  if (show_pp_sigma_v)
    pp.drawScaledSpaSigmaV(scale, pp_sigma_options);
  end   
end

% kirsch
% for el_index = 1:10:100
%   model.getElement(el_index).get
% end

a.writeGid();

for bc_index = 1:model.getBcAmount()
  bc = model.getBc(bc_index);
  if (show_bc)
    bc.draw(bc_size);
  end
end

time = a.getTime(inc_num);

% text('Position', [0, -30], 'String', horzcat('time:  ', num2str(time,  '%.4f')));
text('Position', [0, -30], 'String', horzcat('increment:  ', num2str(inc_num,  '%u')));
text('Position', [0, -34], 'String', horzcat('scale: ', num2str(scale, '%.2e')));

% ring
% text('Position', [5, 10], 'String', horzcat('time:  ', num2str(time,  '%.4f')));
% text('Position', [5,  5], 'String', horzcat('scale: ', num2str(scale, '%.2e')));

% sample
% text('Position', [-180, -140], 'String', horzcat('time:  ', num2str(time,  '%.4f')));
% text('Position', [-180, -155], 'String', horzcat('scale: ', num2str(scale, '%.2e')));

% alpha = time; %*(0.4000/0.3333);
% text('Position', [2, 15], 'String', horzcat('time:  ', num2str(time,  '%.4f')));
% text('Position', [2, 13], 'String', horzcat('alpha: ', num2str(alpha, '%.4f')));
% text('Position', [2, 11], 'String', horzcat('scale: ', num2str(scale, '%.2e')));

%frame       = getframe(fig);
frame       = 0;

%zeta(alpha)

hold off;
end
