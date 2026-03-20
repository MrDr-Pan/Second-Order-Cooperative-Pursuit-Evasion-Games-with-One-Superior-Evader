lambda=0.8;
alpha=90/180*pi;
L2=1;
L1=lambda*L2;
L=sqrt(L1^2+L2^2-2*L1*L2*cos(alpha));
alpha1=asin(sin(alpha)/L*L1);
alpha2=asin(sin(alpha)/L*L2);
dtheta=1/180*pi;

L2_new=L/sin(alpha)*sin(alpha2-dtheta);
L1_new=L/sin(alpha)*sin(alpha1+dtheta);

L1_new/L2_new