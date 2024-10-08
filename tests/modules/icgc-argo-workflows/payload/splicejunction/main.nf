#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PAYLOAD_SPLICE_JUNCTION } from '../../../../../modules/icgc-argo-workflows/payload/splicejunction/main.nf'

workflow test_payload_splice_junction {
    
    analysis_channel = Channel.of(file(params.analysis))
    files_channel = Channel.fromPath(params.file_to_upload)
    analysis_channel.combine(files_channel)
    .map { analysis, files ->
    [[id: 'test', genome_build: "${params.genome_build}", genome_annotation: "${params.genome_annotation}"], files, analysis]}
    .set{ input_channel }

    PAYLOAD_SPLICE_JUNCTION ( input_channel, file(params.pipeline_yml))
}

    
