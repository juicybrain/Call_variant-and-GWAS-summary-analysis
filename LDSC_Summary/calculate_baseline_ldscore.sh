
for i in {1..22} 

do


        python ~/git/ldsc/ldsc/ldsc.py \
        --l2 \
        --bfile g1000_eur_chr/g1000_eur_chr${i} \
        --ld-wind-kb 0.1 \
        --out g1000_eur_chr/g1000_eur_chr${i}\.ldscore

done

