function [good_float_ids, mean_prof, std_prof, mean_pres] = ...
    show_profiles(float_ids, variables, varargin)
% show_profiles  This function is part of the
% MATLAB toolbox for accessing BGC Argo float data.
%
% USAGE:
%   [good_float_ids, mean_prof, std_prof, mean_pres] = ...
%       show_profiles(float_ids, variables, varargin)
%
% DESCRIPTION:
%   This an intermediary function that downloads profile(s) for the given
%   float(s) and calls plot_profile to create the plot(s).
%
% INPUTS:
%   float_ids  : WMO ID(s) of the float(s)
%   variables  : cell array of variable(s) (i.e., sensor(s)) to show
%                (if not set: {'DOXY'} (=O2) is used)
%
% OPTIONAL INPUTS:
%   'depth',[min max] : minimum and maximum depth levels to plot
%   'float_profs',fp : cell array with per-float indices of the profiles to
%                   be shown, as returned by select_profiles
%   'method',method : by default (method='all') all profiles from each float
%                   are shown in one plot per variable;
%                   use method='mean' to plot mean and standard deviation
%                   across profiles instead
%   'obs',on/off  : by default (same as: 'obs','off') only lines are shown
%                   for each profile; 'obs','on' shows points on the profile
%                   at which each measurement was made
%   'per_float',per_float : show profiles separately for each float (1)
%                   or all in one plot (0); default: 1
%                   either option can be used with 'all' and 'mean' methods
%   'png',basename: if basename is not empty, png files will be created
%                   for all plots; if per_float is used, the file
%                   names will be <basename>_<WMOID>_<variable>.png,
%                   if per_float is not used, the file names will be
%                   <basename>_<variable>.png
%   'qc',flags    : show only values with the given QC flags (as an array)
%                   0: no QC was performed;
%                   1: good data;
%                   2: probably good data;
%                   3: probably bad data that are potentially correctable;
%                   4: bad data;
%                   5: value changed;
%                   6,7: not used;
%                   8: estimated value;
%                   9: missing value
%                   default setting: 0:9 (all flags)
%                   See Table 7 in Bittig et al.:
%                   https://www.frontiersin.org/files/Articles/460352/fmars-06-00502-HTML-r1/image_m/fmars-06-00502-t007.jpg
%   'raw',raw     : plot raw, i.e., unadjusted data if set to 'yes';
%                   default: 'no' (i.e., plot adjusted data if available)
%   'title_add',text : add the given text to the end of all titles
%   'var2',variable: if variable is not empty, profiles of this second
%                   variable will be plotted; if it is the same type as the
%                   first variable (e.g., DOXY2 compared to DOXY), it will
%                   be plotted using the same axes; otherwise, right and
%                   top axes will be used for the second variable
%
% OUTPUTS:
%   good_float_ids : array of the float IDs whose Sprof files were
%                   successfully downloaded or existed already
%   mean_prof :     mean across profiles (cell array of cell arrays
%                   ({variable}{float}) of column vectors if per_float
%                   is set to 1,
%                   cell array ({variable}) of column vectors if per_float
%                   is set to 0)
%   std_prof  :     standard deviation across profiles (same type as mean_prof)
%   mean_pres :     mean pressure across profiles (cell array of column
%                   vectors if per_float is set to 1,
%                   column vector if per_float is 0)
%
% AUTHORS:
%   H. Frenzel, J. Sharp, A. Fassbender (NOAA-PMEL), N. Buzby (UW),
%   J. Plant, T. Maurer, Y. Takeshita (MBARI), D. Nicholson (WHOI),
%   and A. Gray (UW)
%
% CITATION:
%   H. Frenzel*, J. Sharp*, A. Fassbender, N. Buzby, J. Plant, T. Maurer,
%   Y. Takeshita, D. Nicholson, A. Gray, 2021. BGC-Argo-Mat: A MATLAB
%   toolbox for accessing and visualizing Biogeochemical Argo data.
%   Zenodo. https://doi.org/10.5281/zenodo.4971318.
%   (*These authors contributed equally to the code.)
%
% LICENSE: bgc_argo_mat_license.m
%
% DATE: FEBRUARY 22, 2022  (Version 1.2)

global Settings;

% make sure Settings is initialized
if isempty(Settings)
    initialize_argo();
end

% assign empty arrays to all return values in case of early return
good_float_ids = [];
mean_prof = {};
std_prof = {};
mean_pres = {};

if isempty(float_ids)
    warning('no floats specified')
    return
end

% set defaults
if nargin < 2
    variables = {'DOXY'};
end
float_profs = [];
basename = [];
var2 = [];
varargpass= {};

% parse optional arguments
for i = 1:2:length(varargin)-1
    if strcmpi(varargin{i}, 'float_profs')
        float_profs = varargin{i+1};
    elseif strcmpi(varargin{i}, 'png')
        basename = varargin{i+1};
    else
        if strcmpi(varargin{i}, 'qc')
            if min(varargin{i+1}) < 0 || max(varargin{i+1}) > 9
                warning('only QC flags 0..9 are allowed!')
                continue; % don't add it to varargpass
            end
        elseif strcmp(varargin{i}, 'var2')
            var2 = check_variables(varargin{i+1}, 'warning', ...
                'unknown sensor will be ignored');
        end
        varargpass = [varargpass, varargin{i:i+1}];
    end
end

% convert requested variable to cell array if necessary and
% discard unknown variables
variables = check_variables(variables, 'warning', ...
    'unknown sensor will be  ignored');

% if float profiles were specified, make sure that there are no empty
% arrays; if so, disregard these floats
if ~isempty(float_profs)
    no_profs = cellfun(@isempty, float_profs);
    if any(no_profs)
        warning('No profiles specified for float(s) %s', ...
            num2str(float_ids(no_profs)))
        float_ids(no_profs) = [];
    end
end

% download Sprof files if necessary
good_float_ids = download_multi_floats(float_ids);

if isempty(good_float_ids)
    warning('no valid floats found')
else
    [Data, Mdata] = load_float_data(good_float_ids, [variables; var2], ...
        float_profs);
    [mean_prof, std_prof, mean_pres] = plot_profiles(Data, Mdata, ...
        variables, basename, varargpass{:});
end
