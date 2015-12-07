classdef BaseIH
% Basic Inputhandler class
  
%===============================================================================  
properties( Access = protected )
  DOM;
%   dim_
end


%===============================================================================
methods( Access = public, Static )
%-------------------------------------------------------------------------------
  function a_handle = readAnalysisType(filename)
    DOM         = xmlread(filename);
    a_xml       = DOM.getElementsByTagName('analysis_type').item(0);
    a_id        = char(a_xml.getAttribute('class'));
    a_handle    = str2func(strcat('analysis.', a_id));
  end
%-------------------------------------------------------------------------------
end


%===============================================================================
methods
%-------------------------------------------------------------------------------  
  function self = BaseIH(filename)
    self.DOM    = xmlread(filename);
  end
%-------------------------------------------------------------------------------
  function m = createModel(self)
    disp(strcat(class(self), '/creating model ...'));
    dim         = self.getDim();
    m_handle    = self.getModelHandle();
    m           = m_handle(dim);
    self.addNodes(m);
    self.addElementTypes(m);
    self.addMaterials(m);
    self.addElements(m);
    self.addBcs(m);    
  end  
%-------------------------------------------------------------------------------
end
  
%===============================================================================
methods( Access = protected )
%-------------------------------------------------------------------------------  
  function dim = getDim(self)
    global_list = self.DOM.getElementsByTagName('global');
    dim         = str2double(global_list.item(0).getAttribute('dim'));
  end
%-------------------------------------------------------------------------------
  function addNodes(self, m)
    node_list = self.getXMLList( 'node', 'n' );
    for counter=0:node_list.getLength() - 1
      xml_node = node_list.item(counter);
      node_number = str2double(xml_node.getFirstChild.getData);
      if xml_node.hasAttribute('x')
        x = str2double(xml_node.getAttribute('x'));
        coords(1) = x;
      end
      if xml_node.hasAttribute('y')
        y = str2double(xml_node.getAttribute('y'));
        coords(2) = y;
      end
      if xml_node.hasAttribute('z')
        z = str2double(xml_node.getAttribute('z'));
        coords(3) = z;
      end
      n = model.Node(node_number, coords);     
      m.addNode( n );
    end      
  end
%-------------------------------------------------------------------------------    
  function addMaterials(self , m)
    mat_list = self.getXMLList( 'material', 'm' );
    for counter = 0:mat_list.getLength - 1
      mat         = struct;
      xml_mat     = mat_list.item(counter);      
      mat.number  = str2double(xml_mat.getFirstChild.getData);
      data_list   = xml_mat.getElementsByTagName('data');
      for counter = 0:data_list.getLength - 1
        data_item   = data_list.item(counter);
        data_field  = data_item.getAttribute('field');
        data_func   = str2func(char(data_item.getAttribute('func')));
        data_value  = data_item.getAttribute('value');
        mat.(char(data_field)) = data_func(data_value);
      end
      m.addMaterial(mat);      
    end    
  end
%-------------------------------------------------------------------------------
  function addElements(self, m)
    element_list = self.getXMLList( 'element' , 'e' );
    for counter=0:element_list.getLength-1
      xml_element   = element_list.item(counter);
      gn_numbers    = str2num(xml_element.getAttribute('gnn')); %#ok<ST2NM>
      e_number      = str2double(xml_element.getFirstChild.getData);
      et_number     = str2double(xml_element.getAttribute('et'));
      mat_number    = str2double(xml_element.getAttribute('m'));
      
      nodes         = cell(length(gn_numbers));      
      for i=1:length(gn_numbers)
        nodes{i}  = m.getNode(gn_numbers(i));
      end
      et          = m.getElementType(et_number);
      mat         = m.getMaterial(mat_number);

      handle      = str2func(strcat(et.class));

      e = handle(e_number, nodes, et, mat);
      m.addElement(e);
    end
  end
%-------------------------------------------------------------------------------
  function addElementTypes(self, m)
    et_list = self.getXMLList( 'element_type', 'et' );
    for counter = 0:et_list.getLength - 1
      et          = struct;
      xml_et      = et_list.item(counter);      
      et.number   = str2double(xml_et.getFirstChild().getData());
      et.class    = ...
        char(xml_et.getElementsByTagName('type').item(0). ...
        getAttribute('class'));
      et.shape    = ...
        char(xml_et.getElementsByTagName('shape').item(0). ...
        getAttribute('class'));
      et.int_order = ...
        str2num(xml_et.getElementsByTagName('int_order').item(0). ...
        getAttribute('value')); %#ok<ST2NM>
      et.el_order = ...
        str2num(xml_et.getElementsByTagName('el_order').item(0). ...
        getAttribute('value')); %#ok<ST2NM>      
      data_list   = xml_et.getElementsByTagName('data');
      for counter = 0:data_list.getLength - 1
        data_item   = data_list.item(counter);
        data_field  = data_item.getAttribute('field');
        data_func   = str2func(char(data_item.getAttribute('func')));
        data_value  = data_item.getAttribute('value');
        et.(char(data_field)) = data_func(data_value);
      end
      m.addElementType(et);      
    end       
  end
%-------------------------------------------------------------------------------    
  function list = getXMLList( self, container_tag , xml_tag )
    container_list = self.DOM.getElementsByTagName(container_tag);
    if ~isempty(container_list.item(0))
      list = container_list.item(0).getElementsByTagName(xml_tag);
    else
      list = [];
    end
  end
%-------------------------------------------------------------------------------
  function addBcs(self, m)
    bc_list = self.getXMLList( 'boundary_condition' , 'bc' );
    for bc_counter = 0:bc_list.getLength - 1
      xml_bc          = bc_list.item(bc_counter);
      number          = str2double(xml_bc.getFirstChild.getData);
      node_number     = str2double(xml_bc.getAttribute('gnn'));
      dir             = char(xml_bc.getAttribute('dir'));
      typ             = char(xml_bc.getAttribute('typ'));
      val             = str2double(xml_bc.getAttribute('val'));
      
      assert( ...
        all(dir == 'x') || ...
        all(dir == 'y') || ...
        all(dir == 'z'), 'inputfile error');
      assert( ...
        typ == model.BoundaryCondition.FREE_ || ...
        typ == model.BoundaryCondition.DIRICHLET_ || ...
        typ == model.BoundaryCondition.NEUMANN_ , 'inputfile error');
      
      node = m.getNode(node_number);
      bc = model.BoundaryCondition(number, node, typ, dir, val);
      node.addBc(bc);
      m.addBc(bc);
    end
  end
%-------------------------------------------------------------------------------
  function handle = getModelHandle(self) %#ok<INUSD>
    handle      = str2func('model.Model');
  end
%-------------------------------------------------------------------------------
end

end




















