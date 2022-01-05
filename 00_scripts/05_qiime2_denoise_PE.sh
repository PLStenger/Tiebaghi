#!/usr/bin/env bash

# pathways in cluster:
DATADIRECTORY_ITS=/scratch_vol1/fungi/Tiebaghi/05_QIIME2/ITS/
DATADIRECTORY_16S=/scratch_vol1/fungi/Tiebaghi/05_QIIME2/16S/

METADATA_FUNGI=/scratch_vol1/fungi/Tiebaghi/98_database_files/ITS/sample-metadata.tsv
METADATA_BACTERIA=/scratch_vol1/fungi/Tiebaghi/98_database_files/16S/sample-metadata.tsv

# pathways in local:
#DATADIRECTORY_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/05_QIIME2/Paired_end/ITS2/
#DATADIRECTORY_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/05_QIIME2/Paired_end/V4/

#METADATA_FUNGI=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/98_database_files/ITS/sample-metadata.tsv
#METADATA_BACTERIA=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/98_database_files/16S/sample-metadata.tsv


# https://chmi-sops.github.io/mydoc_qiime2.html

# https://docs.qiime2.org/2021.2/plugins/available/dada2/denoise-single/
# Aim: denoises single-end sequences, dereplicates them, and filters
# chimeras and singletons sequences
# Use: qiime dada2 denoise-single [OPTIONS]

# DADA2 method

 ###############################################################
 ### For Fungi
 ###############################################################
 
 cd $DATADIRECTORY_ITS
 
 eval "$(conda shell.bash hook)"
 conda activate qiime2-2021.4
 
 # dada2_denoise :
 #################
 
 # Aim: denoises paired-end sequences, dereplicates them, and filters
 #      chimeras and singletons sequences
 
 # https://github.com/benjjneb/dada2/issues/477
 
 qiime dada2 denoise-paired --i-demultiplexed-seqs core/demux.qza \
 --o-table core/Table.qza  \
 --o-representative-sequences core/RepSeq.qza \
 --o-denoising-stats core/Stats.qza \
 --p-trim-left-f 0 \
 --p-trim-left-r 0 \
 --p-trunc-len-f 0 \
 --p-trunc-len-r 0 \
 --p-n-threads 4   
 
 ##################################################################
 # Negative control
 ##################################################################
 qiime dada2 denoise-paired --i-demultiplexed-seqs core/demux_neg.qza \
 --o-table core/Table_neg.qza  \
 --o-representative-sequences core/RepSeq_neg.qza \
 --o-denoising-stats core/Stats_neg.qza \
 --p-trim-left-f 0 \
 --p-trim-left-r 0 \
 --p-trunc-len-f 0 \
 --p-trunc-len-r 0 \
 --p-n-threads 4   
 
 # sequence_contamination_filter :
 #################################
 
 # Aim: aligns feature sequences to a set of reference sequences
 #      to identify sequences that hit/miss the reference
 #      Use: qiime quality-control exclude-seqs [OPTIONS]
 
 # 0.97 is the default (see https://docs.qiime2.org/2020.2/plugins/available/quality-control/exclude-seqs/)
 # Whereas N. Fernandez put 1.00 but didn't work forward (" All features were filtered out of the data." error to the step "qiime feature-table filter-seqs")
 
 # Here --i-reference-sequences correspond to the negative control sample (if you don't have any, like here, take another one from an old project, the one here is from the same sequencing line (but not same project))
 
 qiime quality-control exclude-seqs --i-query-sequences core/RepSeq.qza \
       					     --i-reference-sequences core/RepSeq_neg.qza\
       					     --p-method vsearch \
       					     --p-threads 6 \
       					     --p-perc-identity 1.00 \
       					     --p-perc-query-aligned 1.00 \
       					     --o-sequence-hits core/HitNegCtrl.qza \
       					     --o-sequence-misses core/NegRepSeq.qza
 
 # table_contamination_filter :
 ##############################
 
 # Aim: filter features from table based on frequency and/or metadata
 #      Use: qiime feature-table filter-features [OPTIONS]
 
 # --p-exclude-ids: --p-no-exclude-ids If true, the samples selected by `metadata` or `where` parameters will be excluded from the filtered table instead of being retained. [default: False]:
 
 qiime feature-table filter-features --i-table core/Table.qza \
      					      --m-metadata-file core/HitNegCtrl.qza \
      					      --o-filtered-table core/NegTable.qza \
      					      --p-exclude-ids
 
 # table_contingency_filter :
 ############################
 
 # Aim: filter features that show up in only one samples, based on
 #      the suspicion that these may not represent real biological diversity
 #      but rather PCR or sequencing errors (such as PCR chimeras)
 #      Use: qiime feature-table filter-features [OPTIONS]
 
 # contingency:
     # min_obs: 2  # Remove features that are present in only a single sample !
     # min_freq: 0 # Remove features with a total abundance (summed across all samples) of less than 0 !
 
 
 qiime feature-table filter-features  --i-table core/NegTable.qza \
         					       --p-min-samples 2 \
         					       --p-min-frequency 0 \
         					       --o-filtered-table core/ConTable.qza
 
 
 # sequence_contingency_filter :
 ###############################
 
 # Aim: Filter features from sequence based on table and/or metadata
        # Use: qiime feature-table filter-seqs [OPTIONS]
 
 qiime feature-table filter-seqs --i-data core/NegRepSeq.qza \
       					  --i-table core/ConTable.qza \
       					  --o-filtered-data core/ConRepSeq.qza
 
 
 # sequence_summarize :
 ######################
 
 # Aim: Generate tabular view of feature identifier to sequence mapping
        # Use: qiime feature-table tabulate-seqs [OPTIONS]
 
 qiime feature-table summarize --i-table core/Table.qza --m-sample-metadata-file $METADATA_FUNGI --o-visualization visual/Table.qzv
 qiime feature-table summarize --i-table core/ConTable.qza --m-sample-metadata-file $METADATA_FUNGI --o-visualization visual/ConTable.qzv
 qiime feature-table summarize --i-table core/NegTable.qza --m-sample-metadata-file $METADATA_FUNGI --o-visualization visual/NegTable.qzv
 qiime feature-table tabulate-seqs --i-data core/NegRepSeq.qza --o-visualization visual/NegRepSeq.qzv
 qiime feature-table tabulate-seqs --i-data core/RepSeq.qza --o-visualization visual/RepSeq.qzv
 qiime feature-table tabulate-seqs --i-data core/HitNegCtrl.qza --o-visualization visual/HitNegCtrl.qzv
 
 
 qiime tools export --input-path core/Table.qza --output-path export/core/Table
 qiime tools export --input-path core/ConTable.qza --output-path export/core/ConTable
 qiime tools export --input-path core/NegTable.qza --output-path export/core/NegTable
 qiime tools export --input-path core/NegRepSeq.qza --output-path export/core/NegRepSeq
 qiime tools export --input-path core/RepSeq.qza --output-path export/core/RepSeq
 qiime tools export --input-path core/HitNegCtrl.qza --output-path export/core/HitNegCtrl
 qiime tools export --input-path core/ConRepSeq.qza --output-path export/core/ConRepSeq
 qiime tools export --input-path core/Stats.qza  --output-path export/core/Stats
 
 qiime tools export --input-path visual/NegTable.qzv --output-path export/visual/NegTable
 qiime tools export --input-path visual/ConTable.qzv --output-path export/visual/ConTable
 qiime tools export --input-path visual/Table.qzv --output-path export/visual/Table
 qiime tools export --input-path visual/HitNegCtrl.qzv --output-path export/visual/HitNegCtrl
 qiime tools export --input-path visual/RepSeq.qzv --output-path export/visual/RepSeq
 qiime tools export --input-path visual/NegRepSeq.qzv --output-path export/visual/NegRepSeq
 
