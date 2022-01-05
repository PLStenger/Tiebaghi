#!/usr/bin/env bash

# pathways in cluster:
DATADIRECTORY_ITS=/scratch_vol1/fungi/Tiebaghi/05_QIIME2/ITS/
DATADIRECTORY_16S=/scratch_vol1/fungi/Tiebaghi/05_QIIME2/16S/

METADATA_ITS=/scratch_vol1/fungi/Tiebaghi/98_database_files/ITS/
METADATA_16S=/scratch_vol1/fungi/Tiebaghi/98_database_files/16S/

TMPDIR=/scratch_vol1

#### pathways in local:
####DATADIRECTORY_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/05_QIIME2/ITS/
####DATADIRECTORY_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/05_QIIME2/16S/
###
####METADATA_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/98_database_files/ITS/
####METADATA_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/98_database_files/16S/
###
###
#### Aim: classify reads by taxon using a fitted classifier
###
#### https://docs.qiime2.org/2019.10/tutorials/moving-pictures/
#### In this step, you will take the denoised sequences from step 5 (rep-seqs.qza) and assign taxonomy to each sequence (phylum -> class -> …genus -> ). 
#### This step requires a trained classifer. You have the choice of either training your own classifier using the q2-feature-classifier or downloading a pretrained classifier.
###
#### https://docs.qiime2.org/2019.10/tutorials/feature-classifier/
###
###
#### Aim: Import data to create a new QIIME 2 Artifact
#### https://gitlab.com/IAC_SolVeg/CNRT_BIOINDIC/-/blob/master/snk/12_qiime2_taxonomy
###
###############################################################
### For Fungi
###############################################################

cd $DATADIRECTORY_ITS

eval "$(conda shell.bash hook)"
conda activate qiime2-2021.4

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p taxonomy
mkdir -p export/taxonomy

# I'm doing this step in order to deal the no space left in cluster :
export TMPDIR='/scratch_vol1/fungi'
echo $TMPDIR

#print 'ls /scratch_vol1/fungi'
#ls /scratch_vol1/fungi

#env

#df -h


# NEW DATABASE UNITE :
# sh_taxonomy_qiime_ver8_dynamic_s_10.05.2021.txt
# sh_refs_qiime_ver8_dynamic_s_10.05.2021.fasta
# from https://plutof.ut.ee/#/doi/10.15156/BIO/1264763
# Originaly from https://unite.ut.ee/repository.php
# When using this resource, please cite it as follows:
# Abarenkov, Kessy; Zirk, Allan; Piirmann, Timo; Pöhönen, Raivo; Ivanov, Filipp; Nilsson, R. Henrik; Kõljalg, Urmas (2021): UNITE QIIME release for Fungi 2. Version 10.05.2021. UNITE Community. https://doi.org/10.15156/BIO/1264763 
# Includes global and 97% singletons.

# OLD = /scratch_vol1/fungi/Diversity_in_Mare_yam_crop/98_database_files/ITS2/Taxonomy-UNITE-V7-S-2017.12.01-dynamic.txt

qiime tools import --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path /scratch_vol1/fungi/Tiebaghi/98_database_files/ITS/sh_taxonomy_qiime_ver8_dynamic_s_10.05.2021.txt \
  --output-path taxonomy/RefTaxo.qza

# You will need to importe the "Sequence-UNITE-V7-S-2017.12.01-dynamic.fasta" file by yourself because it's to big for beeing upload by GitHub.
# You can donwload it from here : https://gitlab.com/IAC_SolVeg/CNRT_BIOINDIC/-/tree/master/inp/qiime2/taxonomy/ITS

# OLD = /scratch_vol1/fungi/Diversity_in_Mare_yam_crop/98_database_files/ITS2/Sequence-UNITE-V7-S-2017.12.01-dynamic.fasta

qiime tools import --type 'FeatureData[Sequence]' \
  --input-path /scratch_vol1/fungi/Tiebaghi/98_database_files/ITS/sh_refs_qiime_ver8_dynamic_s_10.05.2021.fasta \
  --output-path taxonomy/DataSeq.qza

