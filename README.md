# Mendelian-Rare-Disease-Pipeline-paired-end
An end-to-end bioinformatics pipeline for diagnosing rare Mendelian diseases, adapted for paired-end sequencing data. It involces quality control, variant calling, and family-based (Trio) prioritization.

## Workflow 
1.Mapping & QC  
2.Variant Calling  
3.Variant Prioritization: Family-based filtering using specific inheritance models (De Novo, AR, AD).  

## Visual Validation[optional]: 
Additional quality checks on prioritized reads using platforms like IGV (Integrative Genomics Viewer) or the UCSC Genome Browser. (Instructions for this step are in the coverage/ folder).

## Prerequisites
To use this analysis scheme and the automated scripts, the following materials are required:  
1.Trio Case Data: Paired-end FASTQ reads for every family member (Child, Father, Mother).  
2.Sample Order File: A .txt file defining the family members for bcftools. Crucial: The order in this file must match the order used in the command structure below.  
3.Targeted Regions: A .bed file containing the specific regions of interest.  
4.Reference Files: Chromosome reference sequences and corresponding Bowtie2 indices.  

## How to use the automated script
To run the automated pipeline, use the following command structure:  
```bash
./(name of the script) [SampleID_Child] [SampleID_Father] [SampleID_Mother] [TrioName] '[Inheritance_Filter]'
```
```py
#Inheritance_Filter: the order of genotypes in the string ($[0]$, $[1]$, $[2]$) must match the order of samples in your .txt file
#Example[from our analysis]
./pipeline_paired_end.sh HG00448 HG00449 HG00450 Trio_1 ’GT[0]="AA" && GT[1]="RA" && GT[2]="RA"’
```
## Folder structure
The VCF and MultiQC result folders contain subfolders corresponding to the cases assigned during the project:
SR — cases assigned to Saida Rozmetova,
IS — cases assigned to Ignacio Sanjuan
