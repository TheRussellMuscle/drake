function runDircolCycle
% find stable limit cycle 

p = CompassGaitPlant();

x0 = zeros(4,1); tf0 = 1; xf = zeros(4,1);
%utraj0 = {PPTrajectory(foh(linspace(0,tf0,15),randn(1,15))),PPTrajectory(foh(linspace(0,tf0,15),randn(1,15)))};
utraj0 = {PPTrajectory(foh(linspace(0,tf0,5),randn(1,5))),PPTrajectory(foh(linspace(0,tf0,5),randn(1,5)))};

con.mode{1}.mode_num = 1;
con.mode{2}.mode_num = 2;

con.mode{1}.u.lb = p.umin;
con.mode{1}.u.ub = p.umax;
con.mode{2}.u.lb = p.umin;
con.mode{2}.u.ub = p.umax;

% make sure I take a reasonable sized step:
con.mode{1}.xf.lb = [pi/8;-inf;-inf;-inf];

con.periodic = true;

con.mode{1}.T.lb = .1;   
con.mode{1}.T.ub = 2;
con.mode{2}.T.lb = .1;   
con.mode{2}.T.ub = 2;

options.method='dircol';
tic
%options.grad_test = true;
[utraj,xtraj,info] = trajectoryOptimization(p,{@cost,@cost},{@finalcost,@finalcost},{x0, [-pi/4;pi/4;2.0;0]},utraj0,con,options);
if (info~=1) error('failed to find a trajectory'); end
toc

t = xtraj.getBreaks();
t = linspace(t(1),t(end),100);
x = xtraj.eval(t);
plot(x(1,:),x(2,:));

v = CompassGaitVisualizer(p);
v.playback_speed = .2;
playback(v,xtraj);

end



      function [g,dg] = cost(t,x,u);
        R = 1;
        g = sum((R*u).*u,1);
        dg = [zeros(1,1+size(x,1)),2*u'*R];
      end
      
      function [h,dh] = finalcost(t,x)
        h=t;
        dh = [1,zeros(1,size(x,1))];
      end
      