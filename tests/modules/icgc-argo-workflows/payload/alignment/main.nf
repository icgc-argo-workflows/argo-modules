#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PAYLOAD_QCMETRICS } from '../../../../../modules/icgc-argo-workflows/payload/alignment/main.nf'

workflow test_payload_alignment_dna {
    
    analysis_channel = Channel.of(file(params.analysis))
    files_channel = Channel.fromPath(params.aln_files).toList()
    analysis_channel.combine(files_channel.toList())
    .map { analysis, files ->
    [[id:'test'], files, analysis]}
    .set{ input_channel }

    PAYLOAD_QCMETRICS ( input_channel, file(params.pipeline_yml))
}

    