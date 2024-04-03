#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { MERG_SORT_DUP } from '../../../../subworkflows/icgc-argo-workflows/merg_sort_dup/main.nf'

workflow test_merg_sort_dup_rdpcqa {
    MERG_SORT_DUP (
        params.test_data['rdpc_qa']['study_id_stage'],
        params.test_data['rdpc_qa']['analysis_id_stage'],
        null)
    
    MERG_SORT_DUP.out.meta_analysis.subscribe{println "analysis : ${it}"}
    MERG_SORT_DUP.out.meta_files.subscribe{println "files : ${it}"}
}

workflow test_merg_sort_dup_local {
    MERG_SORT_DUP (null,null,params.input)

    MERG_SORT_DUP.out.meta_analysis.subscribe{println "analysis : ${it}"}
    MERG_SORT_DUP.out.meta_files.subscribe{println "files : ${it}"}
}