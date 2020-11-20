# nCovPopDyn pipeline

This pipeline was created as a simple tool to study the change of nucleotide diversity over time in a collection of sequences.

## Input
As an input the pipeline requires a file containing sequences and a one with a reference consenus sequence.

For the sequences it is important that they contain a sequencing-, or better, sample-date. The date must have the format **%YYYY-%mm-%dd**
and has to be either part of the sequence-name or provided in an additional tsv-file.
- If the date is part of the sequence-name, then the name should look like this: **'some_name | %YYYY-%mm-%dd'**.   
- If the date is provided in an additional file, then the file must have a column **'strain'**, containing the sequence name, and a column **'date'**, containing the date.

## Output
The pipeline creates a folder **'results'**, containing all (intermediate) outputs, with the following structure:
```
    ├── results                                 # Main results folder
    │   ├── analysis                            # Nucleotide diversity plots and table
    │   ├── bam                                 # sorted and indexed bam files
    │   ├── bins                                # binning results
    │       ├── cal_week                        # binned by calendar week
    │       ├── eq_days_10                      # binned by equal days                       
    │       ├── eq_size_100                     # binned by equal number of sequences
    │       ├── fuzzy_days_100                  # binned by equal number of sequences (fuzzy)
    │               ├── bin_*.bam               # binned sequences as BAM
    │               ├── counts_*.tsv            # count matrix                       
    │               ├── header_*.tsv            # header files (seq. name & date)
    |               ├── range_*.tsv             # range of dates of the corresponding bin
    |   ├── fixed_cigars_bins                   # binning results with modified CIGAR strings
    │       ├── cal_week                        # binned by calendar week
    │       ├── eq_days_10                      # binned by equal days                       
    │       ├── eq_size_100                     # binned by equal number of sequences
    │       ├── fuzzy_days_100                  # binned by equal number of sequences (fuzzy)
    │               ├── bin_*.bam               # binned sequences as BAM
    │               ├── bin_*.bai               # corresponding index BAM files
    │   ├── plots                               # Results plots (and tables)
    │   └── raw                                 # Preprocessed files
    │   
    └── ...
```
The final diversity analysis (plots and tables) can be found in the subfolder **results/plots**.


## How to run this pipeline - A small instruction

This is a small guide on how to run the pipeline. If you follow this instruction, it will be easier to understand what went wrong in case of any trouble :)

### 1. Prerequisites
To run this pipeline, some tools have to be installed. While some are necessary (Snakemake, SamFixCigar), others are optional (Conda/Miniconda).
However, we recommend to follow all steps, since we cannot guarantee functionality otherwise.

#### 1.1 Install Conda/Miniconda - if you haven't yet

Conda will manage the dependencies of our pipeline. Instructions can be found here: https://docs.conda.io/projects/conda/en/latest/user-guide/install


#### 1.2 Create the working environment

Create a new environment where the pipeline will be executed, for example like this:

```
conda create --name ncov_pipeline
```

Then to activate this environment, type:

```
conda activate ncov_pipeline
```

#### 1.3 Install Snakemake

Snakemake is the workflow management system we use. Install it like this:

```
conda install snakemake
```

#### 1.4 Download and compile SamFixCigar

Instruction can be found here: http://lindenb.github.io/jvarkit/SamFixCigar.html

### 2. Initialize the pipeline

As input the pipeline requires names of the sequence file and the reference genome, binning parameters and so on.
These variables are stored in [`config.yaml`](./config.yaml) and used as wildcards to create and link files with each other or as parameters for the binning.

#### 2.1 Raw sequences
The pipeline requires a file containing sequences, either with the date in the sequence-name or in a seperate file (as described earlier).
It is possible to provide one file of each type (date in seq.name/date in meta-file), however, it is currently not possible to run the pipeline with multiple input files of the same type.

- For sequence files containing the date within the sequence-name, move the file containing your sequences into the folder [`raw`](./raw).
Copy its filename (without extension) and paste it into the variable **samples** on line 1 of [`config.yaml`](./config.yaml):

  ```
  samples: "gisaid_cov2020_sequences-300320"
  ```

- For sequence files containing the date in a seperate tsv-file, make sure that both files have the same basename.
Then move both files (.fasta and .tsv) into the folder [`raw`](./raw).
Copy its filename (without extension) and paste it into the variable **samples_meta** on line 2 of [`config.yaml`](./config.yaml):

  ```
  samples_meta: "SARS-CoV-2"
  ```

If you run the pipeline with only one file, add an empty string to the other variable

#### 2.2 Reported cases data file

To compare estimated population dynamics with reported active cases, include a table in the folder [`reported_cases`](./reported_cases). Also provide the following parameters in the corresponding config field, for example like this:

  ```
  reported_cases: ["reported_cases.csv","\t","date","active_cases","%m/%d/%y"]
  ```
where the first element of the list is the file name with format extension, the second element is the delimiter type in this file, followed by date column name, active cases column name and a format the date is stored in.

#### 2.3 Reference consensus sequence
A reference consensus sequence is provided by the pipeline.
If you want to use a different consensus sequence, move the sequence into the folder [`consensus`](./consensus).
Further copy and paste its filename (without extension) into the variable **consensus** on line 3 of [`config.yaml`](./config.yaml).

  ```
  consensus: "ref_consensus"
  ```

#### 2.4 Binning parameters
You also have to set the parameters for some of the binning methods in [`config.yaml`](./config.yaml).
You can set the number of sequences per bin on line 5, and the number of days on line 6.
Parameters should be given as a list.

```
number_per_bin: [20, 30]
days_per_bin: [7, 10, 30]
```

#### 2.5 Metric Parameters

You should also specify minimal size of bin used for spline computation, and whether smoothing of cases reports data and log transformation of theta estimates is desired in [`config.yaml`](./config.yaml):

```
smoothing: False
```
```
log_transform: True
```
```
min_bin_size: 15
```



### 3. Run

To run the pipeline, go to Snakemake directory (where the Snakefile is) and activate the conda environment you created in step 1.2. Then enter the following command to execute the pipeline:


```
snakemake --use-conda --snakefile Snakefile --cores 2
```

The ---use-conda parameter allows Snakemake to install packages that are listed in the environment file [`env.yml`](./env/env.yml). The --cores parameter defines how many CPUs the pipeline will use.

Output of each pipeline step can be found in folder **results**.
