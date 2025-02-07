function[out_struct] = model_convert(obj,t,Y)
% MODEL_CONVERT creates a structure of results calculated by simulation.
% 
% [out_struct] = chamber.model_convert(t, Y)
% t is the time vector and Y is the matrix calculated by simulation.
% The data from Y is exported to out_struct, so that out_struct contains
% following fields:
% 
% CMD - Count Median Diameter
% Ntot - Total particle concentration
% Vtot - Total particle volume
% Dpmean - Mean diameter
% Mtot - Total mass of particles
% Mwall - Mass lost to wall as particles
% Mdilu - Mass diluted as aerosols
% Mvdilu - Mass diluted as vapor
% Mvwall - Mass condensed to wall as vapor
% distr - dN/dlogDp distribution as a function of time, interpolated to
%         denser grid
% distr_original - The original dN/dlogDp distribution

% (c) Miikka Dal Maso & Pauli Simonen 2013
%
% Version history:
% 2013-05-24    0.1.0
% 2013-06-06    0.1.1 Dp0 will be defined differently if fixed sections is
%                     on.
% 2013-06-10    0.1.2 Added distribution smoothing if fixed sections are
%                     used.
% 2013-06-20    0.1.3 Added condensation sink to chamber walls. The mass of
%                     vapor condensed to walls is saved into Mvwall.

initials = obj.initials;

mv     = initials.vap_molmass;
rool   = initials.particle_dens;

nSec = obj.sections;

% Create a new lognormal vector containing the diameters. The number of
% sections in this vector should be much more than the number of sections
% in original distribution. This is because interpolation may cause a big
% error if this grid is too sparse and the distribution is simultaniously
% very narrow.
Dp0 = logspace(initials.Dp_min, initials.Dp_max, initials.output_sections);

% Preallocate the variables for the loop.
Ntot=zeros(1,length(t));
dN=zeros(length(t),length(Dp0));

dist_original=zeros(length(t)+1,2*length(Y(1,nSec+2:(2*nSec+1)))+2);

dist_original(2:end,1) = t;

Vtot=zeros(1,length(t));
out_struct.CMD = zeros(1,length(t));

for i = 1:length(t),
    Ntot(i) = sum(Y(i,2:nSec+1));
    Ni = Y(i,2:nSec+1);
    Dpi = Y(i,nSec+2:(2*nSec+1));
    
    dNi = obj.N_to_dlog(Dpi,Ni);
    
    dist_original(i+1, 3:end)=[dNi, Dpi];
    dist_original(i+1, 2) = Ntot(i);
    
    dN(i,:) = interp1(log10(Dpi),dNi,log10(Dp0),'linear',0);
    
    dV = (pi./6).*Dpi.^3;
    Vtot(i) = sum(Ni.*dV);
    
    % Calculate CMD. Interpolate Ni to Dp0 and find such a point in Dp0
    % that the amount of particles that have smaller diameter equal the
    % amount of particles that have bigger diameter.
    Ni2=interp1(Dpi,Ni,Dp0,'linear',0); %First interpolate Ni to denser grid.
    B=0;  % Preallocate
    j=1;  % Preallocate
    while(B < Ntot(i)/2 && j < length(Dp0)) % Run the loop as long as the sum of particles is smaller than the total number of particles.
        B=sum(Ni2(1:j));  % Sum the number of particles from the beginning of the distribution to j:s index of distribution.
        j = j+1;
    end
    % Now we know that the half of total number of particles is in sections
    % Dp0(1:j). In other words, CMD = Dp0(j).
    out_struct.CMD(i)=Dp0(j);
    
end

out_struct.distr_original = dist_original;

% Get the distribution and save it in format:
% 
% (time) (Ntot)     Dp0(1)         Dp0(2)        ...  Dp0(n)
%  t1    Ntot(t1)   N(Dp0(1), t1)  N(Dp0(2), t1)      N(Dp0(n), t1)
%  .      .         .              .                  .
%  .      .         .              .                  .
%  .      .         .              .                  .

[ro, co] = size(dN);
dist = zeros(ro+1,co+2); % Preallocate the distribution array.
dist(2:end,1) = t(:);    % Insert the time vector to the first column of dist.
dist(2:end,2) = Ntot(:); % Insert Ntot to the second column of dist.
dist(1,3:end) = Dp0;     % The first row of dist tells the Dp0s of distribution.
dist(2:end,3:end) = dN;  % Then each column tells the particle concentration
                         % of corresponding section (Dp0) for all time
                         % points.
                         
out_struct.distr = dist; % Save the distribution to output.

out_struct.Y = Y; % Save the original Y:

out_struct.vap = Y(:,1); % Save the vapor concentration.
out_struct.tim = t(:);   % Save the time vector.


% get a mean volume per particle:
vpart = Vtot./Ntot;
% get a mean diameter of the particles:
Dpmean = (6.*vpart./pi).^(1./3);

out_struct.Ntot = Ntot(:); % Save Ntot values.
out_struct.Vtot = Vtot(:); % Save Vtot values
out_struct.Dpmean= Dpmean(:); % Save Dpmean values

% Avogadro constant:
NA=6.022e23;

% Calculate the total particle mass and lost mass. The amount of lost vapor
% and aerosol molecules is known and they are converted here to mass.
% all [M] = g/cm^3 !!!
out_struct.Mtot = Vtot.*rool*1e6; % Total mass of particles ([Vtot]=m^3/cm^3, [rool]=g/cm^3)
out_struct.Mwall= Y(:,2*nSec+2).*mv./NA; % Mass lost to wall
out_struct.Mdilu= Y(:,2*nSec+3).*mv./NA; % Mass diluted as aerosols
out_struct.Mvdilu=Y(:,2*nSec+4).*mv./NA; % Mass diluted in gas phase

% If there is a wallsink for vapor molecules, calculate the mass lost to
% wall as vapor, too:
if(length(Y(1,:)) == 2*nSec+5)
    out_struct.Mvwall = Y(:,2*nSec+5).*mv./NA; % Mass lost to wall as vapor
else out_struct.Mvwall = 0;
end

end
