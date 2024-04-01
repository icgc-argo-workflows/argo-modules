#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PAYLOAD_GERMLINEVARIANT } from '../../../../../modules/icgc-argo-workflows/payload/germlinevariant/main.nf'

workflow test_payload_germlinevariant {
    analysis_ch=Channel.of(file(params.metadata_analysis))
    files_ch=Channel.fromPath(params.files_to_upload).map{it->file(it)}
    pipeline_ch=Channel.of(file(params.pipeline_yml))


    ch_payload=analysis_ch.combine(files_ch.collect().toList())
    .map {analysis_json,files ->
    [
        [
        id : params.id,
        experimentalStrategy : params.experimentalStrategy,
        genomeBuild : params.genomeBuild,
        tumourNormalDesignation : params.tumourNormalDesignation,
        sampleType : params.sampleType,
        gender : params.gender,
        study_id : params.study_id,
	tool : params.tool,
        dataType : params.dataType
	],
        files, analysis_json]
    }
    PAYLOAD_GERMLINEVARIANT(
        ch_payload,
        pipeline_ch,
        false
    )
}
