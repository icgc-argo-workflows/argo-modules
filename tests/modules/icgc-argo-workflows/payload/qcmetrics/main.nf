#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PAYLOAD_QCMETRICS } from '../../../../../modules/icgc-argo-workflows/payload/qcmetrics/main.nf'

workflow test_payload_qcmetrics {
    
    analysis_channel = Channel.of(file(params.analysis))
    files_channel = Channel.fromPath(params.qc_files).toList()
    analysis_channel.combine(files_channel.toList()).combine(Channel.fromPath(params.multiqc))
    .map { analysis, files, multiqc ->
    [[id:'test'], analysis, files, multiqc]}
    .set{ input_channel }
    genome_build = params.genome_build ?: []
    genome_annotation = params.genome_annotation ?: []

    PAYLOAD_QCMETRICS ( input_channel, file(params.pipeline_yml), genome_build, genome_annotation)
}

    