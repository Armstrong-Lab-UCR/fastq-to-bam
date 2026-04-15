# FQ2BAM
This pipeline takes `.fastq` files and converts them to `.bam` using parabricks.

## Input Files
You only need 2 input files: a `config.yaml` specifying paths to specific files/executibles, and a `samplesheet.csv` that has at least the sample name, read1 and read2.

Your samplesheet can have any columns you want, but it **MUST** have the following fields named *exactly* `sample`, `read1`, and `read2` (but they don't have to be case sensitive!)

### Example `config.yaml`
```{yaml}
reference_genome: "/path/to/reference.fna"
output_dir: "output"
singularity_exec: "/bigdata/armstronglab/shared/applications/singularity_containers/clara-parabricks_4.1.1-1.sif"
mnt: "/path/to/where/you/want/to/mnt"
samplesheet: "/path/to/samplesheet.csv"
```
### Example `samplesheet.csv`
```{csv}
sample,read1,read2
mysample1,SRR928347_1.fastq,SRR928347_2.fastq
mysample2,SRR928348_1.fastq,SRR928348_2.fastq
```

## Output Files
The pipeline will output `.bam` files in the `output_dir` specified in the `config.yaml`, named `{sample}.bam`

### Example Output Files
- `output/mysample1.bam`
- `output/mysample1.bai`
- `output/mysample2.bam`
- `output/mysample2.bai`

## Multiple Libraries
If you have a sample prepped with multiple libraries, please pretend that these are different samples in the `samplesheet`. For example, this is what the `samplesheet` should look like with `mysample2` having multiple library preps:
```{csv}
sample,read1,read2
mysample1,SRR928347_1.fastq,SRR928347_2.fastq
mysample2_l1,SRR928348_1.fastq,SRR928348_2.fastq
mysample2_l2,SRR928349_1.fastq,SRR928349_2.fastq
```
Each sample must have a unique identifier, so in this case simply adding `_l1` or `_l2` to the sample name will effectively treat these as different samples for this step, which is what we want. 

## How to Run
1. Clone the repo:
```{bash}
git clone https://github.com/Armstrong-Lab-UCR/fastq-to-bam.git
```
2. Create your `config.yaml` and `samplesheet.csv` (these can be put straight in the `fastq-to-bam` dir OR exist elsewhere)
3. Start a `tmux` session so that the pipeline won't stop if you close your machine
    - on a terminal window on your laptop, ssh into the UCR cluster, and then do the following:
    ```{bash}
    # load the tmux module
    module load tmux/3.3
    # create a new background terminal session
    tmux new -s [session_name]
    ```
4. From the new background `tmux` session, load the snakemake module
```{bash}
module load snakemake/7.18
```
5. Navigate to the `fastq-to-bam` folder
6. Dry run the pipeline to make sure that everything looks okay
```{bash}
snakemake --configfile /path/to/your/config.yaml --profile profiles/slurm -n
```
7. After that successfully finishes, run the full pipeline
```{bash}
snakemake --configfile /path/to/your/config.yaml --profile profiles/slurm
```

### `tmux` Notes
- exit out of your tmux session: `ctrl` + `B`, then `D`
- go back into a session: `tmux a -t [session_name]`
- list `tmux` sesssions: `tmux list-sessions`
