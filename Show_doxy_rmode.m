%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show_doxy_rmode.m
%
% This example script for the BGC-Argo MATLAB toolbox finds floats
% that have at least 20 DOXY profiles in R mode.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global Float;

% search globally and over the whole available time span, find floats that
% have at least 20 DOXY profiles in R mode
[float_ids, float_profs] = select_profiles([],[],[],[],'sensor','DOXY',...
    'mode','R','min_num_prof',20);

%% show only most recent positions since there may be many floats,
% color by DAC
show_trajectories(float_ids,'color','dac','float_profs',float_profs, ...
    'position','last','title','Most recent locations of floats');

% determine number of floats affected by DAC
fidx = arrayfun(@(x) find(Float.wmoid==x, 1), float_ids);
found_dacs = Float.dac(fidx);
[dacs_list, ~, idx_dac] = unique(found_dacs);
ndacs = length(dacs_list);

fprintf('\n\nNumber of floats with at least 20 DOXY profiles in R mode by DAC:\n');
for i = 1:ndacs
    fprintf('%-10s %3d\n', dacs_list{i}, sum(idx_dac == i));
end
