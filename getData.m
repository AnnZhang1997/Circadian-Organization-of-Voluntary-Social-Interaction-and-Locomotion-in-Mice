function [LDdata, DDdata] = getData()
% returns a nested struct that contains:
% 8 pairs of paired data (left and right), 4 post-removal data, 4 solitary
% data. Each sub-struct follows same structure and contains the daily
% average and diurnal data.   

    LDdata = getLDdata();
    DDdata = getDDdata();

    LDdata.Paired_means = extractMeans(LDdata.Paired);
    LDdata.Interaction_means = extractMeans(LDdata.Interaction);
    LDdata.Removal_means = extractMeans(LDdata.Removal);
    LDdata.Solitary_means = extractMeans(LDdata.Solitary);

    DDdata.Paired_means = extractMeans(DDdata.Paired);
    DDdata.Interaction_means = extractMeans(DDdata.Interaction);
    DDdata.Removal_means = extractMeans(DDdata.Removal);
    DDdata.Solitary_means = extractMeans(DDdata.Solitary);
    
end


function LDdata = getLDdata()
% GETLDDATA
%
% Loads and organizes all 12:12 light-dark (LD) behavioural datasets.
% The returned structure contains four experiment categories:
%   LDdata.Solitary    -> solitary housed animals      (s1-s4)
%   LDdata.Paired      -> paired animals     (p1l/p1r-p4l/p4r)
%   LDdata.Removal     -> partner-removal animals      (r1-r4)
%   LDdata.Interaction -> dyadic interaction events    (p1-p4)
%
% Each animal/pair contains:
%   - day values
%   - night values
%   - daily totals (generated automatically)
%   - associated data filenames
Paired = struct(); 
Interaction = struct();
Removal = struct(); 
Solitary = struct(); 
%%  --- Solitary Animal's Daily Data (n=4) ---
    Solitary.s1.count_day = [12, 14, 17, 19, 36, 27, 20];
    Solitary.s1.count_night = [68, 67, 98, 91, 75, 55, 49];
    Solitary.s1.duration_day = [209, 357, 155, 152, 826, 461, 966];
    Solitary.s1.duration_night = [603, 1749, 662, 1515, 1026, 729, 794];
    Solitary.s1.dur_divider_day = [80, 210, 37, 64, 272, 144, 214];
    Solitary.s1.dur_divider_night = [331, 326, 168, 200, 340, 331, 511];
    Solitary.s1.locomotor_day = [NaN, 394, 93, 0, 0, 2, 0];
    Solitary.s1.locomotor_night = [NaN, 3631, 2623, 5895, 4736, 5775, 5453];

    Solitary.s2.count_day = [20 13 24 12 14 22 27];
    Solitary.s2.count_night = [63 43 48 78 45 37 54];
    Solitary.s2.duration_day = [330 470 396 424 390 393 552];
    Solitary.s2.duration_night = [2480 773 738 2492 443 414 557];
    Solitary.s2.dur_divider_day = [53 174 67 29 42 34 108];
    Solitary.s2.dur_divider_night = [208 97 66 319 57 56 162];
    Solitary.s2.locomotor_day = [93 7 228 2 1 88 39];
    Solitary.s2.locomotor_night = [3785 4851 4197 3010 3898 3054 3819];

    Solitary.s3.count_day = [21 25 17 21 17 20 25];
    Solitary.s3.count_night = [63 43 42 54 50 60 66];
    Solitary.s3.duration_day = [342 383 677 288 330 362 475];
    Solitary.s3.duration_night = [2257 1037 2001 1107 1778 2485 1801];
    Solitary.s3.dur_divider_day = [85 89 174 45 67 55 87];
    Solitary.s3.dur_divider_night = [240 121 196 250 145 296 313];
    Solitary.s3.locomotor_day = [158, 439, 128, 155, 146, 9, 1]; 
    Solitary.s3.locomotor_night = [5767, 3283, 4670, 4270, 4583, 3480, 4809];

    Solitary.s4.count_day = [24, 23, 16, 19, 17, 16, 18];
    Solitary.s4.count_night = [27, 25, 26, 29, 18, 37, 21]+10;
    Solitary.s4.duration_day = [657, 573, 627, 540, 1136, 1597, 401];
    Solitary.s4.duration_night = [673, 1249, 1931, 1384, 890, 1492, 1327];
    Solitary.s4.dur_divider = [874, 504, 127, 137, 237, 775, 234];
    Solitary.s4.locomotor_day = [58, 82, 69, 11, 33, 37, 1];
    Solitary.s4.locomotor_night = [2394, 3069, 3292, 3832, 3885, 3278, 3980];

