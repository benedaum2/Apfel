function a = apfel(filename)
  tic
  set_env;
  disp('analysis of Anisotropic Plasticity by Finite ELements');
  disp(strcat('apfel/loading inputfile <', filename, '> ...'));
  a_handle = io.BaseIH.readAnalysisType(filename);
  a = a_handle(filename);
  % a_filename  = horzcat(a.getName(), '-', datestr(now, 29));
  % diary(horzcat(a_filename, '.log'));
  % diary on
  
  a.run();
  disp(strcat('apfel/finished ...'));

  % save(horzcat(a_filename, '.mat'), 'a');
  toc
  % diary off
end

