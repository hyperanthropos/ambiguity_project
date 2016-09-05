function [ mvar, ev ] = mean_variance( varargin )
% function to calculate mean variance and expected value
%   calculates the variance and expected value of probabilistic offers
%   for multiple probablities and values
%   input = p1, v1, p2, v2, ... pn, vn (probabilities first)

% convert input arguments to vector
varargin = cell2mat(varargin);

% check if input arguments are an even number
if mod(nargin, 2) ~= 0
    error('not a even number of input arguments');
end

% sort probabilites and values into 2 vectors
probabilities = varargin(1, 1:2:nargin);
values = varargin(1, 2:2:nargin);

% check if probabilites are below 1
if max(probabilities) > 1;
    error('some probabilities are above 1 - entered values numbers in worng order?');
end

% calculate expected value and mean variance
ev_vector = NaN(1,nargin/2);
for i = 1:nargin/2
    ev_vector(i) = values(i)*probabilities(i);
end
ev = sum(ev_vector);

mvar_vector = NaN(1,nargin/2);
for i = 1:nargin/2
    mvar_vector(i) = ( values(i)-ev )^2 * probabilities(i);
end
mvar = sum(mvar_vector);

% end function
end