%%  --- Paired Animal's Daily Data (n=8 animals, 4 pairs) ---
    Paired.p1l.count_day = [27, 33, 28, 30, 24, 23, 22];
    Paired.p1l.count_night = [112, 119, 104, 113, 82, 65, 42];
    Paired.p1l.duration_day = [3771, 4472, 4211, 4386, 3692, 4437, 4640];
    Paired.p1l.duration_night = [8083, 9385, 8558, 8456, 6722, 5424, 7096];
    Paired.p1l.dur_divider_day = [1106, 1415, 1440, 1527, 968, 1626, 1524];
    Paired.p1l.dur_divider_night = [1996, 2845, 2591, 2543, 1379, 1574, 1737];

    Paired.p1r.count_day = [19, 14, 16, 12, 14, 11, 7];
    Paired.p1r.count_night = [37, 44, 46, 59, 57, 36, 40];
    Paired.p1r.duration_day = [1176, 968, 1477, 2971, 2718, 750, 998];
    Paired.p1r.duration_night = [1747, 4026, 4297, 6708, 8223, 1887, 6237];
    Paired.p1r.dur_divider_day = [878, 538, 801, 515, 515, 382, 326];
    Paired.p1r.dur_divider_night = [1108, 1010, 752, 1497, 788, 747, 943];

    Paired.p2l.count_day = [20, 18, 13, 42, 34, 24, 13];
    Paired.p2l.count_night = [62, 102, 61, 77, 128, 41, 64];
    Paired.p2l.duration_day = [2452, 504, 2174, 22939, 5357, 5385, 5761];
    Paired.p2l.duration_night = [18584, 8489, 6962, 4071, 22786, 11210, 12323];
    Paired.p2l.dur_divider_day = [720, 219, 553, 247, 1778, 1468, 1050];
    Paired.p2l.dur_divider_night = [8425, 4087, 2196, 107, 4266, 463, 2090];

    Paired.p2r.count_day = [13, 27, 9, 10, 20, 24, 22];
    Paired.p2r.count_night = [71, 51, 43, 78, 55, 56, 31];
    Paired.p2r.duration_day = [248, 593, 113, 347, 363, 685, 408];
    Paired.p2r.duration_night = [3290, 1653, 2035, 2688, 2487, 2255, 1854];
    Paired.p2r.dur_divider_day = [104, 353, 67, 54, 165, 174, 109];
    Paired.p2r.dur_divider_night = [997, 1320, 1238, 527, 1695, 1215, 818];

    Paired.p3l.count_day = [109, 71, 66, 65, 70, 40, 56];
    Paired.p3l.count_night = [139, 151, 149, 86, 107, 76, 103];
    Paired.p3l.duration_day = [3723, 3135, 3579, 5026, 3027, 2494, 4651];
    Paired.p3l.duration_night = [4556, 5666, 4929, 2896, 4132, 4382, 6681];
    Paired.p3l.dur_divider_day = [2168, 1897, 1989, 1732, 1587, 1519, 1958];
    Paired.p3l.dur_divider_night = [3000, 3334, 2508, 1628, 1719, 1740, 2086];

    Paired.p3r.count_day = [20, 11, 18, 26, 11, 8, 21];
    Paired.p3r.count_night = [49, 42, 29, 35, 28, 28, 56];
    Paired.p3r.duration_day = [638, 279, 506, 1204, 246, 450, 636];
    Paired.p3r.duration_night = [1026, 1250, 900, 1472, 1205, 1255, 1983];
    Paired.p3r.dur_divider_day = [389, 201, 305, 636, 115, 246, 347];
    Paired.p3r.dur_divider_night = [716, 790, 656, 1014, 730, 872, 1284];

    Paired.p4l.count_day = [22 12 8 7 8 5 6];
    Paired.p4l.count_night = [50, 52, 70, 77, 85, 74, 70];
    Paired.p4l.duration_day = [221, 318, 489, 71, 982, 274, 715];
    Paired.p4l.duration_night = [1254, 1488, 2641, 4312, 5422, 4318, 10121];
    Paired.p4l.dur_divider_day = [103, 88, 234, 22, 66, 100, 115];
    Paired.p4l.dur_divider_night = [611, 480, 678, 1288, 544, 1213, 1823];

    Paired.p4r.count_day = [54, 21, 28, 32, 25, 22, 18];
    Paired.p4r.count_night = [131, 138, 71, 68, 53, 63, 67];
    Paired.p4r.duration_day = [8064, 1242, 2231, 3068, 3674, 1707, 1400];
    Paired.p4r.duration_night = [26302, 7152, 10884, 5104, 20124, 18164, 25954];
    Paired.p4r.dur_divider_day = [479, 221, 285, 621, 440, 361, 165];
    Paired.p4r.dur_divider_night = [1036, 956, 1058, 1007, 1393, 1231, 1093];

    % =========== Wheel-Running Locomotion =============
    Paired.p1l.locomotor_day = [20, 36, 11, 36, 1, 6, 0];
    Paired.p1l.locomotor_night = [8313, 7053, 6217, 5380, 5459, 3860, 3317];
    Paired.p1r.locomotor_day = [13, 1, 1, 2, 2, 2, 22];
    Paired.p1r.locomotor_night = [10350, 8401, 9313, 11349, 9226, 10303, 10986];
    Paired.p2l.locomotor_day = [36, 6, 53, 86, 21, 14, 25];
    Paired.p2l.locomotor_night = [1122, 1591, 615, 1015, 1426, 622, 954];
    Paired.p2r.locomotor_day = [23, 14, 0, 330, 0, 5, 1];
    Paired.p2r.locomotor_night = [3321, 3837, 3924, 3631, 2254, 1687, 1887];
    Paired.p3l.locomotor_day = [135, 30, 32, 155, 142, 53, 52];
    Paired.p3l.locomotor_night = [1786, 1460, 1219, 1886, 1458, 2409, 1874];
    Paired.p3r.locomotor_day = [173, 57, 52, 17, 19, 13, 25];
    Paired.p3r.locomotor_night = [1325, 856, 1400, 1672, 1316, 2987, 1487];
    Paired.p4l.locomotor_day = [352, 25, 18, 1, 0, 7, 1];
    Paired.p4l.locomotor_night = [8911, 6346, 6805, 7083, 8687, 6742, 6782];
    Paired.p4r.locomotor_day = [32, 3, 2, 2, 25, 19, 37];
    Paired.p4r.locomotor_night = [3578, 3230, 2763, 1906, 1784, 1943, 1587];

    % =========== Interaction Event Data =============
    Interaction.p1.count_day = [10, 12, 14, 13, 8, 4, 5];
    Interaction.p1.count_night = [23, 42, 30, 43, 31, 21, 18];
    Interaction.p1.duration_day = [516, 811, 1108, 1468, 788, 417, 482];
    Interaction.p1.duration_night = [842, 2200, 2122, 2645, 1538, 821, 1727];
    
    Interaction.p2.count_day = [2, 2, 1, 8, 5, 2, 6];
    Interaction.p2.count_night = [31, 12, 13, 16, 27, 26, 15];
    Interaction.p2.duration_day = [51, 25, 14, 225, 140, 110, 149];
    Interaction.p2.duration_night = [1898, 328, 217, 181, 1072, 1374, 752];
    
    Interaction.p3.count_day = [14, 6, 12, 14, 5, 8, 12];
    Interaction.p3.count_night = [24, 31, 19, 19, 14, 21, 42];
    Interaction.p3.duration_day = [292, 62, 397, 445, 120, 403, 398];
    Interaction.p3.duration_night = [518, 869, 513, 567, 454, 633, 1248];
    
    Interaction.p4.count_day = [11, 0, 0, 1, 2, 2, 0];
    Interaction.p4.count_night = [37, 21, 29, 20, 45, 49, 50];
    Interaction.p4.duration_day = [83, 0, 0, 9, 9, 65, 0];
    Interaction.p4.duration_night = [901, 269, 1062, 826, 2538, 1977, 8271];