# Fungal ITS classifiers trained on the UNITE reference database do NOT benefit
# from extracting / trimming reads to primer sites.
# We recommend training UNITE classifiers on the full reference sequences !!!

# Furthermore, we recommend the 'developer' sequences
# (located within the QIIME-compatible release download),
# because the standard versions of the sequences have already been trimmed to
# the ITS region, excluding portions of flanking rRNA genes that may be present
# in amplicons generated with standard ITS primers.

# Aim: Rename import ITS DataSeq in ITS RefSeq for training.

cp taxonomy/DataSeq.qza taxonomy/RefSeq.qza

# Now in order to deal with the "no left space" problem, we will sned temporarly the files in the SCRATCH part of the cluster, I directly did this step in local and then upload the file in cluster

# Aim: Create a scikit-learn naive_bayes classifier for reads

qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads taxonomy/RefSeq.qza \
  --i-reference-taxonomy taxonomy/RefTaxo.qza \
  --o-classifier taxonomy/Classifier.qza

# Aim: Classify reads by taxon using a fitted classifier
# --p-reads-per-batch 1000

qiime feature-classifier classify-sklearn \
   --i-classifier taxonomy/Classifier.qza \
   --i-reads core/ConRepSeq.qza \
   --o-classification taxonomy/taxonomy_reads-per-batch_ConRepSeq.qza
   
qiime feature-classifier classify-sklearn \
  --i-classifier taxonomy/Classifier.qza \
  --i-reads core/RepSeq.qza \
  --o-classification taxonomy/taxonomy_reads-per-batch_RepSeq.qza

qiime feature-classifier classify-sklearn \
  --i-classifier taxonomy/Classifier.qza \
  --i-reads core/RarRepSeq.qza \
  --o-classification taxonomy/taxonomy_reads-per-batch_RarRepSeq.qza

# Switch to https://chmi-sops.github.io/mydoc_qiime2.html#step-9-assign-taxonomy
# --p-reads-per-batch 0 (default)

qiime metadata tabulate \
  --m-input-file taxonomy/taxonomy_reads-per-batch_RarRepSeq.qza \
  --o-visualization taxonomy/taxonomy_reads-per-batch_RarRepSeq.qzv

qiime metadata tabulate \
  --m-input-file taxonomy/taxonomy_reads-per-batch_ConRepSeq.qza \
  --o-visualization taxonomy/taxonomy_reads-per-batch_ConRepSeq.qzv
  
qiime metadata tabulate \
  --m-input-file taxonomy/taxonomy_reads-per-batch_RepSeq.qza \
  --o-visualization taxonomy/taxonomy_reads-per-batch_RepSeq.qzv  


# Now create a visualization of the classified sequences.
  
qiime taxa barplot \
  --i-table core/Table.qza \
  --i-taxonomy taxonomy/taxonomy_reads-per-batch_RepSeq.qza \
  --m-metadata-file $METADATA_ITS/sample-metadata.tsv \
  --o-visualization taxonomy/taxa-bar-plots_reads-per-batch_RepSeq.qzv

qiime taxa barplot \
  --i-table core/ConTable.qza \
  --i-taxonomy taxonomy/taxonomy_reads-per-batch_ConRepSeq.qza \
  --m-metadata-file $METADATA_ITS/sample-metadata.tsv \
  --o-visualization taxonomy/taxa-bar-plots_reads-per-batch_ConRepSeq.qzv
  
qiime taxa barplot \
  --i-table core/RarTable.qza \
  --i-taxonomy taxonomy/taxonomy_reads-per-batch_RarRepSeq.qza \
  --m-metadata-file $METADATA_ITS/sample-metadata.tsv \
  --o-visualization taxonomy/taxa-bar-plots_reads-per-batch_RarRepSeq.qzv  

qiime tools export --input-path taxonomy/Classifier.qza --output-path export/taxonomy/Classifier
qiime tools export --input-path taxonomy/RefSeq.qza --output-path export/taxonomy/RefSeq
qiime tools export --input-path taxonomy/DataSeq.qza --output-path export/taxonomy/DataSeq
qiime tools export --input-path taxonomy/RefTaxo.qza --output-path export/taxonomy/RefTaxo
  
