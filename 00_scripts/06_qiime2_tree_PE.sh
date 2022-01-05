#!/usr/bin/env bash

# pathways in cluster:
DATADIRECTORY_ITS=/scratch_vol1/fungi/Tiebaghi/05_QIIME2/ITS
DATADIRECTORY_16S=/scratch_vol1/fungi/Tiebaghi/05_QIIME2/16S

# pathways in local:
#DATADIRECTORY_ITS=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/05_QIIME2/ITS
#DATADIRECTORY_16S=/Users/pierre-louisstenger/Documents/PostDoc_02_MetaBarcoding_IAC/02_Data/20_Tiebaghi/Tiebaghi/05_QIIME2/16S

# Aim: construct a rooted phylogenetic tree

###############################################################
### For Fungi
###############################################################

cd $DATADIRECTORY_ITS

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p tree
mkdir -p export/tree

eval "$(conda shell.bash hook)"
conda activate qiime2-2021.4

#carry out a multiple seqeunce alignment using Mafft
 qiime alignment mafft \
  --i-sequences core/ConRepSeq.qza \
  --o-alignment tree/aligned-RepSeq.qza

#mask (or filter) the alignment to remove positions that are highly variable. These positions are generally considered to add noise to a resulting phylogenetic tree.
qiime alignment mask \
  --i-alignment tree/aligned-RepSeq.qza \
  --o-masked-alignment tree/masked-aligned-RepSeq.qza

#create the tree using the Fasttree program
qiime phylogeny fasttree \
  --i-alignment tree/masked-aligned-RepSeq.qza \
  --o-tree tree/unrooted-tree.qza

#root the tree using the longest root
qiime phylogeny midpoint-root \
  --i-tree tree/unrooted-tree.qza \
  --o-rooted-tree tree/rooted-tree.qza
  
#export the tree  
qiime tools export \
  --input-path tree/unrooted-tree.qza \
  --output-path $DATADIRECTORY_ITS/tree
  
# This out put is in Newick format, see http://scikit-bio.org/docs/latest/generated/skbio.io.format.newick.html  
# See it on https://itol.embl.de

qiime tools export --input-path tree/unrooted-tree.qza --output-path export/tree/unrooted-tree
qiime tools export --input-path tree/rooted-tree.qza --output-path export/tree/rooted-tree
qiime tools export --input-path tree/aligned-RepSeq.qza --output-path export/tree/aligned-RepSeq
qiime tools export --input-path tree/masked-aligned-RepSeq.qza --output-path export/tree/masked-aligned-RepSeq



###############################################################
### For Bacteria
###############################################################

cd $DATADIRECTORY_16S

# Make the directory (mkdir) only if not existe already(-p)
mkdir -p tree
mkdir -p export/tree

eval "$(conda shell.bash hook)"
conda activate qiime2-2021.4

#carry out a multiple seqeunce alignment using Mafft
 qiime alignment mafft \
  --i-sequences core/ConRepSeq.qza \
  --o-alignment tree/aligned-RepSeq.qza

##mask (or filter) the alignment to remove positions that are highly variable. These positions are generally considered to add noise to a resulting phylogenetic tree.
qiime alignment mask \
  --i-alignment tree/aligned-RepSeq.qza \
  --o-masked-alignment tree/masked-aligned-RepSeq.qza

##create the tree using the Fasttree program
qiime phylogeny fasttree \
  --i-alignment tree/masked-aligned-RepSeq.qza \
  --o-tree tree/unrooted-tree.qza

##root the tree using the longest root
qiime phylogeny midpoint-root \
  --i-tree tree/unrooted-tree.qza \
  --o-rooted-tree tree/rooted-tree.qza
  
  
#export the tree  
qiime tools export \
  --input-path tree/unrooted-tree.qza \
  --output-path $DATADIRECTORY_16S/tree
  
# This out put is in Newick format, see http://scikit-bio.org/docs/latest/generated/skbio.io.format.newick.html  
# See it on https://itol.embl.de


qiime tools export --input-path tree/unrooted-tree.qza --output-path export/tree/unrooted-tree
qiime tools export --input-path tree/rooted-tree.qza --output-path export/tree/rooted-tree
qiime tools export --input-path tree/aligned-RepSeq.qza --output-path export/tree/aligned-RepSeq
qiime tools export --input-path tree/masked-aligned-RepSeq.qza --output-path export/tree/masked-aligned-RepSeq
