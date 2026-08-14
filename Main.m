%% Call Data
[LD, DD] = getData();

%% Result 1 (Social Context): Daily occupancy across social x lighting with LME

% Construct lme table for Daily Entries Count
LD_tbl_entries = getLmeTable(LD, {'Paired', 'Removal', 'Solitary'}, ...
    'entries', 'Lighting', 'LD');
DD_tbl_entries = getLmeTable(DD, {'Paired', 'Removal', 'Solitary'}, ...
    'entries', 'Lighting', 'DD');

entries_tbl = [LD_tbl_entries; DD_tbl_entries];
% Construct lme table for Daily Occupancy Duration
LD_tbl_duration = getLmeTable(LD, {'Paired', 'Removal', 'Solitary'}, ...
    'duration', 'Lighting', 'LD');
DD_tbl_duration = getLmeTable(DD, {'Paired', 'Removal', 'Solitary'}, ...
    'duration', 'Lighting', 'DD');
duration_tbl = [LD_tbl_duration; DD_tbl_duration];

% Centering age with subject-level mean
mouse_tbl = unique(entries_tbl(:, {'MouseID','Age'}));
meanAge = mean(mouse_tbl.Age);
entries_tbl.Age_c = entries_tbl.Age - meanAge;
duration_tbl.Age_c = duration_tbl.Age - meanAge;

% ----- Construct NULL MODELs ------
null_entries = fitlme(entries_tbl, 'DV ~ 1 + (1|MouseID)');
null_duration = fitlme(duration_tbl, 'DV ~ 1 + (1|MouseID)');

% ----- Construct FULL(GLOBAL) MODELs ------
full_entries_additive = fitlme(entries_tbl, ...
    'DV ~ Social + Lighting + Age_c + Day_c + (1|MouseID)');
full_entries_interaction = fitlme(entries_tbl, ...
    'DV ~ Social * Lighting + Age_c + Day_c + (1|MouseID)');
full_duration_additive = fitlme(duration_tbl, ...
    'DV ~ Social + Lighting + Age_c + Day_c + (1|MouseID)');
full_duration_interaction = fitlme(duration_tbl, ...
    'DV ~ Social * Lighting + Age_c + Day_c + (1|MouseID)');

full_entries_additive_reml = fitlme(entries_tbl, ...
    'DV ~ Social + Lighting + Age_c + Day_c + (1|MouseID)', 'FitMethod','REML');
full_entries_interaction_reml = fitlme(entries_tbl, ...
    'DV ~ Social * Lighting + Age_c + Day_c + (1|MouseID)', 'FitMethod','REML');
full_duration_additive_reml = fitlme(duration_tbl, ...
    'DV ~ Social + Lighting + Age_c + Day_c + (1|MouseID)', 'FitMethod','REML');
full_duration_interaction_reml = fitlme(duration_tbl, ...
    'DV ~ Social * Lighting + Age_c + Day_c + (1|MouseID)', 'FitMethod','REML');


% ----- Compare Additive model against Null Model -----
compare(null_entries, full_entries_additive)
compare(null_duration, full_duration_additive)

% ----- Compare Interaction model against Additive model -----
compare(full_entries_additive, full_entries_interaction)
compare(full_duration_additive, full_duration_interaction)

% ANOVA results
anova(full_entries_additive)
anova(full_duration_additive)

% Calculate ICC of random effect
[psi_entries, mse_entries] = covarianceParameters(full_entries_additive);
icc_entries = psi_entries{1}/(psi_entries{1} + mse_entries);

[psi_dur, mse_dur] = covarianceParameters(full_duration_additive);
icc_duration = psi_dur{1}/(psi_dur{1} + mse_dur);
%% Result 1 (Social Context): Pairwise Comparisions of global LME
% Simple contrasts between social context using the retained additive model
full_tbls = {entries_tbl, duration_tbl};

comparisons = {
    'Paired  vs  Solitary';
    'Paired  vs  Removal';
    'Removal vs  Solitary'
};

