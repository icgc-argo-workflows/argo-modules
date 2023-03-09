#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PAYLOAD_QCMETRICS } from '../../../../../modules/icgc-argo-workflows/payload/qcmetrics/main.nf'

workflow test_payload_qcmetrics {
    
    analysis_channel = Channel.of(file(params.test_data['rdpc_qa']['seq_exp_analysis']))
    files_channel = Channel.fromPath(params.test_data['rdpc_qa']['qc_file']).toList()
    analysis_channel.combine(files_channel.toList())
    .map { analysis, files ->
    [[id:'test'], files, analysis]}
    .set{ input_channel }

    PAYLOAD_QCMETRICS ( input_channel, '', '', 'test', '0.1.0')
}

    