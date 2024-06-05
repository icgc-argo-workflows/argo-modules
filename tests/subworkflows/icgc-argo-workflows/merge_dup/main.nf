#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Set default parameter values
params.tools = ' '

// Import the MERGE_DUP subworkflow
include { MERGE_DUP } from '../../../../subworkflows/icgc-argo-workflows/merge_dup/main.nf'

// Define channels for input data
// Define a sample metadata map
def sampleMetadata = [
    study_id: "Study123",
    patient: "PatientXYZ",
    sample: "SampleA",
    sex: "female",
    numLanes: 1,
    experiment: "RNA-seq",
    date: "2021-01-01",
    tool: "Illumina"
    // Add more key-value pairs as necessary
]

// Create an input channel with the metadata and BAM file path
def inputChannel = Channel.fromPath('tests/data/qa/sample_01_L*.bam').combine(Channel.of(sampleMetadata))
.map{ bam,meta ->
    [
        meta,bam
    ]
}

// Create an input channel with the metadata and the reference files path
def referenceFiles = Channel.fromPath('tests/data/qa/test_genome.fa').combine(Channel.of(sampleMetadata))
        .map{ ref,meta ->
            [
                meta,ref
            ]
        }.mix(
        Channel.fromPath('tests/data/qa/test_genome.fa.fai').combine(Channel.of(sampleMetadata))
        .map{ ref,meta ->
            [
                meta,ref
            ]
        }
        )

// Transcriptome aligned bam
def inputChannel_transcript = Channel.fromPath('tests/data/qa/sample_01_tran_L*.bam').combine(Channel.of(sampleMetadata))
.map{ bam,meta ->
    [
        meta,bam
    ]
}
// Transcritome fasta and fai files
def referenceFiles_transcript = Channel.fromPath('tests/data/qa/test_transcript.fa').combine(Channel.of(sampleMetadata))
        .map{ ref,meta ->
            [
                meta,ref
            ]
        }.mix(
        Channel.fromPath('tests/data/qa/test_transcript.fa.fai').combine(Channel.of(sampleMetadata))
        .map{ ref,meta ->
            [
                meta,ref
            ]
        }
        )


workflow test_merge_dup {
    // Execute the MERGE_DUP subworkflow with the test data
    MERGE_DUP (inputChannel, referenceFiles)
}

workflow test_merge_dup_transcript {
    MERGE_DUP (inputChannel_transcript, referenceFiles_transcript)
}