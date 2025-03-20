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



## Software required:
If you want to use it locally, the software from the workflow: trimmomatic, hisat, subread, samtools need to be installed locally and made runnable from command line

## Adapting
The paths to genome, GTF and adapters need to be set in the python constants in the Snakefile
If needed, also paths to the software commands and trimmomatic jar. Recommended is to have them in the executable or java paths, eg with setting the environment value. 


## Running

Create a run directory, where you place: Snakefile, adapters.fa and fastq.gz files in "data" subdirectory. 
Do the updates to the Snakefile as above: location of genome index and GTF annotation, then:

### dry run

snakemake -np

### normal run

snakemake -p

### run on the cluster

Make the snakemake available in the cluster environment, eg
```bash
module load gcc/8.2.0 python/3.10.4
```

#### LSF
```bash
snakemake -p -j 999 --cluster-config cluster.json --cluster "bsub -W {cluster.time} -n {cluster.n}"
```

#### SLURM
```bash
# change times in cluster.json to HH:MM:SS
snakemake -p -j 999 --cluster-config cluster.json --cluster "sbatch --time {cluster.time} -n {cluster.n}"
snakemake -p -j 999 --cluster-config cluster.json --cluster "sbatch --time {cluster.time} -n 1 --cpus-per-task={cluster.n}"
snakemake -p -j 999 --cluster-config cluster.json --cluster "sbatch --time {cluster.time} -n 1 --cpus-per-task={cluster.n} --mem-per-cpu={cluster.mem}"
```
#### SLURM with containers

Running the workflow with the containers from [Galaxy software stack](https://depot.galaxyproject.org/singularity/)
requires passing the external folders as singularity parameters to the snakemake. 
The containers will be loaded into .snakemake folder. 

```bash
 snakemake -p -j 999 --use-singularity --cluster-config cluster.json \
  --cluster "sbatch --time {cluster.time} -n 1 --cpus-per-task={cluster.n}" \
  --singularity-args "--bind /cluster/scratch/username/runfolder/:/mnt2 --bind /cluster/home/michalo/project_michalo/hisat/grch38/:/genomes --bind /cluster/home/michalo/project_michalo/hg38/:/annots"
``` 

### Snakemake version 8 and 9

Use the snakemake 8 or 9, eg by installing the environment

```bash
module load  stack/2024-06  gcc/12.2.0 python/3.11.6
VENV=/cluster/project/sis/cdss/michalo/venv2
python -m venv $VENV
source $VENV/bin/activate
#python -m pip install --upgrade pip
pip install snakemake 
pip install pandas
pip install snakemake-executor-plugin-cluster-generic

VENV=/cluster/project/sis/cdss/michalo/venv2
source $VENV/bin/activate
```
Then pick the right snakefile to run

```bash
cp Snakemake Snakemake_old
cp Snakefile_v8_stackMar25 Snakemake
snakemake --profile simple_profile/ -np
snakemake --profile simple_profile/ 
``` 

