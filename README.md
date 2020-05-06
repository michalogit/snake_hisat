# snake_hisat

Workflow for RNAseq, using hisat2 aligner 

## get the hisat index for human
```bash
wget https://cloud.biohpc.swmed.edu/index.php/s/grch38/download
mv download grch39.tar.gz
tar -xvzf grch39.tar.gz
```

## link the location in the Snakefile
eg
```python
GENOME="/cluster/home/michalo/project_michalo/hisat/grch38/genome"
```

## get the GTF
```bash
wget ftp://ftp.ensembl.org/pub/release-99/gtf/homo_sapiens/Homo_sapiens.GRCh38.99.gtf.gz
gunzip Homo_sapiens.GRCh38.99.gtf.gz
```

## link the GTF in Snakefile
eg
```python
GTF="/cluster/home/michalo/project_michalo/hg38/Homo_sapiens.GRCh38.99.gtf"
```



## TO DO:
Remove calls to software modules. If you want to use it locally, the software from the workflow: trimmomatic, hisat, etc, needs to be installed locally


## Running

Create a run directory, where you place: Snakefile, adapters.fa and fastq.gz files in "data" subdirectory. 
Do the updates to the Snakefile as above: location of genome index and GTF annotation, then:

### dry run

snakemake -np

### normal run

snakemake -p


