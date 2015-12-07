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

classdef Analysis < handle
%===============================================================================
properties( SetAccess = protected )
  name_
  inc_cell_ = {}
  ih_
end


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = Analysis(filename)
    self.name_ = filename(1:end-4);    
    self.initialize(filename)
  end
%-------------------------------------------------------------------------------
  function initialize(self, filename)
    self.ih_ = io.BaseIH(filename);
  end
%-------------------------------------------------------------------------------
  function name = getName(self)
    name = self.name_;
  end  
%-------------------------------------------------------------------------------
  function getIncrement_r = getIncrement(self, inc_num)
    getIncrement_r = self.inc_cell_{inc_num};
  end  
%-------------------------------------------------------------------------------
  function getIncrementAmount_r = getIncrementAmount(self)
    getIncrementAmount_r = length(self.inc_cell_);
  end
%-------------------------------------------------------------------------------
  function getUHats_r = getUHats(self)
    getUHats_r = self.inc_cell_{1}.getUHat();
    for index = 2:length(self.inc_cell_)
      getUHats_r(:,index) = self.inc_cell_{index}.getUHat();
    end
  end
%-------------------------------------------------------------------------------
end

%===============================================================================
methods (Access = protected)
%-------------------------------------------------------------------------------
  function addIncrement(self, inc)
    self.inc_cell_{length(self.inc_cell_) + 1} = inc;
  end
%-------------------------------------------------------------------------------
  function writeDisplacementOnNodes(self, file, a_name, time, inc)
    fprintf(file, 'ResultGroup "%s" %1.4f OnNodes\n', a_name, time);
    if inc.getModel.getDim() == 2
      fprintf(file, 'ResultDescription "Displacement" Vector:2\n');
      fprintf(file, horzcat('ComponentNames "Displacement u" ', ...
        '"Displacement v"\n'));
    elseif inc.getModel.getDim() == 3
      fprintf(file, 'ResultDescription "Displacement" Vector:3\n');      
      fprintf(file, horzcat('ComponentNames "Displacement u" ', ...
        '"Displacement v" "Displacement w"\n'));
    else
      fprintf(file, 'dimension error\n');
    end
    fprintf(file, '\n');      
    fprintf(file, 'Values\n');
    for n = 1:inc.getModel().getNodeAmount()
      node = inc.getModel().getNode(n);
      disp_coords = node.getSpaCoords() - node.getMatCoords();
      fprintf(file, '%03i %+3.7f %+3.7f %+3.7f', ...
        [node.getNumber() disp_coords]);
      fprintf(file, '\n');
    end
    fprintf(file, 'End Values\n');
    fprintf(file, '\n');
  end
%-------------------------------------------------------------------------------
% writes elastic stress to .res-file
  function writeSigmaOnGauss(self, file, a_name, time, inc, et_numbers)
    for j = 1:length(et_numbers)
      fprintf(file, 'ResultGroup "%s" %1.4f OnGaussPoints "%s"\n',  ...
        a_name, time, horzcat('gauss-et-', num2str(et_numbers(j))));
      fprintf(file, 'ResultDescription "Sigma" Matrix:6\n');
      fprintf(file, horzcat('ComponentNames "Sigma xx" "Sigma yy" ', ...
        '"Sigma zz" "Sigma xy" "Sigma yz" "Sigma zx"\n'));
      fprintf(file, '\n');      
      fprintf(file, 'Values\n');
      for e = 1:inc.getModel().getElementAmount()
        el = inc.getModel().getElement(e);
        if el.et_.number ~= et_numbers(j)
          continue;
        end
        for i = 1:el.getIntPointAmount()
          if i == 1
            fprintf(file, '%03i ', el.getNumber());
          else
            fprintf(file, '    ');
          end
          fprintf(file, '%+3.7f %+3.7f %+3.7f %+3.7f %+3.7f %+3.7f\n', ...
            el.getSigma(el.getIntPoint(i).getRefCoords()));
        end
      end
      fprintf(file, 'End Values\n');
    end
  end
%-------------------------------------------------------------------------------
% writes elastic stress to .res-file
  function writeSigma2dOnGauss(self, file, a_name, time, inc, et_numbers)
    for j = 1:length(et_numbers)
      fprintf(file, 'ResultGroup "%s" %1.4f OnGaussPoints "%s"\n',  ...
        a_name, time, horzcat('gauss-et-', num2str(et_numbers(j))));
      fprintf(file, 'ResultDescription "Sigma" Matrix:3\n');
      fprintf(file, horzcat('ComponentNames "Sigma xx" "Sigma yy" "Sigma xy"\n'));
      fprintf(file, '\n');      
      fprintf(file, 'Values\n');
      for e = 1:inc.getModel().getElementAmount()
        el = inc.getModel().getElement(e);
        if el.et_.number ~= et_numbers(j)
          continue;
        end
        for i = 1:el.getIntPointAmount()
          if i == 1
            fprintf(file, '%03i ', el.getNumber());
          else
            fprintf(file, '    ');
          end
          fprintf(file, '%+3.7f %+3.7f %+3.7f\n', ...
            el.getSigma(el.getIntPoint(i).getRefCoords()));
        end
      end
      fprintf(file, 'End Values\n');
    end
  end
%-------------------------------------------------------------------------------
  function et_numbers = writeGaussHeader(self, file, inc)
    et_numbers  = [];
    for el_index = 1:inc.model_.getElementAmount()
      el          = inc.getModel().getElement(el_index);
      et_number   = el.getEt().number;
      if all(ones(size(et_numbers))*et_number ~= et_numbers) || ...
          isempty(et_numbers)
        % new elementtype found - insert to list        
        et_numbers  = [et_numbers et_number]; %#ok<AGROW>
        gauss_name  = horzcat('gauss-et-', num2str(et_number));
        fprintf(file, 'GaussPoints "%s" ', gauss_name);
        et_name     = 'unknown';
        if     isa(el, 'model.element.Hexahedron')
          et_name     = 'Hexahedra';
        elseif isa(el, 'model.element.Quadrilateral')
          et_name     = 'Quadrilateral';
        elseif isa(el, 'model.element.Triangle')
          et_name     = 'Triangle';          
        end
        fprintf(file, 'ElemType %s\n', et_name);
        fprintf(file, 'Number Of Gauss Points: %i\n', el.getIntPointAmount());
        fprintf(file, 'Natural Coordinates: Given\n');
        for ip_index=1:length(el.getIntPoints())
          for dir_index=1:length(el.getIntPoint(ip_index).getRefCoords)
            fprintf(file, '%+1.9f ', ...
              el.getIntPoint(ip_index).getRefCoord(dir_index));
          end
          fprintf(file, '\n');
        end
        fprintf(file, 'End GaussPoints\n');
        fprintf(file, '\n');        
      end
    end
  end  
%-------------------------------------------------------------------------------
end

%===============================================================================
methods (Abstract, Access = public)
  run(self)
  writeGid(self)
end

end




















