# fastq to bam

should do the following: 
`.fastq` -> `.bam` 

## To-Dos
- update the profile for the updated snakemake?
## Input Files
- sample sheet/csv/yaml with read 1 and read 2 per sample
- reference genome
- where to put the output files
- singularity exec: /bigdata/armstronglab/shared/applications/singularity_containers/clara-parabricks_4.1.1-1.sif
## Output Files
- .bam and .bai files
## Resources
- gpu (--gres=gpu:a100:1)
- mem: 240G
- cpus: 16
- time: 96 hrs
## Modules
- singularity
- cuda
## How to Run
- for each sample, grab both reads 
- run this: 
```{bash}
singularity exec --nv \
    --bind :/mnt \
    $singularity_ex \
    pbrun fq2bam \
    --ref $ref_genome \
    --in-fq $read1 $read 2 \
    --out-bam $output_dir
```
- for example
```{bash}
for sample in FASTQ/*_1.fastq.gz; do
        base=`basename $sample _1.fastq.gz`
        R1=“FASTQ/${base}_1.fastq.gz”
        R2=“FASTQ/${base}_2.fastq.gz”
        output=“${base}.bam”

        singularity exec --nv \
        --bind /bigdata/armstronglab/eleun001/channelisland:/mnt \
        /bigdata/armstronglab/shared/applications/singularity_containers/clara-parabricks_4.1.1-1.sif \
        pbrun fq2bam --ref /mnt/channelfox_hap2_out_JBAT.review.May1.FINAL.fa  --in-fq $R1 $R2 --out-bam $OUTPUT_FOLDER/${base}.bam
done
```


