#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PAYLOAD_ALIGNMENT } from '../../../../../modules/icgc-argo-workflows/payload/alignment/main.nf'

workflow test_payload_alignment {
    
    analysis_channel = Channel.of(file(params.analysis))
    files_channel = Channel.fromPath(params.aln_files).toList()
    analysis_channel.combine(files_channel.toList())
    .map { analysis, files ->
    [[id: 'test', read_groups_count:'2'], files, analysis]}
    .set{ input_channel }
    genome_build = params.genome_build ?: []
    genome_annotation = params.genome_annotation ?: []

    PAYLOAD_ALIGNMENT ( input_channel, file(params.pipeline_yml), genome_build, genome_annotation)
}

