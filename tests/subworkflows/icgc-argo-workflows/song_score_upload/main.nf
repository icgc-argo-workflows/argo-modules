#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SONG_SCORE_UPLOAD } from '../../../../subworkflows/icgc-argo-workflows/song_score_upload/main.nf'

workflow test_song_score_upload_rdpcqa {
    
    study_id = params.test_data['rdpc_qa']['study_id']
    payload = file(params.test_data['rdpc_qa']['payload'], checkIfExists: true)
    upload = Channel.fromPath(params.test_data['rdpc_qa']['upload'])

    SONG_SCORE_UPLOAD ( study_id, payload, upload, "")
}

workflow test_song_score_upload_user {
    
    study_id = params.study_id
    payload = file(params.payload, checkIfExists: true)
    upload_files = Channel.fromPath(params.upload_files)

    SONG_SCORE_UPLOAD ( study_id, payload, upload_files, "")
}