function make_ps(a)

a_filename  = horzcat(a.getName(), '-', datestr(now, 29), '.ps');
a_filename  = regexprep(a_filename, 'examples', 'figures');
pause(0.5);
for i = 1:a.getIncrementAmount()
  close all;
  %pause(3);
  post(a, i);
  %pause(3);
  if i == 1
    print ( '-dpsc2', a_filename )
  else
    print ( '-dpsc2', a_filename, '-append' )
  end
end
close all;

