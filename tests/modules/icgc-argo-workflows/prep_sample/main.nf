#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PREP_SAMPLE } from '../../../../modules/icgc-argo-workflows/prep_sample/main.nf'

// Test with Submitted Reads (bam) in rdpc-qa
workflow test_prep_sample_bam {

    input_channel = [
      file(params.test_data['rdpc_qa']['seq_exp_analysis_bam']),
      [file(params.test_data['rdpc_qa']['bam'], checkIfExists: true)]
    ]

    PREP_SAMPLE ( input_channel )
}

// Test with Submitted Reads (fastq) in rdpc-qa
workflow test_prep_sample_fastq {

    analysis_channel = Channel.of(file(params.test_data['rdpc_qa']['seq_exp_analysis_fastq']))
    fastq_channel = Channel.fromPath(params.test_data['rdpc_qa']['fastq']).toList()
    analysis_channel.combine(fastq_channel.toList()).set{input_channel}

    PREP_SAMPLE ( input_channel )
}

// Test with cram & crai in rdpc-qa
workflow test_prep_sample_cram_crai {

    input_channel = [
      file(params.test_data['rdpc_qa']['aln_analysis']),
      [file(params.test_data['rdpc_qa']['cram'], checkIfExists: true),
       file(params.test_data['rdpc_qa']['crai'], checkIfExists: true)]
    ]

    PREP_SAMPLE ( input_channel )
}

// Test with vcf & tbi in rdpc-qa
workflow test_prep_sample_vcf_tbi {

    input_channel = [
      file(params.test_data['rdpc_qa']['vcf_analysis']),
      [file(params.test_data['rdpc_qa']['vcf'], checkIfExists: true),
       file(params.test_data['rdpc_qa']['tbi'], checkIfExists: true)]
    ]

    PREP_SAMPLE ( input_channel )
}

// Test with user provide data
workflow test_prep_sample_user {

    analysis_channel = Channel.of(file(params.song_analysis))
    files_channel = Channel.fromPath(params.files).toList()
    analysis_channel.combine(files_channel.toList()).set{input_channel}

    PREP_SAMPLE ( input_channel )
}