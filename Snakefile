import pandas as pd

OUTPUT_DIR = config["output_dir"]
SAMPLESHEET = config["samplesheet"]

# Read the samplesheet and check for errors
try:
    samples = pd.read_csv(SAMPLESHEET)
    samples.columns = samples.columns.str.lower()
    samples = samples.set_index("sample", drop=False)
except FileNotFoundError:
    raise FileNotFoundError(f"Samplesheet file not found at: {SAMPLESHEET}")
except KeyError:
    raise KeyError("The samplesheet must contain a 'sample' column.")

# Error checking for non-unique sample names
if not samples.index.is_unique:
    raise ValueError("Sample names in the samplesheet are not unique.")

# Error checking for non-unique read names
if samples['read1'].duplicated().any() or samples['read2'].duplicated().any():
    raise ValueError("Read names (read1 or read2) in the samplesheet are not unique.")

SAMPLES = samples.index.tolist()

# the files that snakemake should expect by the end of the workflow
rule all:
    input: 
        expand(f"{OUTPUT_DIR}/{{sample}}.bam", sample=SAMPLES),
        expand(f"{OUTPUT_DIR}/{{sample}}.bai", sample=SAMPLES),

rule fq2bam:
    input:
        read1=lambda wildcards: samples.loc[wildcards.sample, "read1"],
        read2=lambda wildcards: samples.loc[wildcards.sample, "read2"],
        reference=config["reference_genome"],
    params:
        singularity=config["singularity_exec"],
        output_dir=OUTPUT_DIR,
        mnt=config["mnt"],
        sample_name="{sample}"
    output:
        bam=f"{OUTPUT_DIR}/{{sample}}.bam",
        bai=f"{OUTPUT_DIR}/{{sample}}.bai",
    threads: 16
    resources:
        mem_gb=240,
        time="96:00:00",
        gres="gpu:a100:1",
        partition="gpu",
        cpus_per_task=lambda wildcards, threads: threads
    shell:
        """
        module load singularity
        module load cuda

        singularity exec --nv \ 
            --bind {params.mnt} \
            {params.singularity} \
            pbrun fq2bam \
            --ref {input.reference} \
            --in-fq {input.read1} {input.read2} \
            --out-bam {params.output_dir}/{params.sample_name}.bam
        """