###############################################################
### For Bacteria
###############################################################

cd $DATADIRECTORY_16S

eval "$(conda shell.bash hook)"
conda activate qiime2-2021.4

# dada2_denoise :
#################

# Aim: denoises paired-end sequences, dereplicates them, and filters
#      chimeras and singletons sequences

# https://github.com/benjjneb/dada2/issues/477

qiime dada2 denoise-paired --i-demultiplexed-seqs core/demux.qza \
--o-table core/Table.qza  \
--o-representative-sequences core/RepSeq.qza \
--o-denoising-stats core/Stats.qza \
--p-trim-left-f 0 \
--p-trim-left-r 0 \
--p-trunc-len-f 0 \
--p-trunc-len-r 0 \
--p-n-threads 4  

##################################################################
# Negative control
##################################################################
qiime dada2 denoise-paired --i-demultiplexed-seqs core/demux_neg.qza \
--o-table core/Table_neg.qza  \
--o-representative-sequences core/RepSeq_neg.qza \
--o-denoising-stats core/Stats_neg.qza \
--p-trim-left-f 0 \
--p-trim-left-r 0 \
--p-trunc-len-f 0 \
--p-trunc-len-r 0 \
--p-n-threads 4   

# sequence_contamination_filter :
#################################

# Aim: aligns feature sequences to a set of reference sequences
#      to identify sequences that hit/miss the reference
#      Use: qiime quality-control exclude-seqs [OPTIONS]

# Here --i-reference-sequences correspond to the negative control sample (if you don't have any, like here, take another one from an old project, the one here is from the same sequencing line (but not same project))


