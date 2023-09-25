#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREP_METRICS } from '../../../../../modules/icgc-argo-workflows/prep/metrics/main.nf'

// Test with Submitted Reads (bam) in rdpc-qa
workflow test_prep_metrics_prealn {
    qc_files_channel = Channel.fromPath(params.qc_files).toList()
    input_channel = Channel.of([id:'SA624380']).combine(qc_files_channel.toList())
    input_channel.view()

    PREP_METRICS ( input_channel, Channel.fromPath(params.multiqc))
}

// Test with Submitted Reads (fastq) in rdpc-qa
workflow test_prep_metrics_dnaalnqc {

    qc_files_channel = Channel.fromPath(params.qc_files).toList()
    input_channel = Channel.of([id:'SA622743']).combine(qc_files_channel.toList())
    input_channel.view()

    PREP_METRICS ( input_channel, Channel.fromPath(params.multiqc))
}