%%  --- Partner-Removed Animal's Daily Data (n=4) ---
    Removal.r1.count_day = [13, 16, 14, 13, 10, 19, 14];
    Removal.r1.count_night = [29, 23, 46, 38, 47, 27, 26];
    Removal.r1.duration_day = [410, 519, 1788, 1396, 199, 2788, 3187];
    Removal.r1.duration_night = [929, 690, 6349, 3098, 3443, 6003, 5372];
    Removal.r1.dur_divider_day = [NaN, 195, NaN, NaN, NaN, 146, NaN];
    Removal.r1.dur_divider_night = [NaN, 208, NaN, NaN, NaN, 545, NaN];

    Removal.r2.count_day = [22, 18, 8, 9, 10, 7, 8];
    Removal.r2.count_night = [62, 40, 30, 38, 24, 16, 34];
    Removal.r2.duration_day = [469, 278, 426, 153, 477, 486, 353];
    Removal.r2.duration_night = [3513, 2638, 1790, 2298, 1377, 1116, 1621];
    Removal.r2.dur_divider_day = [250, 80, 198, 58, 275, 163, 126];
    Removal.r2.dur_divider_night = [2119, 1484, 818, 1207, 976, 568, 576];

    Removal.r3.count_day = [20, 16, 23, 21, 15, 13, 14];
    Removal.r3.count_night = [34, 25, 39, 45, 20, 27, 34];
    Removal.r3.duration_day = [718, 351, 670, 619, 615, 492, 1170];
    Removal.r3.duration_night = [731, 391, 1722, 3218, 1102, 1294, 4024];
    Removal.r3.dur_divider_day = [362, 135, 292, 296, 245, 262, 176];
    Removal.r3.dur_divider_night = [472, 232, 312, 400, 361, 375, 372];

    Removal.r4.count_day = [34, 27, 21, 53, 51, 49, 38];
    Removal.r4.count_night = [75, 31, 52, 51, 92, 79, 83];
    Removal.r4.duration_day = [1604, 736, 1095, 1366, 2032, 1945, 2420];
    Removal.r4.duration_night = [1506, 706, 985, 1169, 2066, 3323, 1851];
    Removal.r4.dur_divider_day = [642, 253, 369, 466, 871, 356, 855];
    Removal.r4.dur_divider_night = [608, 264, 515, 633, 815, 854, 704];
    
    Removal.r1.locomotor_day = [31, 31, 2, 53, 318, 87, 30];
    Removal.r1.locomotor_night = [9217, 6687, 5721, 3402, 6094, 4698, 3478];
    Removal.r2.locomotor_day = [27, 0, 1, 0, 6, 1, 1];
    Removal.r2.locomotor_night = [1837, 666, 601, 646, 1036, 1129, 917];
    Removal.r3.locomotor_day = [1, 0, 2, 2, 6, 9, 9];
    Removal.r3.locomotor_night = [2803, 3075, 2527, 2145, 1399, 1434, 1500];
    Removal.r4.locomotor_day = [10, 0, 2, 1, 15, 12, 4];
    Removal.r4.locomotor_night = [8830, 7029, 7630, 6318, 5926, 6403, 5135];
    
