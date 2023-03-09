#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { STAGE_INPUT } from '../../../../subworkflows/icgc-argo-workflows/stage_input/main.nf'

workflow test_stage_input_rdpcqa {
    
    input_channel = [
      params.test_data['rdpc_qa']['study_id_stage'],
      params.test_data['rdpc_qa']['analysis_id_stage']
    ]

    STAGE_INPUT ( input_channel )
}

workflow test_stage_input_user {
    
    input_channel = [
      params.study_id,
      params.analysis_id
    ]

    STAGE_INPUT ( input_channel )
}