#!/usr/bin/env bash

# pathways in cluster:
DATADIRECTORY_ITS=/scratch_vol1/fungi/Tiebaghi/05_QIIME2/ITS/
DATADIRECTORY_16S=/scratch_vol1/fungi/Tiebaghi/05_QIIME2/16S/

METADATA_ITS=/scratch_vol1/fungi/Tiebaghi/98_database_files/ITS/
METADATA_16S=/scratch_vol1/fungi/Tiebaghi/98_database_files/16S/

# pathways in local:
#DATADIRECTORY_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/05_QIIME2/ITS/
#DATADIRECTORY_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/05_QIIME2/16S/

#METADATA_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/98_database_files/ITS/
#METADATA_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/98_database_files/16S/


###############################################################
### For Fungi
###############################################################

cd $DATADIRECTORY_ITS

eval "$(conda shell.bash hook)"
conda activate qiime2-2021.4

# Aim: Filter sample from table based on a feature table or metadata

qiime feature-table filter-samples \
        --i-table core/RarTable.qza \
        --m-metadata-file $METADATA_ITS/sample-metadata.tsv \
        --p-where "[#SampleID] IN ('TVG-1-00', 'TVG-1-03', 'TVG-1-06', 'TVG-1-12', 'TVG-1-18', 'TVG-1-24', 'TVG-1-60', 'TVG-2-00', 'TVG-2-03', 'TVG-2-06', 'TVG-2-12', 'TVG-2-18', 'TVG-2-24', 'TVG-2-60', 'TVG-3-00', 'TVG-3-03', 'TVG-3-06', 'TVG-3-12', 'TVG-3-18', 'TVG-3-24', 'TVG-3-60', 'TVG-4-00', 'TVG-4-03', 'TVG-4-06', 'TVG-4-12', 'TVG-4-18', 'TVG-4-24', 'TVG-4-60', 'TVG-5-00', 'TVG-5-03', 'TVG-5-06', 'TVG-5-12', 'TVG-5-18', 'TVG-5-24', 'TVG-5-60', 'TVR-1-00', 'TVR-1-03', 'TVR-1-06', 'TVR-1-12', 'TVR-1-18', 'TVR-1-24', 'TVR-1-60', 'TVR-2-00', 'TVR-2-03', 'TVR-2-06', 'TVR-2-12', 'TVR-2-18', 'TVR-2-24', 'TVR-2-60', 'TVR-3-00', 'TVR-3-03', 'TVR-3-06', 'TVR-3-12', 'TVR-3-18', 'TVR-3-24', 'TVR-3-60', 'TVR-4-00', 'TVR-4-03', 'TVR-4-06', 'TVR-4-12', 'TVR-4-18', 'TVR-4-24', 'TVR-4-60', 'TVR-5-00', 'TVR-5-03', 'TVR-5-06', 'TVR-5-12', 'TVR-5-18', 'TVR-5-24', 'TVR-5-60')"  \
        --o-filtered-table core/RarTable-all.qza

        
# Aim: Identify "core" features, which are features observed,
     # in a user-defined fraction of the samples

        
qiime feature-table core-features \
        --i-table core/RarTable-all.qza \
        --p-min-fraction 0.1 \
        --p-max-fraction 1.0 \
        --p-steps 10 \
        --o-visualization visual/CoreBiom-all.qzv  

qiime tools export --input-path core/RarTable-all.qza --output-path export/core/RarTable-all    
        
#qiime tools export --input-path visual/CoreBiomAll.qzv --output-path export/visual/CoreBiomAll
qiime tools export --input-path visual/CoreBiom-all.qzv --output-path export/visual/CoreBiom-all



###### Biom convert

# Aim: Convert to/from the BIOM table format

biom convert -i export/core/RarTable-all/feature-table.biom -o export/core/RarTable-all/table-from-biom.tsv --to-tsv

 # Aim: Remove first line and rename '#OTU ID' into 'ASV'

 sed '1d ; s/\#OTU ID/ASV_ID/' export/core/RarTable-all/table-from-biom.tsv > export/core/RarTable-all/ASV.tsv


###############################################################
### For Bacteria
###############################################################

cd $DATADIRECTORY_16S

eval "$(conda shell.bash hook)"
conda activate qiime2-2021.4

# Aim: Filter sample from table based on a feature table or metadata

 qiime feature-table filter-samples \
        --i-table core/RarTable.qza \
        --m-metadata-file $METADATA_ITS/sample-metadata.tsv \
        --p-where "[#SampleID] IN ('TVG-1-00', 'TVG-1-03', 'TVG-1-06', 'TVG-1-12', 'TVG-1-18', 'TVG-1-24', 'TVG-1-60', 'TVG-2-00', 'TVG-2-03', 'TVG-2-06', 'TVG-2-12', 'TVG-2-18', 'TVG-2-24', 'TVG-2-60', 'TVG-3-00', 'TVG-3-03', 'TVG-3-06', 'TVG-3-12', 'TVG-3-18', 'TVG-3-24', 'TVG-3-60', 'TVG-4-00', 'TVG-4-03', 'TVG-4-06', 'TVG-4-12', 'TVG-4-18', 'TVG-4-24', 'TVG-4-60', 'TVG-5-00', 'TVG-5-03', 'TVG-5-06', 'TVG-5-12', 'TVG-5-18', 'TVG-5-24', 'TVG-5-60', 'TVR-1-00', 'TVR-1-03', 'TVR-1-06', 'TVR-1-12', 'TVR-1-18', 'TVR-1-24', 'TVR-1-60', 'TVR-2-00', 'TVR-2-03', 'TVR-2-06', 'TVR-2-12', 'TVR-2-18', 'TVR-2-24', 'TVR-2-60', 'TVR-3-00', 'TVR-3-03', 'TVR-3-06', 'TVR-3-12', 'TVR-3-18', 'TVR-3-24', 'TVR-3-60', 'TVR-4-00', 'TVR-4-03', 'TVR-4-06', 'TVR-4-12', 'TVR-4-18', 'TVR-4-24', 'TVR-4-60', 'TVR-5-00', 'TVR-5-03', 'TVR-5-06', 'TVR-5-12', 'TVR-5-18', 'TVR-5-24', 'TVR-5-60)"  \
        --o-filtered-table core/RarTable-all.qza
           
           
# Aim: Identify "core" features, which are features observed,
     # in a user-defined fraction of the samples

qiime feature-table core-features \
        --i-table core/RarTable-all.qza \
        --p-min-fraction 0.1 \
        --p-max-fraction 1.0 \
        --p-steps 10 \
        --o-visualization visual/CoreBiom-all.qzv
        
qiime tools export --input-path core/RarTable-all.qza --output-path export/core/RarTable-all    
        
#qiime tools export --input-path visual/CoreBiomAll.qzv --output-path export/visual/CoreBiomAll
qiime tools export --input-path visual/CoreBiom-all.qzv --output-path export/visual/CoreBiom-all


###### Biom convert

# Aim: Convert to/from the BIOM table format

biom convert -i export/core/RarTable-all/feature-table.biom -o export/core/RarTable-all/table-from-biom.tsv --to-tsv

 # Aim: Remove first line and rename '#OTU ID' into 'ASV'
 
 sed '1d ; s/\#OTU ID/ASV_ID/' export/core/RarTable-all/table-from-biom.tsv >export/core/RarTable-all/ASV.tsv
