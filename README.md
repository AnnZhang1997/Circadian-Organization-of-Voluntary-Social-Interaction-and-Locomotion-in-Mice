# Social Interaction Rhythms Dataset and Analysis Code

This repository contains the processed behavioural data and MATLAB analysis code used in the manuscript:

> *Circadian Organization of Voluntary Social Interaction and Locomotion in Mice.*

The repository includes:
- MATLAB scripts used for statistical analyses reported in the manuscript
- Processed behavioural datasets for all experimental animals
- Locomotor activity data
- Quantified social interaction measurements

---

# Repository Structure

```text
.
├── Main.m
├── getData.m
├── Data/
│   ├── DD_Location/
│   ├── DD_Locomotor/
│   ├── DD_Quantified/
│   ├── LD_Location/
│   ├── LD_Locomotor/
│   └── LD_Quantified/
```

---

# Files

## `Main.m`

Annotated MATLAB script that runs all statistical analyses used in the manuscript.
This is the main entry point for reproducing the analyses presented in the paper.

---

## `getData.m`

MATLAB helper function called by `Main.m`.
This file:
- Stores processed daily average data for each animal
- Links analysis code to the corresponding `.csv` data files
- Organizes datasets across experimental conditions

---

# Data Folder

The `Data/` directory contains six subfolders corresponding to experimental condition and data type.

## Experimental Conditions

- `LD` — 12:12 h light-dark condition
- `DD` — constant dim red light (darkness equivalent) condition

---

# Data Types

## `*_Location`

Contains timestamped, video-verified location change data for individual animals stored as `.csv` files.
These files represent movement between apparatus compartments and were used to quantify social-seeking behaviour.

Example filenames:
```text
Paired1Left.csv
Paired1Right.csv
...
Paired4Left.csv
Paired4Right.csv

Removal1.csv
...
Removal4.csv

Solitary1.csv
...
Solitary4.csv
```

---

## `*_Locomotor`

Contains locomotor activity data stored as `.awd` files.
Data represent running wheel activity quantified as wheel turns per 6-minute bin.

File naming follows the same convention as the corresponding `_location` folders.

---

## `*_quantified`

Contains quantified social interaction/seeking data stored as `.csv` files.

Social interaction/seeking data represent the time spent in the interaction location, quantified as seconds per 6-minute bin.

For the `LD` condition folders, quantified locomotor activity data are additionally included for easier analysis. These data are equivalent to the corresponding `.awd` locomotor files, but reformatted into `.csv` table format.

File naming conventions:
- `##_soc.csv` — quantified social interaction/seeking data
- `##_loc.csv` — quantified locomotor activity data

Where `##` represents the experimental animal/group identifier:

```text
p1l/p1r - p4l/p4r : left/right animals from the 4 paired dyads
r1-r4               : the 4 partner-removed animals
s1-s4               : the 4 naïve solitary animals
p1-p4               : dyadic interaction data for the 4 paired groups
```


# Notes and Contact

- All behavioural timestamps and quantified measures are processed data used for statistical analysis in the submitted manuscript.
- Raw timestamped infrared breakbeam activation data, interaction chamber video recordings, the pre-processing python codes, and figure plotting matlab codes are not included in this repository. They may be obtained by contacting the corresponding author of the manuscript.
- For other questions regarding the dataset or analysis pipeline, please also contact the corresponding author of the manuscript.