for i = 1:numel(full_tbls)
    % Comparison 1: Paired vs. Solitary (8 vs. 4 mice)
    full_tbl = full_tbls{i};
    if i == 2
        full_tbl.DV = full_tbl.DV/60/60; % convert to hour
    end
    idx = ismember(full_tbl.Social, {'paired','solitary'});
    tbl_PvS = full_tbl(idx,:);
    tbl_PvS.Social = removecats(tbl_PvS.Social);
    mdl_PvS = fitlme(tbl_PvS,...
        'DV ~ Social + Lighting + Age_c + Day_c + (1|MouseID)');
    ans_PvS = anova(mdl_PvS);
    d_PvS = 2*mdl_PvS.Coefficients.tStat(2)/sqrt(mdl_PvS.DFE);
% Comparison 2: Paired vs. Partner-Removed (4 vs. 4 mice, repeated measure)
    remainingMice = unique(full_tbl.MouseID(full_tbl.Social=="removal"));
    idx = ismember(full_tbl.MouseID,remainingMice) & ...
          ismember(full_tbl.Social,{'paired','removal'});
    tbl_PvR = full_tbl(idx,:);
    tbl_PvR.Social = removecats(tbl_PvR.Social);
    mdl_PvR = fitlme(tbl_PvR,...
        'DV ~ Social + Lighting + Age_c + Day_c + (1|MouseID)');
    ans_PvR = anova(mdl_PvR);
    d_PvR = 2*mdl_PvR.Coefficients.tStat(2)/sqrt(mdl_PvR.DFE);
% Comparison 3: Partner-Removed vs. Solitary (4 vs. 4 mice)
    idx = ismember(full_tbl.Social,{'removal','solitary'});
    tbl_RvS = full_tbl(idx,:);
    tbl_RvS.Social = removecats(tbl_RvS.Social);
    mdl_RvS = fitlme(tbl_RvS,...
        'DV ~ Social + Lighting + Age_c + Day_c + (1|MouseID)');
    ans_RvS = anova(mdl_RvS);
    d_RvS = 2*mdl_RvS.Coefficients.tStat(2)/sqrt(mdl_RvS.DFE);

    ans_all = [ans_PvS(2, :);
        ans_PvR(2, :);
        ans_RvS(2, :)]; % extract Social row
    ans_all.Term = comparisons;
    cohend = [d_PvS; d_PvR; d_RvS];
    ans_all.CohenD = cohend;
    ans_all.p_adj = holmBonferroni(ans_all.pValue);
    disp(ans_all)
end

%% Result 2 (LD): Day-Night distribution analysis with t-test
% Paired-group individual occupancy duration: day vs. night
[~, p, ~, tstat] = ttest(LD.Paired_means.duration_day, LD.Paired_means.duration_night)
% Interaction duration: day vs. night
[~, p, ~, stats] = ttest(LD.Interaction_means.duration_day, LD.Interaction_means.duration_night)

% Diurnality index of interaction vs. wheel-running
interaction_DI = LD.Interaction_means.duration_night./LD.Interaction_means.duration;
duration_DI = LD.Paired_means.duration_night./LD.Paired_means.duration;
locomotor_DI = LD.Paired_means.locomotor_night./LD.Paired_means.locomotor;
duration_DI_pair = mean(reshape(duration_DI, [4 2]), 2);
locomotor_DI_pair = mean(reshape(locomotor_DI, [4 2]), 2);
[~, p, ~, stats] = ttest(interaction_DI, locomotor_DI_pair)
[~, p, ~, stats] = ttest(duration_DI_pair, locomotor_DI_pair)


% Pearson correlation between daily interaction duration and locomotion
% [rp_total, pp_total] = corr(x_total, y_total, 'Type','Pearson', 'Rows','complete')

% Probability of resulting in interaction
Interaction_day = repmat(LD.Interaction_means.entries_day,2,1); 
Interaction_night = repmat(LD.Interaction_means.entries_night,2,1);
probability_day = Interaction_day(:)./LD.Paired_means.entries_day(:);
probability_night = Interaction_night(:)./LD.Paired_means.entries_night(:);
[~, p, ~, stats] = ttest(probability_day, probability_night)

