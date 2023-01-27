#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.study_id = ''
params.analysis_id = ''
//WorkflowMain.initialise(workflow, params, log)

include { SONG_SCORE_DOWNLOAD                  } from '../subworkflows/icgc-argo-workflows/song_score_download/main.nf'

workflow DOWNLOAD {
    SONG_SCORE_DOWNLOAD(params.study_id,params.analysis_id)
}

workflow {
    DOWNLOAD()
}