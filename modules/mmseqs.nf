/************************************************************************
* MMSEQS
*
* Use MMSEQs easy-linclust to cluster the input data
************************************************************************/

process mmseqs{
  label 'mmseqs'
  publishDir "${params.output}/${params.mmseqs_output}", mode: 'copy', pattern: "*_mmseqs*"
  publishDir "${params.output}/${params.mmseqs_output}", mode: 'copy', pattern: "*UNCLUSTERED*"
  publishDir "${params.output}/${params.summary_output}/unclustered_sequences", mode: 'copy', pattern: '*UNCLUSTERED.fasta'
  publishDir "${params.output}/${params.summary_output}/clustered_sequences", mode: 'copy', pattern: '*_mmseqs.fasta'

  input:
    path(sequences)
    val(addParams)

  output:
    tuple val("${params.output}/${params.mmseqs_output}"), path("${sequences.baseName}_mmseqs.fasta"), emit: mmseqs_result
    path "${sequences.baseName}_mmseqs.fasta.clstr", emit: mmseqs_cluster
    path "${sequences.baseName}_mmseqs_UNCLUSTERED.fasta"

  script:
  """
    mmseqs easy-linclust "${sequences}" "${sequences.baseName}_mmseqs" tmp
    mv ${sequences.baseName}_mmseqs_rep_seq.fasta ${sequences.baseName}_mmseqs.fasta

    python3 ${projectDir}/bin/mmseqs2cdhit.py ${sequences.baseName}_mmseqs_cluster.tsv "${sequences}"
    mv ${sequences.baseName}_mmseqs_cluster.tsv.clstr "${sequences.baseName}_mmseqs.fasta.clstr"
    python3 ${projectDir}/bin/filter_unclustered.py "${sequences.baseName}_mmseqs.fasta" "${sequences.baseName}_mmseqs.fasta.clstr"

  """
}