######### aqiime quality-control exclude-seqs --i-query-sequences core/RepSeq.qza \
######### a --i-reference-sequences core/RepSeq_neg.qza \
######### a --p-method vsearch \
######### a --p-threads 6 \
######### a --p-perc-identity 1.00 \
######### a --p-perc-query-aligned 1.00 \
######### a --o-sequence-hits core/HitNegCtrl.qza \
######### a --o-sequence-misses core/NegRepSeq.qza

# /scratch_vol1/fungi/Diversity_in_Mare_yam_crop/98_database_files/V4/Negative_control_Sample_RepSeq_V4.qza

qiime quality-control exclude-seqs --i-query-sequences core/RepSeq.qza \
 --i-reference-sequences /scratch_vol1/fungi/Diversity_in_Mare_yam_crop/98_database_files/V4/Negative_control_Sample_RepSeq_V4.qza \
 --p-method vsearch \
 --p-threads 6 \
 --p-perc-identity 1.00 \
 --p-perc-query-aligned 1.00 \
 --o-sequence-hits core/HitNegCtrl.qza \
 --o-sequence-misses core/NegRepSeq.qza

# table_contamination_filter :
##############################

# Aim: filter features from table based on frequency and/or metadata
#      Use: qiime feature-table filter-features [OPTIONS]

qiime feature-table filter-features --i-table core/Table.qza \
     					      --m-metadata-file core/HitNegCtrl.qza \
     					      --o-filtered-table core/NegTable.qza \
     					      --p-exclude-ids

# table_contingency_filter :
############################

# Aim: filter features that show up in only one samples, based on
#      the suspicion that these may not represent real biological diversity
#      but rather PCR or sequencing errors (such as PCR chimeras)
#      Use: qiime feature-table filter-features [OPTIONS]

# contingency:
    # min_obs: 2  # Remove features that are present in only a single sample !
    # min_freq: 0 # Remove features with a total abundance (summed across all samples) of less than 0 !


qiime feature-table filter-features  --i-table core/NegTable.qza \
        					       --p-min-samples 2 \
        					       --p-min-frequency 0 \
        					       --o-filtered-table core/ConTable.qza


# sequence_contingency_filter :
###############################

# Aim: Filter features from sequence based on table and/or metadata
       # Use: qiime feature-table filter-seqs [OPTIONS]

qiime feature-table filter-seqs --i-data core/NegRepSeq.qza \
      					  --i-table core/ConTable.qza \
      					  --o-filtered-data core/ConRepSeq.qza


# sequence_summarize :
######################

# Aim: Generate tabular view of feature identifier to sequence mapping
       # Use: qiime feature-table tabulate-seqs [OPTIONS]

qiime feature-table summarize --i-table core/Table.qza --m-sample-metadata-file $METADATA_BACTERIA --o-visualization visual/Table.qzv
qiime feature-table summarize --i-table core/ConTable.qza --m-sample-metadata-file $METADATA_BACTERIA --o-visualization visual/ConTable.qzv
qiime feature-table summarize --i-table core/NegTable.qza --m-sample-metadata-file $METADATA_BACTERIA --o-visualization visual/NegTable.qzv
qiime feature-table tabulate-seqs --i-data core/NegRepSeq.qza --o-visualization visual/NegRepSeq.qzv
qiime feature-table tabulate-seqs --i-data core/RepSeq.qza --o-visualization visual/RepSeq.qzv
qiime feature-table tabulate-seqs --i-data core/HitNegCtrl.qza --o-visualization visual/HitNegCtrl.qzv


qiime tools export --input-path core/Table.qza --output-path export/core/Table
qiime tools export --input-path core/ConTable.qza --output-path export/core/ConTable
qiime tools export --input-path core/NegTable.qza --output-path export/core/NegTable
qiime tools export --input-path core/NegRepSeq.qza --output-path export/core/NegRepSeq
qiime tools export --input-path core/RepSeq.qza --output-path export/core/RepSeq
qiime tools export --input-path core/HitNegCtrl.qza --output-path export/core/HitNegCtrl
qiime tools export --input-path core/ConRepSeq.qza --output-path export/core/ConRepSeq
qiime tools export --input-path core/Stats.qza  --output-path export/core/Stats

qiime tools export --input-path visual/NegTable.qzv --output-path export/visual/NegTable
qiime tools export --input-path visual/ConTable.qzv --output-path export/visual/ConTable
qiime tools export --input-path visual/Table.qzv --output-path export/visual/Table
qiime tools export --input-path visual/HitNegCtrl.qzv --output-path export/visual/HitNegCtrl
qiime tools export --input-path visual/RepSeq.qzv --output-path export/visual/RepSeq
qiime tools export --input-path visual/NegRepSeq.qzv --output-path export/visual/NegRepSeq
