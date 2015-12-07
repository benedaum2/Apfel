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

classdef AnalysisLinear < analysis.Analysis
%===============================================================================
properties( SetAccess = protected )

end


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = AnalysisLinear(filename)
    self@analysis.Analysis(filename);
  end
%-------------------------------------------------------------------------------
% create increment and store it
  function run(self)
    model = self.ih_.createModel();
    inc   = analysis.IncrementLinear(model);
    inc.solve();
    self.addIncrement(inc);
  end  
%-------------------------------------------------------------------------------
% write GiD-postprocessing data
  function writeGid(self)
    tic
    a_name      = horzcat(self.getName(), '-', datestr(now, 29));
    a_name      = regexprep(a_name, 'examples/', '');
    f_name      = horzcat('gid/', a_name, '.res');
    file        = fopen(f_name, 'wt');
    
    fprintf(file, 'GiD Post Results File 1.0\n');
    fprintf(file, '\n');
    
    for i = 1:self.getIncrementAmount()
      inc         = self.getIncrement(i);
      time        = inc.getTime();

      et_numbers = self.writeGaussHeader(file, inc);      
      
      self.writeDisplacementOnNodes(file, a_name, time, inc);
      if inc.getModel().getDim() == 2
        self.writeSigma2dOnGauss(file, a_name, time, inc, et_numbers);
      else
        self.writeSigmaOnGauss(file, a_name, time, inc, et_numbers);
      end
    end
    toc
  end
%-------------------------------------------------------------------------------
end

end





















