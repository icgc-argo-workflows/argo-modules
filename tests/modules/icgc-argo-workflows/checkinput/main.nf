#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SAMPLESHEET_CHECK } from '../../../../modules/icgc-argo-workflows/checkinput/main.nf'

workflow test_check_input {
    

    SAMPLESHEET_CHECK(file(params.input),workflow.Manifest.name)
    // analysis_channel = Channel.of(file(params.analysis))
    // files_channel = Channel.fromPath(params.qc_files).toList()
    // analysis_channel.combine(files_channel.toList()).combine(Channel.fromPath(params.multiqc))
    // .map { analysis, files, multiqc ->
    // [[id:'test'], analysis, files, multiqc]}
    // .set{ input_channel }

    // PAYLOAD_QCMETRICS ( input_channel, file(params.pipeline_yml))
}

    