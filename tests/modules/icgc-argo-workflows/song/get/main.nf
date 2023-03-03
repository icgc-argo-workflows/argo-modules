#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SONG_GET } from '../../../../../modules/icgc-argo-workflows/song/get/main.nf'

workflow test_song_get_rdpcqa {

    input_channel = [params.test_data['rdpc_qa']['study_id'], params.test_data['rdpc_qa']['analysis_id']]
    SONG_GET ( input_channel )
}

workflow test_song_get_user {

    input_channel = [params.study_id, params.analysis_id]
    SONG_GET ( input_channel )
}