#from snakemake.utils import R
#import rpy2
import glob 
import os
import logging

# Globals ---------------------------------------------------------------------

shellcommand="mkdir data"
os.system(shellcommand)
shellcommand="mkdir trimmed_data"
os.system(shellcommand)
shellcommand="mkdir mapped_reads"
os.system(shellcommand)
shellcommand="mkdir sorted_reads"
os.system(shellcommand)
shellcommand="mkdir cufflinks"
os.system(shellcommand)
shellcommand="mkdir stringtie"
os.system(shellcommand)
shellcommand="mkdir secondary_analysis"
os.system(shellcommand)

#using Index https://cloud.biohpc.swmed.edu/index.php/s/grch38/download 
GENOME="/cluster/home/michalo/project_michalo/hisat/grch38/genome"
GTF="/cluster/home/michalo/project_michalo/hg38/Homo_sapiens.GRCh38.99.gtf"
TRIMFILE="adapters.fa"
CORES="24"


SAMPLES, = glob_wildcards("data/{sample}.fastq.gz")
print(SAMPLES)



localrules: all, summary_bai,  summary_string,  summary_bai, summary_cuff



rule all:
    input:
        "secondary_analysis/counts.csv",
        "secondary_analysis/final_marker_bai.txt",
        "secondary_analysis/final_marker_string.txt"
#        "secondary_analysis/final_marker_cuff.txt"


rule trim:
    input:
        "data/{sample}.fastq.gz"
    output:
        "trimmed_data/{sample}.fastq.gz"
    run:
        shell(
        'module load gdc \n'+
        'module load java \n'+
        'module load trimmomatic \n'+
        'echo {input} \n'+
        'trimmomatic SE -phred33 {input} {output} ILLUMINACLIP:'+TRIMFILE+':2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36'
        )


rule hisat_map:
    input:
        "trimmed_data/{sample}.fastq.gz"
    output:
        "mapped_reads/{sample}.sam"
    run:
        shell(
        'module load gcc/4.8.2 gdc python/2.7.11 hisat2/2.1.0 \n'+
        'echo {input} \n'+
        'hisat2  -q -p '+CORES+'-x '+GENOME+' -U {input} -S mapped_reads/{wildcards.sample}.sam \n')


rule samtools_convert:
    input:
        "mapped_reads/{sample}.sam"
    output:
        "mapped_reads/{sample}.bam"
    run:
        shell(
        'module load samtools \n'+
        'samtools view -@ '+CORES+' -bS {input} > {output} ')

rule samtools_sort:
    input:
        "mapped_reads/{sample}.bam"
    output:
        "sorted_reads/{sample}.bam"
    shell:
        "module load samtools \n"
        "samtools sort -@ 24 -T sorted_reads/{wildcards.sample} "
        "-O bam {input} > {output}"

rule samtools_index:
    input:
        "sorted_reads/{sample}.bam"
    output:
        "sorted_reads/{sample}.bam.bai"
    shell:
        "module load samtools \n"
        "samtools index {input}"

rule summary_bai:
    input:
        expand("sorted_reads/{sample}.bam.bai", sample=SAMPLES)
    output:
        "secondary_analysis/final_marker_bai.txt"
    shell:
        "touch secondary_analysis/final_marker_bai.txt"

rule stringtie:
    input:
        "sorted_reads/{sample}.bam"
    output:
        "stringtie/{sample}.gtf"
    shell:
        "stringtie --rf -o {output} -p 24 {input}"

rule summary_string:
    input:
        expand("stringtie/{sample}.gtf", sample=SAMPLES)
    output:
        "secondary_analysis/final_marker_string.txt"
    shell:
        "touch secondary_analysis/final_marker_string.txt"


rule cufflinks:
    input:
        "/cluster/home/michalo/scratch/PhilippL/sorted_reads/{sample}.bam"
    output:
        "cufflinks/{sample}/transcripts.gtf"
    shell:
        "module load legacy gcc/4.8.2 python/2.7.6 samtools/1.1 boost/1.55.0 eigen/3.2.1 cufflinks/2.2.1 \n"
#       "mkdir cufflinks/{wildcards.sample} \n"
        "cd cufflinks/{wildcards.sample} \n"
        "cufflinks -u --library-type fr-secondstrand {input}"

rule summary_cuff:
    input:
        expand("cufflinks/{sample}/transcripts.gtf", sample=SAMPLES)
    output:
        "secondary_analysis/final_marker_cuff.txt"
    shell:
        "touch secondary_analysis/final_marker_cuff.txt"


rule count_in_genes:
    input:
        "sorted_reads/{sample}.bam"
    output:
        "secondary_analysis/{sample}.cnt"
    shell:
        "module load subread \n"
        "featureCounts -M -f --fraction -s 2 -T 24 -t gene -g gene_id -a "+GTF+" -o {output} {input}"


rule create_count_table:
    input:
        expand("secondary_analysis/{sample}.cnt", sample = SAMPLES)
    output:
        "secondary_analysis/counts.csv"
    run:
        import pandas
        import glob

        filez = glob.glob('secondary_analysis/*.cnt')
        t1 = pandas.read_table(filez[1], header=1)
        tout = t1.iloc[:,0]
        for f in filez:
           t1=pandas.read_table(f, header=1)
           tout=pandas.concat([tout, t1.iloc[:,6]], axis=1)
           print(f)

        tout.to_csv('secondary_analysis/counts.csv')

         




