#!/usr/bin/env bash

# installing FastQC from https://www.bioinformatics.babraham.ac.uk/projects/download.html
# FastQC v0.11.9 (Mac DMG image)

# Correct tool citation : Andrews, S. (2010). FastQC: a quality control tool for high throughput sequence data.

# pathways in cluster:
WORKING_DIRECTORY=/scratch_vol1/fungi/Tiebaghi
DATA_DIRECTORY_ITS=/scratch_vol1/fungi/Tiebaghi/03_cleaned_data/DATAOUTPUT_ITS
DATA_DIRECTORY_16S=/scratch_vol1/fungi/Tiebaghi/03_cleaned_data/DATAOUTPUT_16S
OUT_PUT_ITS=/scratch_vol1/fungi/Tiebaghi/04_cleaned_data_quality_check/OUT_PUT_ITS/
OUT_PUT_16S=/scratch_vol1/fungi/Tiebaghi/04_cleaned_data_quality_check/OUT_PUT_16S/

# pathways in local:
#WORKING_DIRECTORY=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi
#DATA_DIRECTORY_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/03_cleaned_data/DATAOUTPUT_ITS
#DATA_DIRECTORY_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/03_cleaned_data/DATAOUTPUT_16S
#OUT_PUT_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/03_cleaned_data_quality_check/OUT_PUT_ITS/
#OUT_PUT_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/03_cleaned_data_quality_check/OUT_PUT_16S/


cd $WORKING_DIRECTORY

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p $OUT_PUT_ITS
mkdir -p $OUT_PUT_16S

eval "$(conda shell.bash hook)"
conda activate fastqc

cd $DATA_DIRECTORY_ITS

# For ITS
for FILE in $(ls $DATA_DIRECTORY_ITS/*.fastq.gz)
do
      fastqc $FILE -o $OUT_PUT_ITS
done ;

conda deactivate fastqc
conda activate multiqc

# Run multiqc for quality summary

multiqc $OUT_PUT_ITS

conda deactivate multiqc
conda activate fastqc

#cd $DATA_DIRECTORY_16S
#
# For 16S
#for FILE in $(ls $DATA_DIRECTORY_16S/*.fastq.gz)
#do
#      fastqc $FILE -o $OUT_PUT_16S
#done ;
#
#conda deactivate fastqc
#conda activate multiqc

# Run multiqc for quality summary

#multiqc $OUT_PUT_16S
