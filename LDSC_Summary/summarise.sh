
#for set in dmrs.Con dmrs.KO dmrs.M dmrs.F 
#do
    for i in results/sumstats_formatted_PASS_*txt
    do
    
    j=$(basename $i .cell_type_results.txt)
    awk -v j=$j -v s=$set 'NR!=1{print $0"\t"j"\t"s}' $i >> res.summary.txt
    
    done
#done
