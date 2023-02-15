#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SONG_MANIFEST } from '../../../../../modules/icgc-argo-workflows/song/manifest/main.nf'

workflow test_song_manifest_rdpcqa {
    study_id = params.test_data['rdpc_qa']['study_id']
    analysis_id = params.test_data['rdpc_qa']['analysis_id_unpublished']
    upload = Channel.fromPath(params.test_data['rdpc_qa']['upload'])

    SONG_MANIFEST ( study_id, analysis_id, upload.collect() )
}

