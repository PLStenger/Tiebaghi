#!/usr/bin/env bash

# pathways in cluster:
DATADIRECTORY_ITS=/scratch_vol1/fungi/Tiebaghi/03_cleaned_data/DATAOUTPUT_ITS
DATADIRECTORY_16S=/scratch_vol1/fungi/Tiebaghi/03_cleaned_data/DATAOUTPUT_16S

OUTPUT_ITS=/scratch_vol1/fungi/Tiebaghi/05_QIIME2/ITS
OUTPUT_16S=/scratch_vol1/fungi/Tiebaghi/05_QIIME2/16S

MANIFEST_FUNGI=/scratch_vol1/fungi/Tiebaghi/98_database_files/ITS/manifest_cluster
MANIFEST_BACTERIA=/scratch_vol1/fungi/Tiebaghi/98_database_files/16S/manifest_cluster

# For negative samples
MANIFEST_FUNGI_NEG=/scratch_vol1/fungi/Tiebaghi/98_database_files/ITS/manifest_cluster_neg
MANIFEST_BACTERIA_NEG=/scratch_vol1/fungi/Tiebaghi/98_database_files/16S/manifest_cluster_neg

# pathways in local:
#DATADIRECTORY_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/03_cleaned_data/DATAOUTPUT_ITS
#DATADIRECTORY_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/03_cleaned_data/DATAOUTPUT_16S

#OUTPUT_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/05_QIIME2/Paired_end/ITS2
#OUTPUT_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/05_QIIME2/Paired_end/V4

#MANIFEST_FUNGI=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/98_database_files/ITS2/manifest
#MANIFEST_BACTERIA=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/98_database_files/V4/manifest

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p $OUTPUT_ITS
mkdir -p $OUTPUT_16S

###############################################################
### For Fungi
###############################################################

cd $DATADIRECTORY_ITS

eval "$(conda shell.bash hook)"
conda activate qiime2-2021.4

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p $OUTPUT_ITS/core
mkdir -p $OUTPUT_ITS/visual

qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' \
			    --input-path  $MANIFEST_FUNGI \
			    --output-path $OUTPUT_ITS/core/demux.qza \
			    --input-format PairedEndFastqManifestPhred33V2


# For negative sample
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' \
			    --input-path  $MANIFEST_FUNGI_NEG \
			    --output-path $OUTPUT_ITS/core/demux_neg.qza \
			    --input-format PairedEndFastqManifestPhred33V2


cd $OUTPUT_ITS

qiime demux summarize --i-data core/demux.qza --o-visualization visual/demux.qzv
qiime demux summarize --i-data core/demux_neg.qza --o-visualization visual/demux_neg.qzv

# for vizualisation :
# https://view.qiime2.org

qiime tools export --input-path visual/demux.qzv --output-path export/visual/demux
qiime tools export --input-path core/demux.qza --output-path export/core/demux

qiime tools export --input-path visual/demux_neg.qzv --output-path export/visual/demux_neg
qiime tools export --input-path core/demux_neg.qza --output-path export/core/demux_neg


###############################################################
### For Bacteria
###############################################################

cd $DATADIRECTORY_16S

eval "$(conda shell.bash hook)"
conda activate qiime2-2021.4

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p $OUTPUT_16S/core
mkdir -p $OUTPUT_16S/visual

qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' \
			    --input-path  $MANIFEST_BACTERIA \
			    --output-path $OUTPUT_16S/core/demux.qza \
			    --input-format PairedEndFastqManifestPhred33V2

qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' \
			    --input-path  $MANIFEST_BACTERIA_NEG \
			    --output-path $OUTPUT_16S/core/demux_neg.qza \
			    --input-format PairedEndFastqManifestPhred33V2

cd $OUTPUT_16S

qiime demux summarize --i-data core/demux.qza --o-visualization visual/demux.qzv
qiime demux summarize --i-data core/demux_neg.qza --o-visualization visual/demux_neg.qzv

# for vizualisation :
# https://view.qiime2.org

qiime tools export --input-path visual/demux.qzv --output-path export/visual/demux
qiime tools export --input-path core/demux.qza --output-path export/core/demux

qiime tools export --input-path visual/demux_neg.qzv --output-path export/visual/demux_neg
qiime tools export --input-path core/demux_neg.qza --output-path export/core/demux_neg
