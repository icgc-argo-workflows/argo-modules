#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.study_id = ''
params.analysis_id = ''
params.api_token = ''
//WorkflowMain.initialise(workflow, params, log)

include { SONG_SCORE_UPLOAD                  } from '../subworkflows/icgc-argo-workflows/song_score_upload/main.nf'

workflow  UPLOAD {

    study_id = params.study_id
    payload = file(params.payload, checkIfExists: true)
    upload = Channel.fromPath(params.upload)
    SONG_SCORE_UPLOAD(study_id,payload,upload,"")
}

workflow {
    UPLOAD()
}