qiime tools export --input-path taxonomy/taxa-bar-plots_reads-per-batch_RarRepSeq.qzv --output-path export/taxonomy/taxa-bar-plots_reads-per-batch_RarRepSeq
qiime tools export --input-path taxonomy/taxa-bar-plots_reads-per-batch_ConRepSeq.qzv --output-path export/taxonomy/taxa-bar-plots_reads-per-batch_ConRepSeq
qiime tools export --input-path taxonomy/taxa-bar-plots_reads-per-batch_RepSeq.qzv --output-path export/taxonomy/taxa-bar-plots_reads-per-batch_RepSeq

qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RepSeq.qzv --output-path export/taxonomy/taxonomy_reads-per-batch_RepSeq_visual
qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_ConRepSeq.qzv --output-path export/taxonomy/taxonomy_reads-per-batch_ConRepSeq_visual
qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RarRepSeq.qzv --output-path export/taxonomy/taxonomy_reads-per-batch_RarRepSeq_visual

qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RepSeq.qza --output-path export/taxonomy/taxonomy_reads-per-batch_RepSeq
qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_ConRepSeq.qza --output-path export/taxonomy/taxonomy_reads-per-batch_ConRepSeq
qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RarRepSeq.qza --output-path export/taxonomy/taxonomy_reads-per-batch_RarRepSeq

  

###############################################################
### For Bacteria
###############################################################

cd $DATADIRECTORY_16S

eval "$(conda shell.bash hook)"
conda activate qiime2-2021.4

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p taxonomy
mkdir -p export/taxonomy

# I'm doing this step in order to deal the no space left in cluster :
export TMPDIR='/scratch_vol1/fungi'
echo $TMPDIR

echo '##############################################################################################################################'
echo '### Bacteria ###'
echo '##############################################################################################################################'

###### All this step was for "old" database, now we uysed new ones 
######
######
######
######qiime tools import --type 'FeatureData[Taxonomy]' \
######  --input-format HeaderlessTSVTaxonomyFormat \
######  --input-path /Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/07_Rhabdastrella_globostellata_microbiome/Rhabdastrella_globostellata_microbiome/98_database_files/silva_nr99_v138_wSpecies_train_set.fa \
######  --output-path taxonomy/RefTaxo.qza
######
######qiime tools import --type 'FeatureData[Sequence]' \
######  --input-path /Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/07_Rhabdastrella_globostellata_microbiome/Rhabdastrella_globostellata_microbiome/98_database_files/silva_nr99_v138_wSpecies_train_set.fa \
######  --output-path taxonomy/DataSeq.qza
######
######   
####### Aim: Extract sequencing-like reads from a reference database.
####### Warning: For 16S only !!! Not for ITS !!! 
######
####### The --p-trunc-len parameter should only be used to trim reference sequences,
####### if query sequences are trimmed to this same length or shorter.
###### 
####### Paired sequences that successfully join will typically be variable in length.
####### Single reads not truncated at a specific length may also be variable in length.
######
####### For classification of paired-end reads and untrimmed single-end reads,
####### we recommend training a classifier on sequences that have been extracted
####### at the appropriate primer sites, but are not trimmed !!!
####### -----
####### The primer sequences used for extracting reads should be the actual DNA-binding
####### (i.e., biological) sequence contained within a primer construct.
######
####### It should NOT contain any non-biological, non-binding sequence,
####### e.g., adapter, linker, or barcode sequences.
######
####### If you aren't sure what section of your primer sequences are actual DNA-binding
####### you should consult whoever constructed your sequencing library, your sequencing
####### center, or the original source literature on these primers.
######
####### If your primer sequences are > 30 nt long, they most likely contain some
####### non-biological sequence !
######
######qiime feature-classifier extract-reads --i-sequences taxonomy/DataSeq.qza \
######        --p-f-primer 'GTGCCAGCMGCCGCGGTAA' \
######        --p-r-primer 'TCCTCCGCTTATTGATATGC' \
######        --o-reads taxonomy/RefSeq.qza 
######        
######        #--p-trunc-len {params.length} \
######
####### Aim: Create a scikit-learn naive_bayes classifier for reads
######
######qiime feature-classifier fit-classifier-naive-bayes \
######  --i-reference-reads taxonomy/RefSeq.qza \
######  --i-reference-taxonomy taxonomy/RefTaxo.qza \
######  --o-classifier taxonomy/Classifier.qza

