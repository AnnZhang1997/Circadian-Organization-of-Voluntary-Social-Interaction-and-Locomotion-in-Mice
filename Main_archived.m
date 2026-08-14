%% Call Data
[LD, DD] = getData();

%% LD Result 1 -- diurnality analysis of interaction using paired t-test
% Individual visit count and duration
[~, p, ~, tstat] = ttest(LD.Paired_means.count_day, LD.Paired_means.count_night)
[~, p, ~, tstat] = ttest(LD.Paired_means.duration_day, LD.Paired_means.duration_night)

% Interaction count and duration
[~, p, ~, stats] = ttest(LD.Interaction_means.count_day, LD.Interaction_means.count_night)
[~, p, ~, stats] = ttest(LD.Interaction_means.duration_day, LD.Interaction_means.duration_night)

% Probability of resulting in interaction
Interaction_day = repmat(LD.Interaction_means.count_day,2,1); 
Interaction_night = repmat(LD.Interaction_means.count_night,2,1);
probability_day = Interaction_day(:)./LD.Paired_means.count_day(:);
probability_night = Interaction_night(:)./LD.Paired_means.count_night(:);
[~, p, ~, stats] = ttest(probability_day, probability_night)

% Average duration per single event
[~, p, ~, tstat] = ttest(...
    LD.Paired_means.duration_day./LD.Paired_means.count_day, ...
    LD.Paired_means.duration_night./LD.Paired_means.count_night)
[~, p, ~, tstat] = ttest(...
    LD.Interaction_means.duration_day./LD.Interaction_means.count_day, ...
    LD.Interaction_means.duration_night./LD.Interaction_means.count_night)
%% LD Result 2 -- Social context compare using LME

variable = 'duration'; % count or duration

tbl = getLmeTable(LD, {'Paired', 'Removal', 'Solitary'}, variable, ...
    'Lighting', 'LD');

lme_additive = fitlme(tbl, 'DV ~ Context + Day_c + (1|Mouse)');
lme_interaction = fitlme(tbl, 'DV ~ Context*Day_c + (1|Mouse)');
compare(lme_additive, lme_interaction)

switch variable
    case 'count'
        anova(lme_interaction)
        lme_interaction.Coefficients

        comparisons = {
            'Paired vs Removal';
            'Paired vs Solitary';
            'Removal vs Solitary'
        };
        H = [
                0  1  0  0  0  0; 
                0  0  1  0  0  0;
                0 -1  1  0  0  0 
            ];
        [pvals, Fvals] = runContrasts(lme_interaction, H);
        p_adj = holmBonferroni(pvals);
        table(comparisons, pvals, p_adj, Fvals)

        % Simple slope 
        comparisons = {
            'Paired slope';
            'Removal slope';
            'Solitary slope'
        };
        H_slopes = [
            0 0 0 1 0 0;   % Paired slope
            0 0 0 1 1 0;   % Removal slope
            0 0 0 1 0 1    % Solitary slope
        ];
        [p_slopes, F_slopes] = runContrasts(lme_interaction, H_slopes);
        beta = fixedEffects(lme_interaction);
        slope_est = H_slopes * beta;
        p_adj_slopes = holmBonferroni(p_slopes);
        table(comparisons, p_slopes, p_adj_slopes, F_slopes)

    case 'duration'
        compare(lme_additive, lme_interaction)
        anova(lme_additive)
        lme_additive.Coefficients
        comparisons = {
            'Paired vs Removal';
            'Paired vs Solitary';
            'Removal vs Solitary'
        };
        H = [
                0  1  0  0;   % Paired vs Removal
                0  0  1  0;   % Paired vs Solitary
                0 -1  1  0    % Removal vs Solitary
            ];
        % run pairwise comparisons
        [pvals, Fvals] = runContrasts(lme_additive, H);
        p_adj = holmBonferroni(pvals);
        
        table(comparisons, pvals, p_adj, Fvals)

end

%% LD Result 3-1 -- diurnality analysis across social context using LME
% Quantify whether the proportion of activity occurring during
% the night phase differs across social contexts for both
% locomotor activity and social motivation.

% === Create LME table ===
loc_tbl = getLmeTable(LD, {'Paired', 'Removal', 'Solitary'}, ...
    {'locomotor_night', 'locomotor'}, 'Lighting', 'LD');
