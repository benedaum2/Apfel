function make_avi(a)
a_filename  = horzcat(a.getName(), '-', datestr(now, 29));
%directory   = 'figures/';
for i = 1:a.getIncrementAmount()
  close all;
  frame = post(a, i);
  frame2im(frame);
  %i_filename = horzcat(directory, a_filename, '_', i);
  %saveas(fig, i_filename, 'jpg')
  frames(i) = frame;
end
movie2avi(frames, a_filename, 'quality', 100, 'fps', 2);
close all;
%command = horzcat('ffmpeg -y -i ./', a_filename, '.avi -r 1 ./', a_filename, '.avi' );
%disp(command)
%system(command)