% Average duration per single event
[~, p, ~, tstat] = ttest(...
    LD.Paired_means.duration_day./LD.Paired_means.entries_day, ...
    LD.Paired_means.duration_night./LD.Paired_means.entries_night)
[~, p, ~, tstat] = ttest(...
    LD.Interaction_means.duration_day./LD.Interaction_means.entries_day, ...
    LD.Interaction_means.duration_night./LD.Interaction_means.entries_night)
%% Result 2 (LD): circadian phase analysis with cosinor fitting

% Cosinor fit for locomotor and individual social seeking of Paired group
locomotor_out = run_cosinor(LD.Paired, 'loc_file');
socialseeking_out = run_cosinor(LD.Paired, 'soc_file');

% --- 0. Convert to circular form ---
loc = locomotor_out.phi_all; % Acrophase of awd in ZT
soc = socialseeking_out.phi_all; % Acrophase of individual social seeking

% convert hours → radians
loc_rad = loc/24 * 2*pi;
soc_rad = soc/24 * 2*pi;

% === Rayleigh Test ===
[p_loc, z_loc] = circ_rtest(loc_rad);
[p_soc, z_soc] = circ_rtest(soc_rad);

% === Resultant Length / Circular Variance ===
R_loc = circ_r(loc_rad);
R_soc = circ_r(soc_rad);
circVar_loc = 1 - R_loc;
circVar_soc = 1 - R_soc;

% === Dispersion Test ===
[p_disp] = circ_ktest(loc_rad, soc_rad);

% === Within-Pair Similarity ===
pairs = reshape(soc_rad, 2, 4); % 2 animals per pair
pair_diff = abs( circ_dist(pairs(1,:), pairs(2,:)) );
pair_diff_hours = pair_diff/(2*pi)*24;
% mean within-pair difference
mean(pair_diff_hours) % ZT
std(pair_diff_hours)

% === Permutation Test ===
nPerm = 10000;
null_diff = zeros(nPerm,1);
for i = 1:nPerm
    shuffled = soc_rad(randperm(length(soc_rad)));
    pairs_null = reshape(shuffled,2,4);
    d = abs(circ_dist(pairs_null(1,:), pairs_null(2,:)));
    null_diff(i) = mean(d);
end
real_diff = mean(pair_diff); % in circular form
p_pair = mean(null_diff <= real_diff);

%% Result 3 (DD): Interaction parameters between LD and DD with t-test.
[~, p, ~, tstat] = ttest2(LD.Interaction_means.duration, DD.Interaction_means.duration)
[~, p, ~, tstat] = ttest2(LD.Interaction_means.entries, DD.Interaction_means.entries)
%% Result 3 (DD): Waveform changes between behaviour and lighting with LME
% Get tables
hoursPerBin = 3;
WR_LD_tbl = getTimebinLmeTable(LD.Paired, 'WR', 'LD', hoursPerBin); 
SI_LD_tbl = getTimebinLmeTable(LD.Interaction, 'SI', 'LD', hoursPerBin);

WR_DD_tbl = getTimebinLmeTable(DD.Paired, 'WR', 'DD', hoursPerBin); 
SI_DD_tbl = getTimebinLmeTable(DD.Interaction, 'SI', 'DD', hoursPerBin);

LD_waveform_tbl = [WR_LD_tbl; SI_LD_tbl];
DD_waveform_tbl = [WR_DD_tbl; SI_DD_tbl];
Interaction_tbl = [SI_LD_tbl; SI_DD_tbl];
WheelRunning_tbl = [WR_LD_tbl; WR_DD_tbl];


zLD_behaviour = fitlme(LD_waveform_tbl, ...
    'zActivity ~ Behaviour*TimeBin + (1|DyadID)');
zDD_behaviour = fitlme(DD_waveform_tbl, ...
    'zActivity ~ Behaviour*TimeBin + (1|DyadID)');
zSI_Lighting = fitlme(Interaction_tbl, ...
    'zActivity ~ Lighting*TimeBin + (1|DyadID)');
zWR_Lighting = fitlme(WheelRunning_tbl, ...
    'zActivity ~ Lighting*TimeBin + (1|DyadID)');

