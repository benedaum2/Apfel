function make_tif(a)
a_filename  = horzcat(a.getName(), '-', datestr(now, 29));
directory   = horzcat('figures/', a_filename);
for i = 1:a.getIncrementAmount(),
  close all;
  post(a, i);
  zoom(0.8);
  mkdir(directory);
  i_filename  = horzcat(directory, '/frame_', num2str(i));
  saveas(gcf, i_filename, 'tif')
end
close all;

