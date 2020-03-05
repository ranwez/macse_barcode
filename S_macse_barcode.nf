#! usr/bin/env nextflow

params.refAlign="refAlign.fasta"
params.seqToAlign="allSeq.fasta"
params.gc="2"


Channel
    .fromPath( params.seqToAlign )
    .splitFasta( by: 10, file:true)
    .set {fasta_split }

process enrichNoIns {
    input:
      file seqF from fasta_split
      file 'refAlignFile' from file(params.refAlign)
    output:
      file "${seqF.baseName}_NT.aln" into splitEnrich
      //stdout result

      """
      #echo $seqF ${params.refAlign} ${params.gc}
      java -jar /homedir/ranwez/MACSE_BARCODE/macse_v2.03.jar -prog enrichAlignment -align $refAlignFile -gc_def ${params.gc} -seq $refAlignFile -seq_lr $seqF -fixed_alignment_ON -new_seq_alterable_ON -fs_lr 10 -stop_lr 10 -maxFS_inSeq 2 -maxINS_inSeq 0 -maxSTOP_inSeq 1 -out_NT ${seqF.baseName}_NT.aln
      """
}

process mergeNoIns{
   publishDir '/homedir/ranwez/MACSE_BARCODE/NEXTRES/', mode: 'copy', overwrite: false
   input:
     file alignList from splitEnrich.collect()

    """
    echo "" > alignAll.aln
    for alignFile in ${alignList}
    do
        cat \$alignFile >> alignAll.aln
    done
    cp alignAll.aln /homedir/ranwez/MACSE_BARCODE/
    """

}

//result.view { it.trim() }

// nextflow S_macse_barcode.nf --refAlign REF_ALIGN/refAlign_final_mask_align_NT.aln --seqToAlign DATA/Mammalia_BOLD_100seq_COI-5P_2020.fasta
// nextflow S_macse_barcode.nf --refAlign REF_ALIGN/refAlign_final_mask_align_NT.aln --seqToAlign DATA/Mammalia_BOLD_100seq_COI-5P_2020.fasta
