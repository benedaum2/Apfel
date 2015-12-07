function zeta(alpha)
  h         = 20;
  l         = 200;
  step      = 0.1;
  x         = l/(3*alpha):step:l/2;
  zeta      = h/2*sqrt(3*(1 - 2*alpha*(x/l)));
  plot(x,  zeta);
  plot(x, -zeta);  
end