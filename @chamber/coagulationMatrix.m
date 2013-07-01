function out = coagulationMatrix(Dp,ind)
% COAGULATIONMATRIX calculates the matrix for coagulation between sections.
% 
% coagulationMatrix(Dp, ind)

% (c) Miikka Dal Maso 2013
%
% Version history:
% 2013-05-24    0.1.0


le = length(Dp);
out = zeros(le,le);

vol = (pi./6).*(Dp.^3);
cVol = (pi./6).*(Dp(ind).^3);

for i = 1:le,
    newV = vol(i)+cVol; % new volume of the colliding particle
    % find the two surrounding volumes
     ve1 = vol-newV;     
     ve2 = ve1./abs(ve1);
     ix = find(diff(ve2)); % this is the smaller of the volumes to divide between...
     
     if isempty(ix), % if no found, put the particles in the largest bin
            out(i,end) = out(i,end)+newV./vol(end);
     else 
%             out(i,ix)   = (vol(ix+1)-newV)./(vol(ix+1)-vol(ix));
%             out(i,ix+1) = (newV-vol(ix))./(vol(ix+1)-vol(ix));       
            out(i,ix+1) = (newV-vol(ix))./(vol(ix+1)-vol(ix));  
            out(i,ix) = 1-out(i,ix+1);            
     end
     out(i,isnan(out)) = 0;
     out(i,isinf(out)) = 0;
end
end


        








