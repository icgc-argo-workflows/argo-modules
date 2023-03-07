#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { SONG_SCORE_UPLOAD } from '../../../../subworkflows/icgc-argo-workflows/song_score_upload/main.nf'

workflow test_song_score_upload_rdpcqa {

    input_channel = [
      [study_id:params.test_data['rdpc_qa']['study_id']],
      file(params.test_data['rdpc_qa']['payload'], checkIfExists: true),
      [file(params.test_data['rdpc_qa']['upload'], checkIfExists: true),
       file(params.test_data['rdpc_qa']['upload_index'], checkIfExists: true)]
    ]
    SONG_SCORE_UPLOAD ( input_channel )
}

workflow test_song_score_upload_user {
    
    payload_channel = Channel.of(file(params.payload))
    files_channel = Channel.fromPath(params.upload_files).toList()
    payload_channel.combine(files_channel.toList()).map{
      payload,files -> [
        [study_id:params.study_id],
        payload,
        files
      ]
    }
    .set {input_channel}

    SONG_SCORE_UPLOAD ( input_channel )
}