%% Attach daily values by adding day values and night values together
    Paired = addDailyTotals(Paired);
    Interaction = addDailyTotals(Interaction);
    Removal = addDailyTotals(Removal);
    Solitary = addDailyTotals(Solitary);
%% Attach Quantified Social & Locomotor Activity file names
    % soc_file = social activity; loc_file = locomotor activity file
    % Interaction.ps only have social activity (interaction) file
    Paired = addFileNames(Paired, true, 'LD');
    Interaction = addFileNames(Interaction, false, 'LD');
    Removal = addFileNames(Removal, true, 'LD');
    Solitary = addFileNames(Solitary, true, 'LD');

%% Create nested LD data struct
    LDdata = struct();
    LDdata.Paired      = Paired;
    LDdata.Interaction = Interaction;
    LDdata.Removal     = Removal;
    LDdata.Solitary    = Solitary;
end

function DDdata = getDDdata()
    % GETDDDATA
    %
    % Loads and organizes all constant darkness (DD) behavioural datasets.
    % The returned structure contains four experiment categories:
    %   DDdata.Solitary    -> solitary housed animals     (s1-s4)
    %   DDdata.Paired      -> paired animals    (p1l/p1r-p4l/p4r)
    %   DDdata.Removal     -> partner-removal animals     (r1-r4)
    %   DDdata.Interaction -> dyadic interaction events   (p1-p4)
    %
    % Each animal/pair structure may contain:
    %   - Free-running circadian period
    %   - CT12 reference time
    %   - Daily behavioural counts
    %   - Daily behavioural durations
    %   - Duration normalization/divider values
    %   - File paths for quantified behavioural data
    %   - AWD locomotor activity file path

