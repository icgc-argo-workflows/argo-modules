#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { STAGE_INPUT } from '../../../../subworkflows/icgc-argo-workflows/stage_input/main.nf'

workflow test_stage_input_rdpcqa {
    println("hello")
    STAGE_INPUT (
      params.test_data['rdpc_qa']['study_id_stage'],
      params.test_data['rdpc_qa']['analysis_id_stage'],
      null)
    
    STAGE_INPUT.out.meta_analysis.subscribe{println "analysis : ${it}"}
    STAGE_INPUT.out.meta_files.subscribe{println "files : ${it}"}
}

workflow test_stage_input_local {
    STAGE_INPUT (null,null,params.input)

    STAGE_INPUT.out.meta_analysis.subscribe{println "analysis : ${it}"}
    STAGE_INPUT.out.meta_files.subscribe{println "files : ${it}"}
}