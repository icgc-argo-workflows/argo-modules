#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SONG_SUBMIT } from '../../../../../modules/icgc-argo-workflows/song/submit/main.nf'

workflow test_song_submit {

    input_channel = [
      [study_id:params.test_data['rdpc_qa']['study_id']],
      file(params.test_data['rdpc_qa']['payload'], checkIfExists: true),
      []
    ]  
    SONG_SUBMIT ( input_channel )
}