ans_LD = anova(zLD_behaviour);
ans_DD = anova(zDD_behaviour);
ans_SI = anova(zSI_Lighting);
ans_WR = anova(zWR_Lighting);

comparisons = {
    'LD: SI vs WR';
    'DD: SI vs WR';
    'SI: LD vs DD';
    'WR: LD vs DD'
};

ans_all = [ans_LD(4, :);
    ans_DD(4, :);
    ans_SI(4, :);
    ans_WR(4, :)]; % extract interaction row
ans_all.Term = comparisons;
ans_all.p_adj = holmBonferroni(ans_all.pValue);
disp(ans_all)

function p_adj = holmBonferroni(pvals)
% Performs Holm–Bonferroni correction for multiple comparisons.
%
% INPUT
%   pvals: Vector of uncorrected p-values.
%
% OUTPUT
%   p_adj: Vector of adjusted p-values in the original order.
%
% METHOD
%   1. Sort p-values ascending
%   2. Multiply each p-value by remaining number of tests
%   3. Enforce monotonic increase
%   4. Restore original ordering

    % Ensure column vector
    pvals = pvals(:);

    % Number of comparisons
    m = length(pvals);

    % Sort p-values
    [p_sorted, idx] = sort(pvals);

    % Preallocate
    p_adj_sorted = zeros(size(p_sorted));

    % Holm adjustment
    for i = 1:m
        p_adj_sorted(i) = min(1, p_sorted(i) * (m - i + 1));
    end

    % Enforce monotonicity
    for i = 2:m
        p_adj_sorted(i) = max(p_adj_sorted(i), ...
                               p_adj_sorted(i-1));
    end

    % Restore original ordering
    p_adj = zeros(size(pvals));
    p_adj(idx) = p_adj_sorted;

end
function tbl = getLmeTable(Data, contexts, variables, varargin)
% GETLMETABLE
%
% Converts nested behavioural data structures into a long-format table
% suitable for linear mixed-effects modelling.
%
% INPUTS:
%   Data
%       Master data structure organized as:
%           Data.(context).(mouse)
%
%   contexts
%       Cell array or string array specifying which contexts to include.
%
%       Example:
%           {'Paired','Removal','Solitary'}
%
%   variables
%       Variable name or cell array of variable names to extract.
%
%       Single variable example:
%           'duration'
%
%       Multiple variable example:
%           {'locomotor_night','locomotor'}
%
% OPTIONAL PARAMETERS:
%   'Lighting'
%       Experimental lighting condition:
%           'LD' or 'DD'
%
% OUTPUT:
%   tbl
%       Long-format table suitable for fitlme().

%% =========================
% Parse inputs
% ==========================

p = inputParser;

addRequired(p, 'Data', @isstruct);

addRequired(p, 'contexts', ...
    @(x) iscell(x) || isstring(x));

addRequired(p, 'variables', ...
    @(x) ischar(x) || isstring(x) || iscell(x));

addParameter(p, 'Lighting', '', ...
    @(x) any(validatestring(x, {'LD','DD'})));

parse(p, Data, contexts, variables, varargin{:});

opt = p.Results;

%% =========================
% Convert single variable input to cell
% ==========================

singleVariableMode = false;

if ischar(variables) || isstring(variables)

    variables = {char(variables)};
    singleVariableMode = true;

elseif numel(variables) == 1

    singleVariableMode = true;

end

%% =========================
% Initialize storage containers
% ==========================

tableData = struct();

for v = 1:numel(variables)

    varName = variables{v};

    tableData.(varName) = [];

end

Social  = {};
MouseID = {};
Day     = [];
Age     = [];

%% =========================
% Extract data
% ==========================