%% Circadian parameters (free-running period and CT12 reference)
    Paired = struct(); 
    Interaction = struct();
    Removal = struct(); 
    Solitary = struct(); 

    Solitary.s1.period = 23 + 56/60;
    Solitary.s2.period = 23 + 56/60;
    Solitary.s3.period = 23 + 44/60;
    Solitary.s4.period = 23 + 41/60;
    Solitary.s1.CT12   = datetime('2026-01-02 18:50:00');
    Solitary.s2.CT12   = datetime('2026-01-02 18:50:00');
    Solitary.s3.CT12   = datetime('2026-03-16 02:00:00');
    Solitary.s4.CT12   = datetime('2026-03-16 02:00:00');

    Paired.p1l.period = 23 + 45/60;
    Paired.p1r.period = 23 + 50/60;
    Paired.p1l.CT12   = datetime('2025-12-17 18:50:00');
    Paired.p1r.CT12   = datetime('2025-12-17 18:50:00');  
    Removal.r1.period = Paired.p1l.period;
    Removal.r1.CT12   = Paired.p1l.CT12;

    Paired.p2l.period = 23 + 45/60;
    Paired.p2r.period = 24 + 5/60;
    Paired.p2l.CT12   = datetime('2026-01-02 18:50:00');
    Paired.p2r.CT12   = datetime('2026-01-02 18:50:00');
    Removal.r2.period = Paired.p2r.period;
    Removal.r2.CT12   = Paired.p2l.CT12;

    Paired.p3l.period = 23 + 56/60;
    Paired.p3r.period = 23 + 58/60;
    Paired.p3l.CT12   = datetime('2026-01-04 18:50:00');
    Paired.p3r.CT12   = datetime('2026-01-04 18:50:00');
    Removal.r3.period = Paired.p3r.period;
    Removal.r3.CT12   = Paired.p3l.CT12;

    Paired.p4l.period = 23 + 51/60;
    Paired.p4r.period = 23 + 53/60;
    Paired.p4l.CT12   = datetime('2026-03-06 22:00:00');
    Paired.p4r.CT12   = datetime('2026-03-06 22:00:00');
    Removal.r4.period = Paired.p4l.period;
    Removal.r4.CT12   = Paired.p4l.CT12;
    
%% --- Solitary Animal's Daily Data (n=4) ---
    Solitary.s1.count = [53, 52, 52, 71, 50, 66, 70];
    Solitary.s1.duration = [2611, 8184, 5410, 4477, 9284, 6820, 10333];
    Solitary.s1.dur_divider = [180, 691, 215, 356, 230, 285, 234];

    Solitary.s2.count = [53, 49, 46, 55, 41, 62, 43];
    Solitary.s2.duration = [1257, 1931, 2891, 2058, 2150, 3065, 1799];
    Solitary.s2.dur_divider = [510, 416, 413, 935, 343, 154, 680];
    
    Solitary.s3.count = [82, 82, 44, 71, 89, 89, 81];
    Solitary.s3.duration = [2278, 1444, 377, 2832, 3023, 2852, 3010];
    Solitary.s3.dur_divider = [239, 124, 71, 118, 601, 643, 496];

    Solitary.s4.count = [59, 68, 79, 46, 48, 35, 25];
    Solitary.s4.duration = [1728, 1649, 2620, 1969, 1661, 1116, 1213];
    Solitary.s4.dur_divider = [436, 590, 605, 186, 234, 67, 356];


