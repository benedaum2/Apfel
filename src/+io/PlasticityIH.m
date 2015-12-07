classdef PlasticityIH < io.BaseIH
% extended inputhandling for plasticity
  
%===============================================================================  
properties( Access = protected )

end


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------  
  function self = PlasticityIH(filename)
    self@io.BaseIH(filename);
  end
%-------------------------------------------------------------------------------
  function time_steps = readTimeSteps(self)
    ts_list = self.getXMLList('time_step', 'ts');
    
    if isempty(ts_list)
      error('specify atleast one time step')
    end
    
    last_item = ts_list.item(ts_list.getLength() - 1);
    if (str2double(last_item.getAttribute('time')) ~= 1.0) 
      disp(' ~~~warning: last time step not 1.0~~~');
    end
    
    time_steps  = zeros(1, ts_list.getLength());
    prev_time   = 0;
    for counter = 0:ts_list.getLength() - 1
      ts_item     = ts_list.item(counter);
      ts_number   = str2double(ts_item.getFirstChild.getData);
      assert(ts_number == counter + 1, ...
        'xml-item not in correct order')      
      ts_time       = str2double(ts_item.getAttribute('time'));
      assert(prev_time < ts_time, ...
        'Increment time has to be strictly increasing')
      time_steps(ts_number) = ts_time;
    end    
  end  
%-------------------------------------------------------------------------------
  function flow_rule = readFlowRule(self)
    fr_xml        = self.DOM.getElementsByTagName('flow_rule').item(0);
    fr_id         = char(fr_xml.getElementsByTagName('type').item(0). ...
        getAttribute('class'));
    fr_handle     = str2func(strcat(fr_id));
    
    data          = struct;
    data_list     = fr_xml.getElementsByTagName('data');
    for counter   = 0:data_list.getLength - 1
      data_item     = data_list.item(counter);
      data_field    = data_item.getAttribute('field');
      data_func     = str2func(char(data_item.getAttribute('func')));
      data_value    = data_item.getAttribute('value');
      data.(char(data_field)) = data_func(data_value);
    end    
    
    flow_rule     = fr_handle(data);  
  end
%-------------------------------------------------------------------------------
end
  
%===============================================================================
methods (Access = protected)
%-------------------------------------------------------------------------------
  function addElements(self, m)
    element_list = self.getXMLList( 'element' , 'e' );
    
    % only one flow rule  for the entire model
    flow_rule     = self.readFlowRule(); 
    
    for counter=0:element_list.getLength-1
      xml_element   = element_list.item(counter);
      gn_numbers    = str2num(xml_element.getAttribute('gnn')); %#ok<ST2NM>
      e_number      = str2double(xml_element.getFirstChild.getData);
      et_number     = str2double(xml_element.getAttribute('et'));
      mat_number    = str2double(xml_element.getAttribute('m'));
      
      nodes         = cell(length(gn_numbers));
      for i=1:length(gn_numbers)
        nodes{i} = m.getNode(gn_numbers(i));
      end
      et            = m.getElementType(et_number);
      mat           = m.getMaterial(mat_number);

      handle        = str2func(strcat(et.class));
      
      e             = handle(e_number, nodes, et, mat, flow_rule);
      
      assert(isa(e, 'plasticity.element.Element'));
      m.addElement(e);
    end
  end
%-------------------------------------------------------------------------------
  function handle = getModelHandle(self) %#ok<INUSD>
    handle      = str2func('plasticity.Model');
  end
%-------------------------------------------------------------------------------  
end

end




















