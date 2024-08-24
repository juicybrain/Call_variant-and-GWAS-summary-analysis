# alignment

# prepare dict
java -jar /home/yli/ref/picard/picard.jar  CreateSequenceDictionary     R=/home/yli/ref/genome/hgT2T/hgT2T.fa   O=/home/yli/ref/genome/hgT2T/hgT2T.dict


for spl in  ...
do

#    bwa mem -t 8  ~/ref/genome/mm10/mm10.fa  ${spl}\.R1.fq.gz ${spl}\.R2.fq.gz > ${spl}\.aligned.sam

#    wait
#    samtools view -bS  ${spl}\.aligned.sam  > ${spl}\.aligned.bam
#    samtools sort  ${spl}\.aligned.bam  -o  ${spl}\.aligned.s.bam
#    samtools index ${spl}\.aligned.s.bam ${spl}\.aligned.s.bam.bai

    #picard
    /home/yli/src/JDK/jdk-22.0.1/bin/java -jar /home/yli/ref/picard/picard.jar MarkDuplicates I=${spl}\.aligned.s.bam   O=${spl}\.aligned.s.u.bam    M=dedup_metrics.txt     REMOVE_DUPLICATES=true


    # fix the read groups

    barcode=`zcat ${spl}\.R1.fq.gz | head -n 1|awk -v FS=":" '{print $10}'`

    java -jar /home/yli/ref/picard/picard.jar  AddOrReplaceReadGroups I=${spl}\.aligned.s.u.bam  O=${spl}\.aligned.s.u.rg.bam SORT_ORDER=coordinate RGID=foo RGLB=bar   RGPL=illumina RGSM=${spl}  CREATE_INDEX=True RGPU=${barcode}

    # germline SNP
    /home/yli/src/GATK/gatk-4.5.0.0/gatk --java-options "-Xmx4G" HaplotypeCaller         -R  /home/yli/ref/genome/mm10/mm10.fa  -I  ${spl}\.aligned.s.u.rg.bam  -O ${spl}\.raw_variants.vcf


    # somatic SNP
    # gatk --java-options "-Xmx4G" Mutect2         -R ~/ref/genome/mm10/mm10.fa   -I ${spl}\.aligned.s.u.bam -normal normal.bam       -O somatic_variants.vcf

done


### VCF to frequency
for spl in `ls *vcf`; do cat ${spl} |   grep -v \# | awk -v OFS="\t" '{print $1,$2-1,$2,1}' |sort -k1,1 -k2,2n > SNP_per10K/${spl}\.bed& done
for spl in `ls *vcf.bed`; do bedtools map -a ~/ref/bed/mm10.10k.window.bed -b ${spl} -c 4 -o sum | grep -v "\." >  ${spl}\graph; done

### get the SNP types
for spl in `ls *vcf`; do cat ${spl} | grep -v \# | awk -v OFS="\t" '{print $4"_"$5}' | sort | uniq -c | sort -nrk1,1 > ${spl}.res & done






