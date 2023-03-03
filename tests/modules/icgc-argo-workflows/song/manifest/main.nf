#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SONG_MANIFEST } from '../../../../../modules/icgc-argo-workflows/song/manifest/main.nf'

workflow test_song_manifest_rdpcqa {
    
    input_channel = [
      [study_id:params.test_data['rdpc_qa']['study_id']],
      params.test_data['rdpc_qa']['analysis_id_unpublished'],
      file(params.test_data['rdpc_qa']['payload'], checkIfExists: true),
      [file(params.test_data['rdpc_qa']['upload'], checkIfExists: true),
       file(params.test_data['rdpc_qa']['upload_index'], checkIfExists: true)]
    ]
    SONG_MANIFEST ( input_channel )
}

