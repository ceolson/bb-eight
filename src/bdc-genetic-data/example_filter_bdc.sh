# open terminal session in sb.biodatacatalyst

#bcftools view -R ../../workspace/regions.tsv  \
#  NWD998698.freeze5.v1.vcf.gz \
#  | grep "^[^#;]" > ../../workspace/NWD998698_reduced.vcf

# ex.: get one site from one individual:
bcftools view -r chr11:47332517 ../project-files/JHS/NWD100014.freeze5.v1.vcf.gz | grep "^[^#;]"

# ex.: get all sites for one individual:
bcftools view -R regions_grch38.tsv ../project-files/JHS/NWD100014.freeze5.v1.vcf.gz | grep "^[^#;]" > NWD100014.vcf

# coordinates are GChr38 for TopMed Freeze 5
