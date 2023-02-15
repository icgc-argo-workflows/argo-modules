#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SCORE_DOWNLOAD } from '../../../../../modules/icgc-argo-workflows/score/download/main.nf'

// Test with data in rdpc-qa
workflow test_score_download_rdpcqa {
    
    study_id = params.test_data['rdpc_qa']['study_id']
    analysis_id = params.test_data['rdpc_qa']['analysis_id']
    analysis = file(params.test_data['rdpc_qa']['analysis'])

    SCORE_DOWNLOAD ( analysis, study_id, analysis_id )
}

// Test with user provide data
workflow test_score_download_user {
    
    study_id = params.study_id
    analysis_id = params.analysis_id
    analysis = file(params.analysis)

    SCORE_DOWNLOAD ( analysis, study_id, analysis_id )
}