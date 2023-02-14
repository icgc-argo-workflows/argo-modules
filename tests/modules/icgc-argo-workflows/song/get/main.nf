#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SONG_GET } from '../../../../../modules/icgc-argo-workflows/song/get/main.nf'

workflow test_song_get_rdpcqa {

    study_id = params.test_data['rdpc_qa']['study_id']
    analysis_id = params.test_data['rdpc_qa']['analysis_id']

    SONG_GET ( study_id, analysis_id )
}

workflow test_song_get_user {

    study_id = params.study_id
    analysis_id = params.analysis_id

    SONG_GET ( study_id, analysis_id )
}