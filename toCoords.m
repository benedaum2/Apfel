function toCoords(vector, dim) 
coords_vector = zeros(length(vector)/dim, 1 + dim);
for row = 1:length(coords_vector)
  row_skip = (row - 1)*dim;
  for col = 1:dim
    coords_vector(row, 1) = row;
    coords_vector(row, 1 + col) = vector(row_skip + col);
  end
end

disp(coords_vector);