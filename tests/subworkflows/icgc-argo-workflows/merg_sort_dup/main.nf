#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { MERG_SORT_DUP } from '../../../../subworkflows/icgc-argo-workflows/merg_sort_dup/main.nf'

workflow test_merg_sort_dup_rdpcqa {
    input_channel = [
        params.test_data['rdpc_qa']['study_id'],
        analysis_id = params.test_data['rdpc_qa']['analysis_id']
    ]

    MERG_SORT_DUP ( input_channel )
    }

workflow test_merg_sort_dup_local {
    input_channel = [
        params.study_id, params.analysis_id
    ]

    MERG_SORT_DUP ( input_channel)
}