#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SAMPLESHEET_CHECK } from '../../../../modules/icgc-argo-workflows/checkinput/main.nf'

workflow test_check_input {
    SAMPLESHEET_CHECK(file(params.input),workflow.Manifest.name)
}

    