# With new database :

# See here for only 16S : https://www.dropbox.com/sh/nz7c5asn6b3hr1j/AADMAR-YZOBkpUQJLumZ9w3wa/ver_0.02?dl=0&subfolder_nav_tracking=1
# See here for all 16S : https://www.dropbox.com/sh/ibpy9j0clw8dzwm/AAAIVuYnqUzAOxlg2fijePQna/ver_0.02?dl=0&subfolder_nav_tracking=1

# See this thread https://forum.qiime2.org/t/silva-138-classifiers/13131 (found because of this thread : https://forum.qiime2.org/t/silva-138-for-qiime2/12957/4)

#cp $METADATA_16S/SILVA-138-SSURef-full-length-classifier.qza taxonomy/Classifier.qza

###cp $METADATA_16S/SILVA-138-SSURef-Full-Seqs.qza taxonomy/DataSeq.qza
###cp $METADATA_16S/Silva-v138-full-length-seq-taxonomy.qza taxonomy/RefTaxo.qza

cp /scratch_vol1/fungi/Diversity_in_Mare_yam_crop/98_database_files/V4/SILVA-138-SSURef-Full-Seqs.qza taxonomy/DataSeq.qza
cp /scratch_vol1/fungi/Diversity_in_Mare_yam_crop/98_database_files/V4/Silva-v138-full-length-seq-taxonomy.qza taxonomy/RefTaxo.qza

# Here only for 16S --> forward: 'GTGCCAGCMGCCGCGGTAA'  # 515f & reverse: 'GGACTACHVGGGTWTCTAAT' # 806r
#qiime feature-classifier extract-reads --i-sequences taxonomy/DataSeq.qza \
#        --p-f-primer 'GTGCCAGCMGCCGCGGTAA' \
#        --p-r-primer 'TCCTCCGCTTATTGATATGC' \
#        --o-reads taxonomy/RefSeq.qza 

## Here for V1V2V316S --> forward 515f & reverse 806r
#qiime feature-classifier extract-reads --i-sequences taxonomy/DataSeq.qza \
#        --p-f-primer 'GTGCCAGCMGCCGCGGTAA' \
#        --p-r-primer 'TCCTCCGCTTATTGATATGC' \
#        --o-reads taxonomy/RefSeq.qza         



# https://www.researchgate.net/post/What_are_the_best_primers_for_16S_rRNA_sequencing_for_identification_of_soil_bacteria_isolates
# Here for whole 16S
# 27F (5'-AGA GTT TGA TYM TGG CTC AG-3'), 515R (5'-TTA CCG CGG CKG CTG GCA C-3')

#qiime feature-classifier extract-reads --i-sequences taxonomy/DataSeq.qza \
#        --p-f-primer 'AGAGTTTGATYMTGGCTCAG' \
#        --p-r-primer 'TTACCGCGGCKGCTGGCAC' \
#        --o-reads taxonomy/RefSeq.qza     

# BIOINDIC primers
qiime feature-classifier extract-reads --i-sequences taxonomy/DataSeq.qza \
        --p-f-primer 'GTGCCAGCMGCCGCGGTAA' \
        --p-r-primer 'GGACTACHVGGGTWTCTAAT' \
        --o-reads taxonomy/RefSeq.qza             
        


# Aim: Create a scikit-learn naive_bayes classifier for reads

qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads taxonomy/RefSeq.qza \
  --i-reference-taxonomy taxonomy/RefTaxo.qza \
  --o-classifier taxonomy/Classifier.qza
  
# Aim: Create a scikit-learn naive_bayes classifier for reads

qiime feature-classifier classify-sklearn \
   --i-classifier taxonomy/Classifier.qza \
   --i-reads core/ConRepSeq.qza \
   --o-classification taxonomy/taxonomy_reads-per-batch_ConRepSeq.qza
   
