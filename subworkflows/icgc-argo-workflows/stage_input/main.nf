
include { SONG_SCORE_DOWNLOAD          } from '../../icgc-argo-workflows/song_score_download/main'
include { PREP_SAMPLE                  } from '../../../modules/icgc-argo-workflows/prep/sample/main.nf'
include { SAMPLESHEET_CHECK            } from '../../../modules/icgc-argo-workflows/checkinput/main.nf'

workflow STAGE_INPUT {

    take:
    study_analysis  // channel: study_id, analysis_id
    sample_sheet

    main:
    ch_versions = Channel.empty()

    if (!"${workflow.profile}".contains('docker') && !"${workflow.profile}".contains('singularity')){
        exit 1, "Error Missing profile. `-profile` must be specified with the engines :`docker` or `singularity`."
    }
    if (!"${workflow.profile}".contains('rdpc_qa') && !"${workflow.profile}".contains('rdpc_dev') && !"${workflow.profile}".contains('rdpc')){
        exit 1, "Error Missing profile. `-profile` must be specified with the rdpc environments : `rdpc_qa`,`rdpc_dev`, or `rdpc`."
    }

    if (study_analysis[0] && study_analysis[1]){
        if (!params.api_token){
            if (!params.api_download_token || !params.api_upload_token){
                exit 1, "Error SONG parameters detected but missing token params. `--api_token` or `api_upload_token` and `api_download_token` must be supplied when uploading."
            }
        }
    }

    if (sample_sheet){
      println(sample_sheet)
      SAMPLESHEET_CHECK(file(sample_sheet),workflow.Manifest.name)

      ch_versions = ch_versions.mix(SAMPLESHEET_CHECK.out.versions)

      sheet_to_read = SAMPLESHEET_CHECK.out.csv
    } else {
      SONG_SCORE_DOWNLOAD( study_analysis )
      ch_versions = ch_versions.mix(SONG_SCORE_DOWNLOAD.out.versions)

      PREP_SAMPLE ( SONG_SCORE_DOWNLOAD.out.analysis_files )
      ch_versions = ch_versions.mix(PREP_SAMPLE.out.versions)

      sheet_to_read = PREP_SAMPLE.out.sample_sheet_csv
    } 


    sheet_to_read
    .collectFile(keepHeader: true, name: 'sample_sheet.csv')
    .splitCsv(header:true)
    .map{ row ->
      if (row.analysis_type == "sequencing_experiment" && row.single_end == 'False') {
        tuple([
          id:"${row.sample}-${row.lane}".toString(), 
          study_id:row.study_id,
          patient:row.patient,
          sex:row.sex,
          status:row.status.toInteger(),
          sample:row.sample, 
          read_group:row.read_group.toString(), 
          data_type:'fastq', 
          size:1, 
          experiment:row.experiment, 
          numLanes:row.read_group_count], 
          [file(row.fastq_1), file(row.fastq_2)],
          file(row.analysis_json)
          ) 
      }
      else if (row.analysis_type == "sequencing_experiment" && row.single_end == 'True') {
        tuple([
          id:"${row.sample}-${row.lane}".toString(), 
          study_id:row.study_id,
          patient:row.patient,
          sex:row.sex,
          status:row.status.toInteger(),
          sample:row.sample, 
          read_group:row.read_group.toString(), 
          data_type:'fastq', 
          single_end:row.single_end,
          size:1,
          experiment:row.experiment, 
          numLanes:row.read_group_count], 
          [file(row.fastq_1)],
          file(row.analysis_json)
          )
      }
      else if (row.analysis_type == "sequencing_alignment") {
        tuple([
          id:"${row.sample}".toString(),
          study_id:row.study_id,
          patient:row.patient,
          sample:row.sample,
          sex:row.sex,
          status:row.status.toInteger(), 
          data_type:'cram',
          genome_build:row.genome_build,
          size:1,
          experiment:row.experiment],
          [file(row.cram), file(row.crai)],
          file(row.analysis_json)
          )
      }
      else if (row.analysis_type == "variant_calling") {
        tuple([
          id:"${row.sample}".toString(),
          study_id:row.study_id, 
          patient:row.patient,
          sample:row.sample, 
          variantcaller:row.variantcaller,
          genome_build:row.genome_build,
          size:1,
          experiment:row.experiment,
          data_type:'vcf'], [
          file(row.vcf), file(row.tbi)],
          file(row.analysis_json)
          )
      }
      else if (row.analysis_type == "qc_metrics") {
        tuple([
          id:"${row.sample}".toString(),
          study_id:row.study_id, 
          patient:row.patient,
          sample:row.sample,
          sex:row.sex,
          status:row.status.toInteger(), 
          qc_tools:row.qc_tools, 
          size:1,
          experiment:row.experiment,
          data_type:'tgz'],
          [file(row.qc_file)],
          file(row.analysis_json)
          )
      }
    }
    .set { formatted_channel}

    formatted_channel.map{ meta,files,analysis_json -> tuple (meta,analysis_json)}.set{ch_meta_analysis}
    formatted_channel.map{ meta,files,analysis_json -> tuple (meta,files)}.set{ch_input_sample}


    emit:
    meta_analysis = ch_meta_analysis         // channel: [ val(meta), analysis_json]
    sample_files  = ch_input_sample          // channel: [ val(meta), [ files ] ]

    
    versions = ch_versions                   // channel: [ versions.yml ]
}