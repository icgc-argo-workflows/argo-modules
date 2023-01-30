#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SONG_GET } from '../../../../../modules/icgc-argo-workflows/song/get/main.nf'

workflow test_song_get {

    study_id = params.test_data['rdpc_qa']['study_id']
    analysis_id = params.test_data['rdpc_qa']['analysis_id']

    SONG_GET ( study_id, analysis_id )
}
