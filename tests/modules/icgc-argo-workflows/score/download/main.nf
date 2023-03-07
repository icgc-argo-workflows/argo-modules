#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SCORE_DOWNLOAD } from '../../../../../modules/icgc-argo-workflows/score/download/main.nf'

// Test with data in rdpc-qa
workflow test_score_download_rdpcqa {
    input_channel = [
      params.test_data['rdpc_qa']['study_id'], 
      params.test_data['rdpc_qa']['analysis_id'], 
      file(params.test_data['rdpc_qa']['analysis'])]

    SCORE_DOWNLOAD ( input_channel )
}

// Test with user provide data
workflow test_score_download_user {
    input_channel = [
      params.study_id, 
      params.analysis_id, 
      file(params.analysis)]

    SCORE_DOWNLOAD ( input_channel )
}