%% --- Paired Animal's Daily Data (n=8 animals, 4 pairs) ---
    Paired.p1l.count = [80, 72, 65, 82, 61, 85, 40];
    Paired.p1l.duration = [8166, 8603, 8235, 8415, 7646, 6473, 4293];
    Paired.p1l.dur_divider = [2129, 3643, 3119, 2506, 1285, 1578, 946];
    Paired.p1r.count = [60, 71, 74, 70, 54, 51, 36];
    Paired.p1r.duration = [6348, 13680, 7875, 6257, 2389, 5563, 6297];
    Paired.p1r.dur_divider = [3357, 4241, 2602, 1487, 1087, 1342, 1158];

    Paired.p2l.count = [64, 79, 89, 81, 73, 77, 83];
    Paired.p2l.duration = [3186, 4956, 5137, 5208, 4159, 4356, 4519];
    Paired.p2l.dur_divider = [2148, 2022, 1953, 2619, 2332, 3217, 3196];
    Paired.p2r.count = [126, 102, 79, 71, 64, 85, 85];
    Paired.p2r.duration = [31938, 33776, 28109, 27378, 24952, 26317, 21571];
    Paired.p2r.dur_divider = [6221, 5692, 5261, 4082, 2937, 4468, 4146];

    Paired.p3l.count = [NaN, NaN, 78, 72, 51, 66, 55];
    Paired.p3l.duration = [NaN, NaN, 6533, 10599, 11646, 10503, 9625];
    Paired.p3l.dur_divider = [NaN, NaN, 816, 778, 602, 524, 284];
    Paired.p3r.count = [NaN, NaN, 144, 148, 154, 127, 107];
    Paired.p3r.duration = [NaN, NaN, 15571, 13852, 13831, 14817, 15659];
    Paired.p3r.dur_divider = [NaN, NaN, 3395, 2476, 2702, 1616, 1909];

    Paired.p4l.count = [92, 91, 84, 92, 96, NaN, NaN];
    Paired.p4l.duration = [13796, 12376, 9913, 12976, 18560, NaN, NaN];
    Paired.p4l.dur_divider = [1757, 777, 1663, 1037, 1553, NaN, NaN];
    Paired.p4r.count = [108, 96, 72, 58, 94, NaN, NaN];
    Paired.p4r.duration = [9630, 9329, 8549, 7721, 10147, NaN, NaN];
    Paired.p4r.dur_divider = [2277, 1595, 1368, 1230, 1494, NaN, NaN];

%   Interaction Data
    Interaction.p1.period = [Paired.p1l.period Paired.p1r.period];
    Interaction.p1.count = [24, 37, 28, 31, 17, 20, 17];
    Interaction.p1.duration = [2063, 3252, 1950, 1675, 693, 1641, 2308];
    Interaction.p1.duration_both_divider = [508, 564, 266, 90, 87, 131, 112];

    Interaction.p2.period = [Paired.p2l.period, Paired.p2r.period];
    Interaction.p2.count = [43, 52, 43, 44, 27, 29, 37];
    Interaction.p2.duration = [2092, 2924, 2469, 3428, 1481, 1574, 2004];
    Interaction.p2.duration_both_divider = [611, 393, 318, 374, 337, 477, 506];

    Interaction.p3.period = [Paired.p3l.period, Paired.p3r.period];
    Interaction.p3.count = [88, 70, 58, 74, 62, 40, 37];
    Interaction.p3.duration = [4615, 4706, 2606, 5561, 5342, 2984, 3630];
    Interaction.p3.duration_both_divider = [189, 169, 87, 66, 150, 105, 68];
    
    Interaction.p4.period = [Paired.p4l.period, Paired.p4r.period];
    Interaction.p4.count = [38, 34, 24, 36, 51, NaN, NaN];
    Interaction.p4.duration = [2841, 2410, 1105, 2500, 3375, NaN, NaN];
    Interaction.p4.duration_both_divider = [75, 37, 49, 58, 59, NaN, NaN];

%% --- Partner-Removed Animal's Daily Data (n=4) ---
    Removal.r1.count = [89, 53, 93, 66, 64, 86, 53]; 
    Removal.r1.duration = [3311, 1307, 6523, 8491, 3509, 7169, 6355];
    Removal.r1.dur_divider = [611, 436, 793, 683, 681, 463, 471];

    Removal.r2.count = [62, 39, 44, 19, 29, 30, 47]; 
    Removal.r2.duration = [12187, 5505, 16383, 1845, 13468, 18881, 16863];
    Removal.r2.dur_divider = [1230, 1124, 859, 678, 849, 1441, 614];

    Removal.r3.count = [94, 72, 60, 48, 49, 51, 60]; 
    Removal.r3.duration = [3735, 3051, 2761, 3019, 3303, 6544, 3939];
    Removal.r3.dur_divider = [744, 661, 545, 412, 445, 530, 757];

    Removal.r4.count = [84 93 71 63 88 67 66]; 
    Removal.r4.duration = [12489 12727 8607 5829 10783 8781 9482];
    Removal.r4.dur_divider = [523 339 249 180 316 220 248];

