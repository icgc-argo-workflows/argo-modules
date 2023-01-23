#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SONG_SCORE_UPLOAD } from '../../../../subworkflows/icgc-argo-workflows/song_score_upload/main.nf'

workflow test_song_score_upload {
    
    study_id = params.test_data['rdpc_qa']['study_id']
    payload = file(params.test_data['rdpc_qa']['payload'], checkIfExists: true)
    upload = Channel.fromPath(params.test_data['rdpc_qa']['upload'])

    SONG_SCORE_UPLOAD ( study_id, payload, upload, "")
}
