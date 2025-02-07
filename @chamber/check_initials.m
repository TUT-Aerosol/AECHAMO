function [] = check_initials(obj)
%CHECK_INITIALS Checks the initial parameters and reports errors.
% 
%   If the initial parameters are set using function chamber.initialize,
%   there is no need to check them with this function anymore, as the
%   function chamber.initialize has already done it.
%
%   If the initial parameters are set using function chamber.set_params, the
%   parameters should be checked afterwards using this function.

% (c) Pauli Simonen 2013
%
% Version history:
% 2013-06-04    0.1.0 Separated from function initialize.


initials = obj.initials;

% Check that coag_mode is either 'coag' or 'aggl'.
if(strcmp(initials.coag_mode,'coag') == 0)
    if(strcmp(initials.coag_mode,'aggl') == 0)
        error('Argument coag_mode must be either ''coag'' or ''aggl''.');
    end
end

% Check that method is 'moving_sectional', 'moving_center' or
% 'moving_center_beta'.
if(strcmp(initials.method,'moving_sectional') == 0)
    if(strcmp(initials.method,'moving_center') == 0)
        if(strcmp(initials.method, 'moving_center_beta') == 0)
            error('Parameter ''method'' must be one of the following: ''moving_sectional'', ''moving_center'' or ''moving_center_beta''.');
        end
    end
end
          

% Check that Dp_min and Dp_max are exponents:
if(abs(initials.Dp_min) < 1) 
    error('Argument ''Dp_min'' must be an exponent. The minimum diameter will be 10^(Dp_min).');
end

if(abs(initials.Dp_max) < 1)
    error('Argument ''Dp_max'' must be an exponent. The maximum diameter will be 10^(Dp_max).');
end

% Then check that Dp_max > Dp_min:
if(initials.Dp_min >= initials.Dp_max)
    error('''Dp_min'' must be smaller than ''Dp_max''.');
end

% Make sure that sigma(s) of distribution is > 1.0:
for i=1:length(initials.sigma)
    if(initials.sigma(i) <= 1.0)
        error('''sigma'' must be bigger than 1.0.');
    end
end

% Check that the time vector is a vector.
if(length(initials.tvect) < 2)
    error('Argument ''tvect'' must be a vector.');
end

% If 'dilu_coeff' has been defined as an array, check that it has two
% columns and the same last and first point as obj.tvect.
if(isscalar(initials.dilu_coeff) == 0)  % Is it an array?
    % Check that there are two columns in dilu_coeff:
    [rows cols]=size(initials.dilu_coeff);
    if(cols ~=2)
        error('The argument ''dilu_coeff'' must consist of two columns.');
    end
    % Check that the first element of dilu_coeff(:,1) is the same as the
    % first element of tvect:
    if(initials.dilu_coeff(1,1) ~= initials.tvect(1))
        error('The first column of argument ''dilu_coeff'' must have the same first value as ''tvect''.');
    end
    % Check that the last element of dilu_coeff(:,1) is the same as the last
    % element of tvect:
    if(initials.dilu_coeff(rows,1) ~= initials.tvect(length(initials.tvect)))
        error('The first column of argument ''dilu_coeff'' must have the same last value as ''tvect''.');
    end
end

% The same check for gas_source if it is a vector.
if(isscalar(initials.gas_source) == 0)  % Is it an array?
    % Check that there are two columns in gas_source:
    [rows cols]=size(initials.gas_source);
    if(cols ~=2)
        error('The argument ''gas_source'' must consist of two columns.');
    end
    % Check that the first element of gas_source(:,1) is the same as the
    % first element of tvect:
    if(initials.gas_source(1,1) ~= initials.tvect(1))
        error('The first column of argument ''gas_source'' must have the same first value as ''tvect''.');
    end
    % Check that the last element of gas_source(:,1) is the same as the last
    % element of tvect:
    if(initials.gas_source(rows,1) ~= initials.tvect(length(initials.tvect)))
        error('The first column of argument ''gas_source'' must have the same last value as ''tvect''.');
    end
end

% Check the particle source as well.
if(isscalar(initials.part_source) == 0)  % Is it an array?
    % Check that there are three columns in part_source:
    [rows, cols, depth]=size(initials.part_source);
    if(cols ~=3)
        error('The argument ''part_source'' must consist of three columns.');
    end
    % Check that the first element of part_source(:,1) is the same as the
    % first element of tvect:
    if(initials.part_source(1,1) ~= initials.tvect(1))
        error('The first column of argument ''part_source'' must have the same first value as ''tvect''.');
    end
    % Check that the last element of part_source(:,1) is the same as the last
    % element of tvect:
    if(initials.part_source(rows,1) ~= initials.tvect(length(initials.tvect)))
        error('The first column of argument ''part_source'' must have the same last value as ''tvect''.');
    end
end


% Check the value of Df. Should be 1.0 < Df < 3.0.
if(initials.Df < 1.0)
    error('chamber.initialize: Parameter Df must be larger than 1.0.');
elseif(initials.Df > 3.0)
    error('chamber.initialize: Parameter Df must be smaller than 3.0.');
end

% If mu, N and sigma are vectors, make sure that all these have same
% length, because the distribution is then sum 
% D(mu(1),sigma(1),N(1)) + ... + D(mu(n),sigma(n),N(n)), where D denotes
% lognormal distribution.
num_of_distr = length(initials.mu);
if(length(initials.N) ~= num_of_distr || length(initials.sigma) ~= num_of_distr)
    error('chamber.initialize: Parameters ''mu'', ''N'' and ''sigma'' must have equal lengths.');
end

% If user has defined particle number distribution, its length must equal
% the number of sections.
% if(~isscalar(initials.distr))
    if(obj.sections ~= length(obj.number_distribution))
        error('Number distribution is defined, but its length is not the same as number of sections.');
    end
% end

% Then check that the number of section limits == 
% (number of sections - 1)
if(length(obj.Dplims) ~= (length(obj.Dps)-1))
    error('The length of Dplims must equal (number of sections -1).');
end

% The length of center diameter vector must equal the
% number of sections. In addition, every center value must be larger than
% the lower limit of section.
if(length(obj.center_diameters > 1))
    % First check that the length equals number of sections:
    if(obj.sections ~= length(obj.center_diameters))
        error('The number of center diameters does not equal the number of sections.');
    end
        % If the length is correct, check that every
    % center diameter > lower limit of section:
    for i=2:obj.sections
        if(obj.center_diameters(i) < obj.Dplims(i-1))
            error('The lower limit of section %i is larger than the center diameter of corresponding section.',i);
        end
    end
    % And that every center diameter < upper limit of section:
    for i=1:obj.sections-1
        if(obj.center_diameters(i) > obj.Dplims(i))
            error('The upper limit of section %i is smaller than the center diameter of corresponding section.',i);
        end
    end
end

% If fixed sectional method is used, make sure that the time vector has
% constant spacing:
% if(initials.fixed_sections ~= 0)
if(strcmp(initials.method,'moving_center'))
    difference = diff(initials.tvect);
    if(~all(difference == difference(1)))
        error('The time vector must have constant spacing when the fixed sectional method is used.');
    end
end


end

