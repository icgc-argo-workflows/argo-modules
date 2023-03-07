#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SONG_PUBLISH } from '../../../../../modules/icgc-argo-workflows/song/publish/main.nf'

workflow test_song_publish {
    input_channel = [
      [study_id:params.test_data['rdpc_qa']['study_id']],
      params.test_data['rdpc_qa']['analysis_id_published']
    ]

    SONG_PUBLISH ( input_channel )
}
