#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SONG_SCORE_DOWNLOAD } from '../../../../subworkflows/icgc-argo-workflows/song_score_download/main.nf'

workflow test_song_score_download_rdpcqa {

    input_channel = [
      params.test_data['rdpc_qa']['study_id'], 
      analysis_id = params.test_data['rdpc_qa']['analysis_id']]

    SONG_SCORE_DOWNLOAD ( input_channel )
}

workflow test_song_score_download_user {
    
    input_channel = [
      params.study_id, params.analysis_id]

    SONG_SCORE_DOWNLOAD ( input_channel )
}