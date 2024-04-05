#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import the MERG_SORT_DUP subworkflow
include { MERG_SORT_DUP } from '../../../../subworkflows/icgc-argo-workflows/merg_sort_dup/main.nf'

// Define channels for input data
// Define a sample metadata map and BAM file path
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

// Define the path to your test BAM file(s)
def bamFilePath = '/Users/gfeng/Documents/Work/ICGC-ARGO-WORKFLOWS/NEW/argo-modules/tests/data/qa/sample_01_L*.bam'

// Create an input channel with the metadata and BAM file path
// Note: The BAM file path needs to be wrapped with the file() method to create a Nextflow File object
//def inputChannel = Channel.of([sampleMetadata, file(bamFilePath)])
def inputChannel = Channel.fromPath('/Users/gfeng/Documents/Work/ICGC-ARGO-WORKFLOWS/NEW/argo-modules/tests/data/qa/sample_01_L*.bam').combine(Channel.of(sampleMetadata))
.map{ bam,meta ->
    [
        meta,bam
    ]
}

// def referenceFiles = Channel.fromPath('/Users/gfeng/Documents/Work/ICGC-ARGO-WORKFLOWS/NEW/argo-modules/tests/data/qa/GRCh38_Verily_v1.genome.fa*').combine(Channel.of(["hello"]))
// .map{ ref,meta ->
//     [
//         meta,file(ref)
//     ]
// }

def referenceFiles = Channel.fromPath('/Users/gfeng/Documents/Work/ICGC-ARGO-WORKFLOWS/NEW/argo-modules/tests/data/qa/GRCh38_Verily_v1.genome.fa').combine(Channel.of(["hello"]))
        .map{ ref,meta ->
            [
                meta,ref
            ]
        }.mix(
        Channel.fromPath('/Users/gfeng/Documents/Work/ICGC-ARGO-WORKFLOWS/NEW/argo-modules/tests/data/qa/GRCh38_Verily_v1.genome.fa.fai').combine(Channel.of(["hello"]))
        .map{ ref,meta ->
            [
                meta,ref
            ]
        })

workflow test_merg_sort_dup {

    // Execute the MERG_SORT_DUP subworkflow with the test data
    MERG_SORT_DUP (inputChannel, referenceFiles)

    // Check if output files exists or have the expected content
    //MERG_SORT_DUP.out.cram_alignment_index.view { "Generated CRAM Index: ${it}" }
    //MERG_SORT_DUP.out.tmp_files.view { "Temporary files for cleanup: ${it}" }
    //MERG_SORT_DUP.out.metrics.view { "Metrics file: ${it}" }
    //MERG_SORT_DUP.out.versions.view { "Software versions: ${it}" }
    }