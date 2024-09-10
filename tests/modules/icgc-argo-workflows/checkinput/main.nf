#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { CHECKINPUT } from '../../../../modules/icgc-argo-workflows/checkinput/main.nf'

workflow test_check_input {
    CHECKINPUT(file(params.input),workflow.Manifest.name)
}

    