dur_tbl = getLmeTable(LD, {'Paired', 'Removal', 'Solitary'}, ...
    {'duration_night', 'duration'}, 'Lighting', 'LD');
% === Rename Variables for Consistency ===
loc_tbl = renamevars(loc_tbl, ...
    {'locomotor_night','locomotor'}, ...
    {'NightCount','TotalCount'});
dur_tbl = renamevars(dur_tbl, ...
    {'duration_night','duration'}, ...
    {'NightCount','TotalCount'});
loc_tbl.Prop = loc_tbl.NightCount ./ loc_tbl.TotalCount;
dur_tbl.Prop = dur_tbl.NightCount ./ dur_tbl.TotalCount;
% === LOGIT TRANSFORMATION for LOCOMOTOR ===
% Boundary check
fprintf('\n=== LOCOMOTOR PROP CHECK ===\n');
disp([min(loc_tbl.Prop), max(loc_tbl.Prop)])
fprintf('Exact 0 or 1 values: %d\n', ...
    sum(loc_tbl.Prop == 0 | loc_tbl.Prop == 1));

% Adjust proportions to avoid infinite logits
p_adj = ...
    (loc_tbl.NightCount + 0.5) ./ ...
    (loc_tbl.TotalCount + 1);
loc_tbl.logitProp = ...
    log(p_adj ./ (1 - p_adj));

% === CONSTRUCTING LMES ===
loc_additive = fitlme(loc_tbl, ...
            'logitProp ~ Context + Day_c + (1|Mouse)');
loc_interaction = fitlme(loc_tbl, ...
            'logitProp ~ Context*Day_c + (1|Mouse)');
dur_additive = fitlme(dur_tbl, ...
            'Prop ~ Context + Day_c + (1|Mouse)');
dur_interaction = fitlme(dur_tbl, ...
            'Prop ~ Context*Day_c + (1|Mouse)');
% === COMPARE ADDITIVE VS. INTERACTIVE MODELS ===
compare(loc_additive, loc_interaction)
compare(dur_additive, dur_interaction)
% === ANOVA TABLES & COEFFICIENTS === 
anova(loc_interaction) % not significant
anova(dur_additive)
dur_additive.Coefficients

% === PLANNED CONTRASTS FOR SOCIAL DURATION ===
comparisons = {
    'Paired vs Removal';
    'Paired vs Solitary';
    'Removal vs Solitary'
};
H = [
        0  1  0  0;   % Paired vs Removal
        0  0  1  0;   % Paired vs Solitary
        0 -1  1  0    % Removal vs Solitary
    ];
[pvals, Fvals] = runContrasts(dur_additive, H);
p_adj = holmBonferroni(pvals);
table(comparisons, pvals, p_adj, Fvals)


% === RESIDUAL DIAGNOSTICS + HOMOSCEDASTICITY CHECK ===
% % Uncomment to check
% r = residuals(dur_additive);
% figure; histogram(r,30); title('Residual Distribution');
% figure; qqplot(r); title('QQ Plot of Residuals');
% f = fitted(dur_additive);
% figure; scatter(f, r, 'filled'); xlabel('Fitted'); ylabel('Residuals');
% title('Residuals vs Fitted'); refline(0,0);


% === CORRELATION BETWEEN LOCOMOTOR AND SOCIAL ===
loc_sub = loc_tbl(:, {'Mouse','Day', 'Context', 'Prop','TotalCount'});
dur_sub = dur_tbl(:, {'Mouse','Day', 'Context', 'Prop','TotalCount'});
% Rename variables before merge
loc_sub.Properties.VariableNames{'Prop'} = 'loc_prop';
dur_sub.Properties.VariableNames{'Prop'} = 'dur_prop';
loc_sub.Properties.VariableNames{'TotalCount'} = 'loc_total';
dur_sub.Properties.VariableNames{'TotalCount'} = 'dur_total';
% Merge tables
tbl_merged = innerjoin(loc_sub, dur_sub, 'Keys', {'Mouse','Context', 'Day'});

% --- Correlation of Total Activity ---
x_total = tbl_merged.dur_total; % social
y_total = tbl_merged.loc_total; % locomotor
% Pearson
[rp_total, pp_total] = corr(x_total, y_total, 'Type','Pearson', 'Rows','complete')

