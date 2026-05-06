########################################
child="$1" # Sample ID of the child
father="$2" # Sample ID of the father
mother="$3" # Sample ID of the mother
CASE="$4" # Name assigned to the trio analysis
PATRON="$5" # Inheritance filter (pattern used by bcftools)

child="$1"
father="$2"
mother="$3"
CASE="$4"
PATRON="$5"

# Dynamically create MultiQC config to group paired-end reads and rename IDs to family roles (child/father/mother)
mkdir -p QC_reports_"${CASE}"
mkdir -p VCF_results_"${CASE}"

cat > multiqc_config.yaml <<EOF
table_sample_merge:
  "R1": ".targets_R1"
  "R2": ".targets_R2"

sample_names_replace_exact: true
sample_names_replace:
  "child": "${child}"
  "father": "${father}"
  "mother": "${mother}"
EOF

mkdir -p QC_reports_"${CASE}" 
# This creates a folder named "QC_reports_case1_def1" where the multiqc report will be saved.
mkdir -p VCF_results_"${CASE}" 
# This creates a folder named "VCF_results_case1_def1" where the VCFs will be saved.

# Loop that iterates through each family member. For each one, the script runs several commands: bowtie2, samtools and qualimap.
for fam in child father mother 
do
i="${!fam}" 
# This line is essential for the correct input and labeling in the bowtie2 command. 

# Instead of using the literal string stored in fam (ex: child), it retrives the value of the corresponding value, that is, in the example case, the identifier of the child (HG00448).
fastqc "${i}.targets_R1.fq.gz" "${i}.targets_R2.fq.gz"

bowtie2 -1 "${i}.targets_R1.fq.gz" -2 "${i}.targets_R2.fq.gz" -x chr20  --rg-id "${i}" --rg "SM:${fam}" | samtools view -Sb | samtools sort -o "${fam}.bam" 

samtools index "${fam}.bam" 
 
qualimap bamqc -bam "${fam}.bam" --feature-file chr20_ILMN_Exome_2.0_Plus_Panel.hg38_padded.bed  --outdir QC_reports_"${CASE}"/"${fam}" 
# Then, the report is stored in a subfolder with the fam variable as name (child) in the "QC_reports_case1_def1" folder

done #The loop ends here.

# MultiQC report generation. 
multiqc . -c multiqc_config.yaml -o QC_reports_"${CASE}" -f
#mutliqc: '.' scans current folder, '-c' applies YAML grouping rules, '-o' sets output folder, '-f' overwrites old reports

#From here, all the files (.bam, .cand.vcf, .vcf, .vcf.gz) are stored in the "VCF_results_case1_def1" folder.

#We run freebayes with the following parameters:
# -m = --min-mapping-quality > 20 (It excludes from the analysis alignments with a mapping quality < 20)
# -C = --min-alternate-count > 5 (For an alternate alelle to be considered, it need at least 5 reads in an individual)
#-Q = --mismatch-base-quality-threshold =>10 (It sets the minimum base quality required for a mismatch to be taken into account; mismatches supported by bases with quality < 10 are ignored))
#-q = --min-base-quality > 10 (It excludes from the analysis variants that have bases with quality lower than 10)

freebayes -f chr20.fa -m 20 -C 5 -Q 10 -q 10 --min-coverage 10 child.bam father.bam mother.bam > VCF_results_"${CASE}"/"${CASE}".vcf

bgzip VCF_results_"${CASE}"/"${CASE}".vcf

bcftools index VCF_results_"${CASE}"/"${CASE}".vcf.gz

#'QUAL>20' keeps only variants with a QUAL score greater than 20.

bcftools view -R chr20_ILMN_Exome_2.0_Plus_Panel.hg38_padded.bed VCF_results_"${CASE}"/"${CASE}".vcf.gz | bcftools view -S samples.txt | bcftools view -i "${PATRON}" | bcftools filter -i 'QUAL>20' -Ov -o VCF_results_"${CASE}"/"${CASE}".cand.vcf


