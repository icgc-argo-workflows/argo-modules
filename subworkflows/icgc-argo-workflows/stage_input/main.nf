
include { SONG_SCORE_DOWNLOAD          } from '../../icgc-argo-workflows/song_score_download/main'
include { PREP_SAMPLE                  } from '../../../modules/icgc-argo-workflows/prep/sample/main'
include { SAMPLESHEET_CHECK            } from '../../../modules/icgc-argo-workflows/checkinput/main'

workflow STAGE_INPUT {

    take:
    study_analysis  // channel: study_id, analysis_id
    samplesheet  // channel: samplesheet,workflow_name
    
    main:
    ch_versions = Channel.empty()



    if (params.api_token || params.api_download_token){
      SONG_SCORE_DOWNLOAD( study_analysis )
      ch_versions = ch_versions.mix(SONG_SCORE_DOWNLOAD.out.versions)

      PREP_SAMPLE ( SONG_SCORE_DOWNLOAD.out.analysis_files )
      ch_versions = ch_versions.mix(PREP_SAMPLE.out.versions)

      analysis_input = PREP_SAMPLE.out.sample_sheet_csv
    } else {
      SAMPLESHEET_CHECK(file(samplesheet),workflow.Manifest.name)
      ch_versions = ch_versions.mix(SAMPLESHEET_CHECK.out.versions)

      analysis_input =  SAMPLESHEET_CHECK.out.csv
    }

    analysis_input
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
           numLanes:row.read_group_count,
           experiment:row.experiment,
           single_end : row.single_end
           ], 
           [file(row.fastq_1), file(row.fastq_2)],
           row.analysis_json
           )
       } else if (row.analysis_type == "sequencing_experiment" && row.single_end == 'True') {
         tuple([
           id:"${row.sample}-${row.lane}".toString(), 
           study_id:row.study_id,
           patient:row.patient,
           sex:row.sex,
           status:row.status.toInteger(),
           sample:row.sample, 
           read_group:row.read_group.toString(), 
           data_type:'fastq', 
           numLanes:row.read_group_count,
           experiment:row.experiment,
           single_end : row.single_end
           ], 
           [file(row.fastq_1)],
           row.analysis_json
           ) 
      } else if (row.analysis_type == "sequencing_alignment") {
        tuple([
          id:"${row.sample}".toString(),
          study_id:row.study_id,
          patient:row.patient,
          sample:row.sample,
          sex:row.sex,
          status:row.status.toInteger(),
          genome_build:row.genome_build,
          experiment:row.experiment,
          data_type:'cram'], 
          [file(row.cram), file(row.crai)],
          row.analysis_json
          )
      }
      else if (row.analysis_type == "variant_calling") {
        tuple([
          id:"${row.sample}".toString(),
          study_id:row.study_id, 
          patient:row.patient,
          sample:row.sample,
          sex:row.sex,
          status:row.status.toInteger(), 
          variantcaller:row.variantcaller, 
          genome_build:row.genome_build,
          experiment:row.experiment,
          data_type:'vcf'],
          [file(row.vcf), file(row.tbi)],
          row.analysis_json
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
          genome_build:row.genome_build,
          experiment:row.experiment,
          data_type:'tgz'],
          [file(row.qc_file)],
          row.analysis_json
          )
      }
    }
    .set { ch_input_sample }

    ch_input_sample.map{ meta,files,analysis ->
      if (analysis){
        tuple([meta,file(analysis)])
      } else {
        tuple([meta,null])
      }
    }
    .set{ ch_meta_analysis }

    ch_input_sample.map{ meta,files,analysis -> tuple([meta,files])}.set{ch_files}

    //ch_meta_analysis.subscribe { println "$it" }
    //ch_files.subscribe { println "$it" }

    emit:
    meta_analysis = ch_meta_analysis         // channel: [ val(meta), analysis_json]
    sample_files  = ch_files          // channel: [ val(meta), [ files ] ]
    
    versions = ch_versions                   // channel: [ versions.yml ]
}