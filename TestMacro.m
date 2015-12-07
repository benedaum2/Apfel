% clear
% steel = struct('E', 210000, 'nu', 0.3);
% node2d_1 = Node2d([1;1]);
% node2d_2 = Node2d([3;1]);
% node2d_3 = Node2d([1;3]);
% nodes = {node2d_1,node2d_2,node2d_3};
% element1 = ElementPlateTri(nodes, steel, 1)

% clear
% steel = struct('E', 210000, 'nu', 0.3);
% node2d_1 = Node2d([1;1]);
% node2d_2 = Node2d([5;1]);
% node2d_3 = Node2d([1;5]);
% node2d_4 = Node2d([3;1]);
% node2d_5 = Node2d([3;3]);
% node2d_6 = Node2d([1;3]);
% nodes = {node2d_1,node2d_2,node2d_3,node2d_4,node2d_5,node2d_6};
% secondorder_tri1 = ElementPlateTri(nodes, steel, 1)
% secondorder_tri1.testShapeFunctions([0.1;0.1])

%-------------------------------------------------------------------------------
% J-Matrix

% clear
% steel = struct('E', 210000, 'nu', 0.3);
% node2d_1 = Node2d([1;1]);
% node2d_2 = Node2d([5;1]);
% node2d_3 = Node2d([1;5]);
% node2d_4 = Node2d([3;1]);
% node2d_5 = Node2d([3;3]);
% node2d_6 = Node2d([1;3]);
% nodes = {node2d_1,node2d_2,node2d_3,node2d_4,node2d_5,node2d_6};
% secondorder_tri1 = ElementPlateTri(nodes, steel, 1)
% ref_coords = [0.2;0.3]
% secondorder_tri1.getDetJ(ref_coords)

%-------------------------------------------------------------------------------
% H-Matrix

%clear
%     ref_coords = [0;1]
%     dim = 2
%     
%     num_nodes = 6
%     
%   
%     H = zeros(dim, dim*num_nodes);
%     for row = 1:size(H, 1)
%       for col = row:dim:dim*num_nodes
%         h_index = (col - row + 1) - (dim - 1)*floor((col - 0.01)/dim);
%         H(row, col) = secondorder_tri1.shape_funcs_{h_index}.value(ref_coords);
%       end
%     end

%-------------------------------------------------------------------------------
% B-Matrix

% clear
% steel = struct('E', 210000, 'nu', 0.3);
% node2d_1 = Node2d([1;1]);
% node2d_2 = Node2d([5;1]);
% node2d_3 = Node2d([1;5]);
% node2d_4 = Node2d([3;1]);
% node2d_5 = Node2d([3;3]);
% node2d_6 = Node2d([1;3]);
% nodes = {node2d_1,node2d_2,node2d_3,node2d_4,node2d_5,node2d_6};
% secondorder_tri1 = ElementPlateTri(nodes, steel, 1)
% ref_coords = [0.2;0.3]
% B_vergleich = [
%    -0.2500,         0,   -0.0500,         0,         0,         0,    0.3000,         0,     0.3000,         0,   -0.3000,         0;
%          0,   -0.2500,         0,         0,         0,    0.0500,         0,   -0.2000,          0,    0.2000,         0,    0.2000;
%    -0.2500,   -0.2500,         0,   -0.0500,    0.0500,         0,   -0.2000,    0.3000,     0.2000,    0.3000,    0.2000,   -0.3000
% ];
% B = secondorder_tri1.getB(ref_coords);
% epsilon = 10^-10
% assert(all(all(B_vergleich - B < epsilon*ones(size(B)))), '[fail] check of B failed')
% disp('[ ok ] check of B succeded')

%-------------------------------------------------------------------------------
% K-Matrix

% clear
% et_ds = struct('thickness', 1);
% mat_ds = struct('E', 210000, 'nu', 0.3);
% node2d_1 = model.Node2d(1, [1;1]);
% node2d_2 = model.Node2d(2, [5;1]);
% node2d_3 = model.Node2d(3, [1;5]);
% node2d_4 = model.Node2d(4, [3;1]);
% node2d_5 = model.Node2d(5, [3;3]);
% node2d_6 = model.Node2d(6, [1;3]);
% nodes = {node2d_1,node2d_2,node2d_3,node2d_4,node2d_5,node2d_6};
% secondorder_tri1 = model.ElementPlateTri(1, nodes, et_ds, mat_ds);
% ref_coords = [0.2;0.3]
% secondorder_tri1.getK()

%===============================================================================
% Input handling
%-------------------------------------------------------------------------------

% model = fe('triangle_patch.xml')

%===============================================================================
% Modeltesting
%-------------------------------------------------------------------------------
% filename = 'triangle_patch.xml';
% 
% disp(['fe/loading input file <', filename, '> ...']);
% input_handler = io.XMLInputHandler( filename );
% 
% disp('fe/creating model ...');
% model = input_handler.createModel();
% 
% disp('fe/starting analysis ...');
% linear = analysis.Linear(model);



% a_lag = apfel('examples/cantilever_nl_lagrange2ord.xml');
% a_ser = apfel('examples/cantilever_nl_serendipity2ord.xml');
% u_hat_lag = a.inc_cell_{4}.getUHat();
% u_hat_ser = a.inc_cell_{4}.getUHat();
% u_hat_lag - u_hat_ser

% a_lag = apfel('examples/cantilever_nl_lagrange2ord.xml');

%[self.model_.getElement(1).getLocalXHat('mat'), self.model_.getElement(1).getLocalXHat('spa'), self.model_.getElement(1).getLocalUHat]

% for i = 1:40
%   post(a, i)
% end

string = 'abcd'

!echo string




