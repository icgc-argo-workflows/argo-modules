#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREP_METRICS } from '../../../../../modules/icgc-argo-workflows/prep/metrics/main.nf'

// Test with Submitted Reads (bam) in rdpc-qa
workflow test_prep_metrics_prealn {
    input_channel = Channel.of([id:'SA624380']).combine(Channel.fromPath(params.multiqc))
    qc_files_channel = Channel.fromPath(params.qc_files).toList()

    PREP_METRICS ( input_channel, qc_files_channel)
}

// Test with Submitted Reads (fastq) in rdpc-qa
workflow test_prep_metrics_dnaalnqc {
    input_channel = Channel.of([id:'SA622743']).combine(Channel.fromPath(params.multiqc))
    qc_files_channel = Channel.fromPath(params.qc_files).toList()

    PREP_METRICS ( input_channel, qc_files_channel)
}

// 
workflow test_prep_metrics_rnaalnqc {
    input_channel = Channel.of([id: 'SA622799']).combine(Channel.fromPath(params.multiqc))

    PREP_METRICS ( input_channel, [])
}