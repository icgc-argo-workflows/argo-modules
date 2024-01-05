#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { STAGE_INPUT } from '../../../../subworkflows/icgc-argo-workflows/stage_input/main.nf'

workflow test_stage_input_rdpcqa {
    
    input_channel = [
      params.test_data['rdpc_qa']['study_id_stage'],
      params.test_data['rdpc_qa']['analysis_id_stage']
    ]

    samplesheet_workflow = [null,null]

    STAGE_INPUT (input_channel,samplesheet_workflow)
}

workflow test_stage_input_local {
    
    input_channel = [null,null]

    STAGE_INPUT (input_channel,params.input)
}