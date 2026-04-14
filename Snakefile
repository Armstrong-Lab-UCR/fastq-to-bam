# the files that snakemake should expect by the end of the workflow
configfile: "config.yaml"

OUTPUT_DIR = config["output_dir"]
SAMPLE_NAME = config["sample_name"]

rule all:
    input: 
        bam=f"{OUTPUT_DIR}/{SAMPLE_NAME}.bam",
        bai=f"{OUTPUT_DIR}/{SAMPLE_NAME}.bai",

rule fq2bam:
    input:
        read1=config["read1"],
        read2=config["read2"],
        reference=config["reference_genome"],
    params:
        singularity=config["singularity_exec"],
        output_dir=OUTPUT_DIR,
        mnt=config["mnt"]
    output:
        bam=f"{OUTPUT_DIR}/{SAMPLE_NAME}.bam",
        bai=f"{OUTPUT_DIR}/{SAMPLE_NAME}.bai",
    threads: 16
    resources:
        mem_gb=240,
        time="96:00:00",
        gres="gpu:a100:1",
        partition="gpu"
    shell:
        """
        module load singularity
        module load cuda

        singularity exec --nv \ 
            --bind: {params.mnt} \
            {params.singularity} \
            pbrun fq2bam \
            --ref {input.reference} \
            --in-fq {input.read1} {input.read2} \
            --out-bam {params.output_dir}/{SAMPLE_NAME}.bam
        """