qiime feature-classifier classify-sklearn \
  --i-classifier taxonomy/Classifier.qza \
  --i-reads core/RepSeq.qza \
  --o-classification taxonomy/taxonomy_reads-per-batch_RepSeq.qza

qiime feature-classifier classify-sklearn \
  --i-classifier taxonomy/Classifier.qza \
  --i-reads core/RarRepSeq.qza \
  --o-classification taxonomy/taxonomy_reads-per-batch_RarRepSeq.qza

# Switch to https://chmi-sops.github.io/mydoc_qiime2.html#step-9-assign-taxonomy
# --p-reads-per-batch 0 (default)

qiime metadata tabulate \
  --m-input-file taxonomy/taxonomy_reads-per-batch_RarRepSeq.qza \
  --o-visualization taxonomy/taxonomy_reads-per-batch_RarRepSeq.qzv

qiime metadata tabulate \
  --m-input-file taxonomy/taxonomy_reads-per-batch_ConRepSeq.qza \
  --o-visualization taxonomy/taxonomy_reads-per-batch_ConRepSeq.qzv
  
qiime metadata tabulate \
  --m-input-file taxonomy/taxonomy_reads-per-batch_RepSeq.qza \
  --o-visualization taxonomy/taxonomy_reads-per-batch_RepSeq.qzv  

# Now create a visualization of the classified sequences.
  
qiime taxa barplot \
  --i-table core/Table.qza \
  --i-taxonomy taxonomy/taxonomy_reads-per-batch_RepSeq.qza \
  --m-metadata-file $METADATA_16S/sample-metadata.tsv \
  --o-visualization taxonomy/taxa-bar-plots_reads-per-batch_RepSeq.qzv

qiime taxa barplot \
  --i-table core/ConTable.qza \
  --i-taxonomy taxonomy/taxonomy_reads-per-batch_ConRepSeq.qza \
  --m-metadata-file $METADATA_16S/sample-metadata.tsv \
  --o-visualization taxonomy/taxa-bar-plots_reads-per-batch_ConRepSeq.qzv
  
qiime taxa barplot \
  --i-table core/RarTable.qza \
  --i-taxonomy taxonomy/taxonomy_reads-per-batch_RarRepSeq.qza \
  --m-metadata-file $METADATA_16S/sample-metadata.tsv \
  --o-visualization taxonomy/taxa-bar-plots_reads-per-batch_RarRepSeq.qzv  

qiime tools export --input-path taxonomy/Classifier.qza --output-path export/taxonomy/Classifier
qiime tools export --input-path taxonomy/RefSeq.qza --output-path export/taxonomy/RefSeq
qiime tools export --input-path taxonomy/DataSeq.qza --output-path export/taxonomy/DataSeq
qiime tools export --input-path taxonomy/RefTaxo.qza --output-path export/taxonomy/RefTaxo
  
qiime tools export --input-path taxonomy/taxa-bar-plots_reads-per-batch_RarRepSeq.qzv --output-path export/taxonomy/taxa-bar-plots_reads-per-batch_RarRepSeq
qiime tools export --input-path taxonomy/taxa-bar-plots_reads-per-batch_ConRepSeq.qzv --output-path export/taxonomy/taxa-bar-plots_reads-per-batch_ConRepSeq
qiime tools export --input-path taxonomy/taxa-bar-plots_reads-per-batch_RepSeq.qzv --output-path export/taxonomy/taxa-bar-plots_reads-per-batch_RepSeq

qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RepSeq.qzv --output-path export/taxonomy/taxonomy_reads-per-batch_RepSeq_visual
qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_ConRepSeq.qzv --output-path export/taxonomy/taxonomy_reads-per-batch_ConRepSeq_visual
qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RarRepSeq.qzv --output-path export/taxonomy/taxonomy_reads-per-batch_RarRepSeq_visual

qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RepSeq.qza --output-path export/taxonomy/taxonomy_reads-per-batch_RepSeq
qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_ConRepSeq.qza --output-path export/taxonomy/taxonomy_reads-per-batch_ConRepSeq
qiime tools export --input-path taxonomy/taxonomy_reads-per-batch_RarRepSeq.qza --output-path export/taxonomy/taxonomy_reads-per-batch_RarRepSeq