% --- Correlation of Diurnal Proportions ---
x = tbl_merged.dur_prop;   % social
y = tbl_merged.loc_prop;   % locomotor
% Spearman
[r_s, p_s] = corr(x, y, 'Type','Spearman', 'Rows','complete')

% === SCATTER PLOT FOR SANITY CHECK ===
% % Uncomment to check
% figure(); scatter(x_total, y_total, 'filled');
% xlabel('Social'); ylabel('Locomotor');
% title('Total Activity Correlation'); lsline;
%% LD Result 3-2 -- circadian phase analysis using cosinor fitting (UNCHECKED)

% Cosinor fit for locomotor and individual social seeking of the paired
% group
% locomotor_out = run_cosinor(LD.Paired, 'loc_file');
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

%% LD vs. DD Interaction parameters using lme

variable = 'count'; % count or duration
LD_tbl = getLmeTable(LD, {'Interaction'}, variable, 'Lighting', 'LD');
DD_tbl = getLmeTable(DD, {'Interaction'}, variable, 'Lighting', 'DD');
full_tbl = [LD_tbl; DD_tbl];
full_tbl.Lighting = categorical(full_tbl.Lighting);

lme_additive = fitlme(full_tbl,'DV ~ Lighting + Day_c + (1|Mouse)');
anova(lme_additive)

%% LD vs. DD Context * Lighting (DONE)
variable = 'duration'; % count or duration

LD_tbl = getLmeTable(LD, {'Paired', 'Removal', 'Solitary'}, ...
    variable, 'Lighting', 'LD');
DD_tbl = getLmeTable(DD, {'Paired', 'Removal', 'Solitary'}, ...
    variable, 'Lighting', 'DD');
full_tbl = [LD_tbl; DD_tbl];
full_tbl.Lighting = categorical(full_tbl.Lighting);

lme_additive = fitlme(full_tbl,'DV ~ Lighting + Context + Day_c + (1|Mouse)');
lme_interaction = fitlme(full_tbl,'DV ~ Lighting*Context + Day_c + (1|Mouse)');
compare(lme_additive, lme_interaction)
anova(lme_additive)

% Simple contrasts between social context under DD
comparisons = {
    'Paired vs Removal   (DD)';
    'Paired vs Solitary  (DD)';
    'Removal vs Solitary (DD)'
};
H = [
    0  1  0  0  0;   % Paired vs Removal (DD)
    0  0  1  0  0;   % Paired vs Solitary (DD)
    0 -1  1  0  0    % Removal vs Solitary (DD)
];
[pvals, Fvals] = runContrasts(lme_additive, H);
p_adj = holmBonferroni(pvals);
table(comparisons, pvals, p_adj, Fvals)


%% Helper Functions
function [pvals, Fvals] = runContrasts(lme, H)

    nComp = size(H,1);

    pvals = zeros(nComp,1);
    Fvals = zeros(nComp,1);

    for i = 1:nComp
        [p,F] = coefTest(lme, H(i,:));
        pvals(i) = p;
        Fvals(i) = F;
    end

end
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

Context = {};
Mouse   = {};
Day     = [];

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
        Context = [Context;
            repmat({lower(ctx)}, nDays, 1)];

        Mouse = [Mouse;
            repmat({strcat(opt.Lighting, mouseName)}, ...
            nDays, 1)];

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
tbl.Context = Context;
tbl.Mouse   = Mouse;
tbl.Day     = Day;

%% =========================
% Mouse identity replacements
% ==========================

switch opt.Lighting

    case 'LD'

        tbl.Mouse = replace(tbl.Mouse, ...
            {'LDr1','LDr2','LDr3','LDr4'}, ...
            {'LDp1r','LDp2r','LDp3r','LDp4r'});

    case 'DD'

        tbl.Mouse = replace(tbl.Mouse, ...
            {'DDr1','DDr2','DDr3','DDr4'}, ...
            {'DDp1l','DDp2r','DDp3r','DDp4l'});

end

%% =========================
% Convert grouping variables to categorical
% ==========================

tbl.Context = categorical(tbl.Context);
tbl.Mouse   = categorical(tbl.Mouse);

%% Center day variable
tbl.Day_c = tbl.Day - mean(tbl.Day);

%% Add lighting condition column
tbl.Lighting = repmat( ...
    string(opt.Lighting), ...
    height(tbl), 1);

%% Remove rows containing NaNs
tbl = rmmissing(tbl);

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

