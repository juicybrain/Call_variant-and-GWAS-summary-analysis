######## prepare annotation files
gs=/projects/ps-renlab/yangli/genome/mm10/mm10.chrom.sizes
plink=./g1000_eur_chr

function loadavg {
    while [ `cat /proc/loadavg | awk '{print int($1)}'` -gt 50 ]; do sleep 120; date; done;
 }


for i in data/dmr*bed.hg19.bed
do
  k=$(basename $i .CREs.reciprocalToHg19.bed)
  echo $k
  for j in {1..22}
    do
    python ~/git_repository/ldsc/make_annot.py --bed-file $i --bimfile $plink/g1000_eur_chr$j.bim --annot-file ld_score/${k}.$j.annot.gz &
    sleep 3
    loadavg
  done
done

####### calculate ldsc scores

#!/bin/bash
DIR="./"
resources="./resource"

for i in $(ls ld_score/rs1cemba.*22.annot.gz | sed 's/.22.annot.gz//g')
    do
    j=$(basename $i)
    script_file="bash_script/$j.sh"
    cat > script_file.2.sh <<EOF
#!/bin/bash

cd $DIR
for i in {1..22}
do
    python ~/git/ldsc/ldsc/ldsc.py  --l2  --bfile  g1000_eur_chr/g1000_eur_chr\$i   --ld-wind-kb 1\\
                                    --annot ld_score/$j.\$i.annot.gz\\
                                    --thin-annot\\
                                    --out ld_score/$j.\$i\\
                                    --print-snps ./hapmap3_snps/hm.\$i.snp  --yes-really
                                    done
EOF

chmod +x script_file.2.sh
./script_file.2.sh
wait
done
######## run ldsc_test


#        mkdir results

 ls data/dmr*.bed | grep -v "rs1cemba"  | while read i
         do
             j=$(basename $i)
                 printf "${j}\tld_score/${j}.,ld_score/rs1cemba.\n"
        done > rs1cemba.ldcts

        cts_name=rs1cemba
        sumstats=trait_new

        for name in $(ls $sumstats | grep -v test)
        do
        i=$(basename $name .sumstats.gz)

        # We don't need a separate script file now, so we can execute the commands directly
        python ~/git/ldsc/ldsc/ldsc.py --h2-cts ${sumstats}/${name} --ref-ld-chr g1000_eur_chr/g1000_eur.  --out results/${name}\.dmr  --ref-ld-chr-cts rs1cemba.ldcts --w-ld-chr ./weights_hm3_no_hla/weights.

#        python ~/git/ldsc/ldsc/ldsc.py \
#                    --h2-cts $sumstats/$i.sumstats.gz \
#                    --ref-ld-chr ./1000G_EUR_Phase3_baseline/baseline. \
#                    --out results/${i}.$cts_name \
#                    --ref-ld-chr-cts $cts_name.ldcts \
#                    --w-ld-chr  ./weights_hm3_no_hla/weights.
        done
