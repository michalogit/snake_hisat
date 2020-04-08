# snake_hisat



## get the hisat index for human
wget https://cloud.biohpc.swmed.edu/index.php/s/grch38/download
mv download grch39.tar.gz
tar -xvzf grch39.tar.gz

## link the location in the Snakefile

eg
GENOME="/cluster/home/michalo/project_michalo/hisat/grch38/genome"
