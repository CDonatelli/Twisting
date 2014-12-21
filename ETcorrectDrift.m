%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixing remains of drift

q = NewB11_072.t > -4.5;
plot(NewB11_072.t(q), NewB11_072.orient(q))
plot(NewB11_072.t(q), NewB11_072.orient(q,:))
p = polyfit(NewB11_072.t(q), NewB11_072.orient(q,1), 5);
plot(NewB11_072.t(q), NewB11_072.orient(q,1), NewB11_072.t(q), polyval(p,NewB11_072.t(q)),'r-')
plot(NewB11_072.t(q), NewB11_072.orient(q,1)-polyval(p,NewB11_072.t(q)),'r-')