for c = 1:numel(contexts)

    ctx = contexts{c};

    % Skip missing contexts safely
    if ~isfield(Data, ctx)

        warning('Context "%s" not found. Skipping.', ctx);
        continue;

    end

    mouseNames = fieldnames(Data.(ctx));

    %% Iterate through mice
    for m = 1:numel(mouseNames)

        mouseName = mouseNames{m};
        mouseData = Data.(ctx).(mouseName);
        mouseAge = mouseData.Age;

        %% Determine number of days
        firstVar = variables{1};

        if ~isfield(mouseData, firstVar)
            continue;
        end

        nDays = numel(mouseData.(firstVar));

        %% Extract variables
        for v = 1:numel(variables)

            varName = variables{v};

            % Missing variables are replaced with NaNs
            if isfield(mouseData, varName)

                vec = mouseData.(varName);

            else

                vec = NaN(nDays,1);

            end

            tableData.(varName) = ...
                [tableData.(varName); vec(:)];

        end

        %% Add metadata
        Social = [Social;
            repmat({lower(ctx)}, nDays, 1)];

        MouseID = [MouseID;
            repmat({strcat(opt.Lighting, mouseName)}, ...
            nDays, 1)];

        Age = [Age;
            repmat(mouseAge, nDays, 1)];

        Day = [Day;
            (1:nDays)'];

    end
end

%% =========================
% Build output table
% ==========================

tbl = table();

% Single-variable mode:
% Rename variable column to "DV"
if singleVariableMode

    tbl.DV = tableData.(variables{1});

% Multi-variable mode:
% Use original variable names
else

    for v = 1:numel(variables)

        varName = variables{v};

        tbl.(varName) = tableData.(varName);

    end

end

%% Add metadata columns
tbl.Social  = Social;
tbl.MouseID = MouseID;
tbl.Day     = Day;
tbl.Age     = Age;
%% Mouse identity replacements

switch opt.Lighting

    case 'LD'

        tbl.MouseID = replace(tbl.MouseID, ...
            {'LDr1','LDr2','LDr3','LDr4'}, ...
            {'LDp1r','LDp2r','LDp3r','LDp4r'});

    case 'DD'

        tbl.MouseID = replace(tbl.MouseID, ...
            {'DDr1','DDr2','DDr3','DDr4'}, ...
            {'DDp1l','DDp2r','DDp3r','DDp4l'});

end


%% Add lighting condition column
tbl.Lighting = repmat( ...
    string(opt.Lighting), ...
    height(tbl), 1);

%% Remove rows containing NaNs
tbl = rmmissing(tbl);

%% Variable Tranform

% Convert grouping variables to categorical
tbl.Lighting = categorical(tbl.Lighting);
tbl.Social = categorical(tbl.Social);
tbl.MouseID   = categorical(tbl.MouseID);

% Centering day (1-7)
tbl.Day_c = tbl.Day - mean(1:1:7);

end
function out = run_cosinor(data, variable)
fieldNames = fieldnames(data);
files = {};
for i = 1:numel(fieldNames)
    files{end+1} = readtable(data.(fieldNames{i}).(variable));
end

omega = 2*pi/24;
n = numel(files);
t_fit = linspace(0,48,500)';
X_fit = [ones(size(t_fit)) cos(omega*t_fit) sin(omega*t_fit)];

all_curves = nan(length(t_fit), n);
phi_all = nan(n,1);

all_mean_y = nan(240, n);
all_std_y = nan(240, n);

for i = 1:n
    file = files{i};
    data = file.data;
    zt_start = file.CT(1) + (file.bin(1)-1)/10;

    t = zt_start + (0:length(data)-1)*(1/10);
    t = t(:);
    y = data(:);

    % Bin to ZT (for plotting output)
    t_zt = mod(t,24);
    edges = 0:0.1:24;
    zt_bin_idx = discretize(t_zt, edges);
    mean_y = accumarray(zt_bin_idx, y, [240 1], @mean, NaN);
    std_y = accumarray(zt_bin_idx, y, [240 1], @std, NaN);
    all_mean_y(:,i) = mean_y;
    all_std_y(:,i) = std_y;

    % --- design matrix ---
    X = [ones(size(t)) cos(omega*t) sin(omega*t)];

    % --- remove NaNs ---
    valid = ~isnan(y);
    X_valid = X(valid,:);
    y_valid = y(valid);

    % --- check enough data ---
    if sum(valid) < 3
        warning('File %d skipped: not enough valid data', i);
        continue
    end

    % --- fit ---
    b = X_valid \ y_valid;

    % --- phase ---
    phi = atan2(b(3), b(2));
    phi_all(i) = mod(phi/(2*pi)*24, 24);

    % --- predicted curve ---
    y_fit = X_fit * b;
    all_curves(:,i) = y_fit;
end

% --- group mean curve ---
mean_curve = mean(all_curves,2,'omitnan');
sem_curve  = std(all_curves,[],2,'omitnan') / sqrt(n);

% --- circular mean phase ---
phi_rad = phi_all/24*2*pi;
mean_phi = atan2(mean(sin(phi_rad)), mean(cos(phi_rad)));
mean_phi = mod(mean_phi/(2*pi)*24, 24);

% --- output ---
out.t_fit = t_fit;
out.mean_curve = mean_curve;
out.sem_curve = sem_curve;
out.mean_phi = mean_phi;
out.phi_all = phi_all;
out.mean_y = all_mean_y;
out.std_y = all_std_y;
end

function tbl = getTimebinLmeTable(data, behaviour, lighting, BinSize)
% Converts behavioural data structures into a long-format table
%
% INPUTS:
%   Data
%       Master data structure organized as:
%           (Lighting).(social context).(mouse)
%       Only take (Lighting).Paired for WR & (Lighting).Interaction for SI
%
%   behaviour
%       'WR' - wheel-running.
%       'SI' - social interaction
%
%   lighting
%       string 'LD' or 'DD'
%
% OUTPUT:
%   tbl
%       Long-format table suitable for fitlme().

    fieldNames = fieldnames(data);
    % define the file name to call on
    sumDataforSI = false;
    scaleBinforDDSI = false;
    switch behaviour
        case 'WR'
            filename = 'loc_file';
            dyadNum = [1 1 2 2 3 3 4 4];
        case 'SI'
            filename = 'soc_file';
            sumDataforSI = true;
            dyadNum = [1 2 3 4];
            if strcmp(lighting,'DD')
                % scale to 360 full circadian seconds per bin
                scaleBinforDDSI = true;
            end
    end
    
    tbl = table();
    for i = 1:numel(fieldNames)
        file = readtable(data.(fieldNames{i}).(filename));
        if sumDataforSI
            if scaleBinforDDSI
                scaleBin = 24 / mean(data.(fieldNames{i}).period);
            else
                scaleBin = 1;
            end
            file.data = scaleBin*(file.both_mid + file.both_midsep);
        end
        file = groupsummary(file,...
                           {'CT','bin'},...
                           'mean',...
                           'data'); % average across days
        % Circadian time
        t = file.CT + (file.bin-1)/10;
        ct = mod(t,24);
    
        
        % Add 6-min bins into 1h bins
        edges = 0:BinSize:24;
        binID = discretize(ct,edges);
        hourlyActivity = accumarray(binID,...
                                  file.mean_data,...
                                  [24/BinSize 1],...
                                  @sum,...
                                  NaN);
    
        tmp = table();
        tmp.DyadID    = repmat(categorical("Dyad"+dyadNum(i)),24/BinSize,1);
        tmp.Lighting  = repmat(categorical(string(lighting)),24/BinSize,1);
        tmp.Behaviour = repmat(categorical(string(behaviour)),24/BinSize,1);
        tmp.TimeBin = categorical(1:BinSize:24, 1:BinSize:24, ...
            compose("CT%d",0:BinSize:23))';
        tmp.Activity = hourlyActivity;
        tmp.zActivity = zscore(tmp.Activity);

        % append to lme table
        tbl = [tbl; tmp];
    end

    if strcmp(behaviour,'WR')
        tbl = groupsummary(tbl,...
                           {'DyadID','Lighting','Behaviour','TimeBin'},...
                           'mean',...
                           {'Activity', 'zActivity'});
    
        tbl.GroupCount = [];
        tbl.Properties.VariableNames{'mean_Activity'} = 'Activity';
        tbl.Properties.VariableNames{'mean_zActivity'} = 'zActivity';
    
    end
end