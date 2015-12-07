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

classdef AnalysisPlasticity < analysis.Analysis
%===============================================================================
properties( SetAccess = protected )
  time_steps_
  delta_time_
end


%===============================================================================
methods (Access = public)
%-------------------------------------------------------------------------------    
% Constructor
  function self = AnalysisPlasticity(filename)
    self@analysis.Analysis(filename);
    self.time_steps_  = self.ih_.readTimeSteps();
    tau               = [0, self.time_steps_(1:end-1)];
    self.delta_time_  = self.time_steps_ - tau;
  end
%-------------------------------------------------------------------------------
  function time = getTime(self, number)
    time              = self.time_steps_(number);
  end     
%-------------------------------------------------------------------------------
  function initialize(self, filename)
    self.ih_ = io.PlasticityIH(filename);
  end      
%-------------------------------------------------------------------------------
% sequentially creates increments and stores them
  function run(self)
    model_n   = self.ih_.createModel();
    for index = 1:length(self.time_steps_)
      model_n1  = self.ih_.createModel();
      model_n1.linkTo(model_n);
      inc       = analysis.IncrementPlasticity(index, model_n1, ...
        self.delta_time_(index), self.time_steps_(index));
      disp(horzcat(class(self), ' time: ', ...
        num2str(self.getTime(index), '%.4f')));      
      [success, model_n]   = inc.solve();
      if ~success
        disp(horzcat(class(self), ' solve failed, analysis terminated'));
        self.addIncrement(inc);        
        return;
      end
      self.addIncrement(inc);
    end
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

      self.writeDisplacementOnNodes(file, a_name, time, inc);
      et_numbers = self.writeGaussHeader(file, inc);
      self.writeSigmaOnGauss(file, a_name, time, inc, et_numbers);
      self.writeKappaOnGauss(file, a_name, time, inc, et_numbers);
      self.writeSigmaVOnGauss(file, a_name, time, inc, et_numbers);
    end
    toc
  end  
%-------------------------------------------------------------------------------
end

%===============================================================================
methods (Access = protected)
%-------------------------------------------------------------------------------
% writes plastic stress to .res-file
  function writeSigmaOnGauss(self, file, a_name, time, inc, et_numbers)
    for j = 1:length(et_numbers)
      fprintf(file, 'ResultGroup "%s" %1.4f OnGaussPoints "%s"\n',  ...
        a_name, time, horzcat('gauss-et-', num2str(et_numbers(j))));
      fprintf(file, 'ResultDescription "Sigma" Matrix:6\n');
      fprintf(file, horzcat('ComponentNames "Sigma xx" "Sigma yy" ', ...
        '"Sigma zz" "Sigma xy" "Sigma yz" "Sigma zx"\n\n'));  
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
            el.getPlasticityPoint(i).getSigN1());
        end
      end
      fprintf(file, 'End Values\n\n');
    end
  end
%-------------------------------------------------------------------------------
  function writeKappaOnGauss(self, file, a_name, time, inc, et_numbers)
    for j = 1:length(et_numbers)    
      fprintf(file, 'ResultGroup "%s" %1.4f OnGaussPoints "%s"\n',  ...
        a_name, time, horzcat('gauss-et-', num2str(et_numbers(j))));
      fprintf(file, 'ResultDescription "Kappa" Scalar\n');
      fprintf(file, horzcat('ComponentNames "Kappa"\n\n'));
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
          fprintf(file, '%+3.7e\n', ...
            el.getPlasticityPoint(i).getKappa());
        end
      end
      fprintf(file, 'End Values\n\n');
    end
  end
%-------------------------------------------------------------------------------
  function writeSigmaVOnGauss(self, file, a_name, time, inc, et_numbers)
    for j = 1:length(et_numbers)
      fprintf(file, 'ResultGroup "%s" %1.4f OnGaussPoints "%s"\n',  ...
        a_name, time, horzcat('gauss-et-', num2str(et_numbers(j))));
      fprintf(file, 'ResultDescription "Sigma v" Scalar\n');
      fprintf(file, horzcat('ComponentNames "Sigma v"\n\n'));
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
          fprintf(file, '%+3.7f\n', ...
            el.getPlasticityPoint(i).getSigV());
        end
      end
      fprintf(file, 'End Values\n\n');
    end
  end  
%-------------------------------------------------------------------------------
end

end





