%% Attach Quantified Social Activity file names
    Paired      = addFileNames(Paired, false, 'DD');
    Interaction = addFileNames(Interaction, false, 'DD');
    Removal     = addFileNames(Removal, false, 'DD');
    Solitary    = addFileNames(Solitary, false, 'DD');

%% Attach Locomotor .AWD file names
    Solitary.s1.file_awd = "DD_Locomotor/S1.awd";
    Solitary.s2.file_awd = "DD_Locomotor/S2.awd";
    Solitary.s3.file_awd = "DD_Locomotor/S3.awd";
    Solitary.s4.file_awd = "DD_Locomotor/S4.awd";
    Paired.p1l.file_awd  = "DD_Locomotor/P1L.awd";
    Paired.p1r.file_awd  = "DD_Locomotor/P1R.awd";
    Paired.p2l.file_awd  = "DD_Locomotor/P2L.awd";
    Paired.p2r.file_awd  = "DD_Locomotor/P2R.awd";
    Paired.p3l.file_awd  = "DD_Locomotor/P3L.awd";
    Paired.p3r.file_awd  = "DD_Locomotor/P3R.awd";
    Paired.p4l.file_awd  = "DD_Locomotor/P4L.awd";
    Paired.p4r.file_awd  = "DD_Locomotor/P4R.awd";
    Removal.r1.file_awd  = "DD_Locomotor/R1.awd";
    Removal.r2.file_awd  = "DD_Locomotor/R2.awd";
    Removal.r3.file_awd  = "DD_Locomotor/R3.awd";
    Removal.r4.file_awd  = "DD_Locomotor/R4.awd";
    
%% Create nested DD data struct
    DDdata = struct();

    DDdata.Paired      = Paired;
    DDdata.Interaction = Interaction;
    DDdata.Removal     = Removal;
    DDdata.Solitary    = Solitary;
end

function S = addDailyTotals(S)
% Called by getLDdata() and getDDdata()
%
% Automatically generates daily total variables by summing
% matching *_day and *_night fields. Missing fields are skipped.
%
% Supported variables:
%   count
%   duration
%   dur_divider
%   locomotor_daily

    pairs = {
        'count',         'count_day',         'count_night'
        'duration',      'duration_day',      'duration_night'
        'dur_divider',    'dur_divider_day',    'dur_divider_night'
        'locomotor',    'locomotor_day',    'locomotor_night'
    };
    fields = fieldnames(S);

    for f = 1:numel(fields)
        name = fields{f};
        for i = 1:size(pairs,1)
    
            totalField = pairs{i,1};
            dayField   = pairs{i,2};
            nightField = pairs{i,3};
    
            if isfield(S.(name), dayField) && isfield(S.(name), nightField)
                S.(name).(totalField) = ...
                    S.(name).(dayField) + S.(name).(nightField);
            end
        end
    end
end
function S = addFileNames(S, hasLocFile, lighting)
% Called by getLDdata() and getDDdata()
%
% Attach associated data filenames, generated from structure names.
% soc_file -> quantified social activity CSV
% loc_file -> quantified locomotor activity CSV
%
% Example:
%   Paired.p1l -> "p1l_soc.csv"

    fields = fieldnames(S);
    for i = 1:numel(fields)
        name = fields{i};
        soc_name = lower(name) + "_soc.csv";
        S.(name).soc_file = strcat('Data/',lighting, '_Quantified/', soc_name);
        if hasLocFile
            loc_name = lower(name) + "_loc.csv";
            S.(name).loc_file = strcat('Data/',lighting, '_Quantified/', loc_name);
        end
    end
end

function means = extractMeans(Data)
% Calculates the mean value of each numeric field across days
% for every animal/pair in a data structure.
%
% INPUT
%   Data: Structure containing animal data.
%
% OUTPUT
%   means: Structure containing mean values for each variable.

    means = struct();
    
    % Get all animal IDs
    animals = fieldnames(Data);
    
    % Get variable names from the first animal
    items = fieldnames(Data.(animals{1}));

    % Loop through each variable/field
    for i = 1:length(items)

        item = items{i};
        % Preallocate output vector
        item_means = NaN(length(animals), 1);

        for n = 1:numel(animals)
            animal = animals{n};

            if isfield(Data.(animal), item) && ...
               isnumeric(Data.(animal).(item))
               
                item_means(n) = mean(Data.(animal).(item), 'omitnan');
            
            end
        end
        means.(item) = item_means;
    end
end