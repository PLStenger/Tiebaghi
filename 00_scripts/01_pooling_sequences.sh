#!/usr/bin/env bash

# pathways in cluster:
DATADIRECTORY_16S=/scratch_vol1/fungi/Tiebaghi/01_raw_data/16S
OUTPUT_16S=/scratch_vol1/fungi/Tiebaghi/02_pooled_data/16S

DATADIRECTORY_ITS=/scratch_vol1/fungi/Tiebaghi/01_raw_data/ITS
OUTPUT_ITS=/scratch_vol1/fungi/Tiebaghi/02_pooled_data/ITS

WORKING_DIRECTORY=/scratch_vol1/fungi/Tiebaghi

# pathways in local:
#DATADIRECTORY_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/00_raw_data/16S
#OUTPUT_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/01_pooled/16S

#DATADIRECTORY_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/00_raw_data/ITS
#OUTPUT_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/01_pooled/ITS

# WARNING : HERE ITS NOT NECESSARY TO POOL SEQ, ONLY CHANGE THE NAME

cd $WORKING_DIRECTORY

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p $OUTPUT_ITS
mkdir -p $OUTPUT_16S

cd $DATADIRECTORY_16S

#cat Pa-1-5-1_S106_L001_R1_001.fastq.gz > $OUTPUT_16S/Pa-1-5-1_S106_R1.fastq.gz


cd $DATADIRECTORY_ITS

#cat Pa-1-5-1_S106_L001_R1_001.fastq.gz > $OUTPUT_ITS/Pa-1-5-1_S106_R1.fastq.gz

