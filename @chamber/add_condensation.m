function [ dy ] = add_condensation(dy, y, initials, index)
%ADD_CONDENSATION Calculates the condensation/evaporation onto particles

% (c) Pauli Simonen 2013
% Version history:
% 2013-06-10    0.1.0
% 2013-06-20    0.1.1 Change y indices because length of y changed when
%                     condensation sink to wall for vapor was added.

lambda = initials.lambda;
alfa = initials.stick_coeff;
diffu = initials.diff_coeff;
Csat = initials.satu_conc;
mv     = initials.vap_molmass ; % the condensing vapor molecular weight
rool   = initials.particle_dens ; % the particle density
nSec   = initials.sections; % the number of size sections

i = index;

NA = 6.022e23;

Kn = (2.*lambda)./y(nSec+1+i); % Knudsen number
betam = (Kn+1)./((0.377.*Kn)+1+(4/(3.*alfa)).*(Kn.^2)+(4/(3.*alfa)).*Kn);


% if(initials.fixed_sections == 0)
    % I is the flux of molecules to the particle phase    
    I = 2.*pi.*max([y(nSec+1+i) 0]).*1e2.*diffu.*(y(1)-Csat).*betam; %1/s
    % Move the sections by condensation:
    dy(nSec+1+i) = dy(nSec+1+i)+(2.*mv.*I)./(pi.*rool.*y(nSec+1+i).^2.*NA.*1e6); % particle diameter (m/s)
    dy(1) = dy(1) - y(i+1).*I;
% else
%     % I is the flux of molecules to the particle phase    
%     I = 2.*pi.*max([y(nSec+1+i) 0]).*1e2.*diffu.*(y(1)-Csat).*betam; %1/s
% 
%     % Move the variable diameters by condensation:
%     dy(nSec+1+i) = dy(nSec+1+i)+(2.*mv.*I)./(pi.*rool.*y(nSec+1+i).^2.*NA.*1e6); % particle diameter (m/s)
%     dy(1) = dy(1) - y(i+1).*I;
% end

end

