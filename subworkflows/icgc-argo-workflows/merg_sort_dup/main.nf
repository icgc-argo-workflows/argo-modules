// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { SAMTOOLS_MERGE                        } from '../../../modules/icgc-argo-workflows/samtools/merge/main'
include { BIOBAMBAM_BAMMARKDUPLICATES2          } from '../../../modules/icgc-argo-workflows/biobambam/bammarkduplicates2/main'
include { SAMTOOLS_INDEX                        } from '../../../modules/icgc-argo-workflows/samtools/index/main' 
include { SAMTOOLS_CONVERT                      } from '../../../modules/icgc-argo-workflows/samtools/convert/main'
include { TAR                                   } from '../../../modules/icgc-argo-workflows/tar/main'

workflow MERG_SORT_DUP {

    take:
    bam
    reference_files

    main:

    ch_versions = Channel.empty()

    reference_files.branch{
        fasta : it[1].name.endsWith(".fasta") || it[1].name.endsWith(".fa")
        return it
        fai : it[1].name.endsWith(".fai")
        return it
    }.set{ref_org}

    //bam.subscribe{println "bam: ${it}"}
    //Collect channel (e.g. [metaA,bamA,metaB,bamB] and seperate back in channels of [meta,bam])
    //Simplfy metadata to group and collect BAMs : [meta, [bamA,bamB,bamC]] for merging
    bam.flatten().buffer( size: 2 )
    .map{
        meta,bam ->
        [
            [
            id:"${meta.study_id}.${meta.patient}.${meta.sample}",
            study_id:"${meta.study_id}",
            patient:"${meta.patient}",
            sex:"${meta.sex}",
            sample:"${meta.sample}",
            numLanes:"${meta.numLanes}",
            experiment:"${meta.experiment}",
            date:"${meta.date}",
            tool: "${meta.tool}"
            ],
            [
            read_group:"${meta.id}",
            data_type:"${meta.data_type}",
            size:"${meta.size}",
            ],
            bam
        ]
    }.groupTuple(by: 0).
    map{
        meta,info,bam ->
        [
            [
            id:"${meta.study_id}.${meta.patient}.${meta.sample}",
            study_id:"${meta.study_id}",
            patient:"${meta.patient}",
            sex:"${meta.sex}",
            sample:"${meta.sample}",
            numLanes:"${meta.numLanes}",
            experiment:"${meta.experiment}",
            date:"${meta.date}",
            read_group:"${info.read_group.collect()}",
            data_type:"${info.data_type.collect()}",
            size:"${info.size.collect()}",
            tool: "${meta.tool}"
            ],bam.collect()
        ]
    }.set{ch_bams}

//    ch_bams.subscribe{println "input bam: ${it}"}
//    reference_files.subscribe{println "reference :${it}"}

    SAMTOOLS_MERGE(
        ch_bams,
        ref_org.fasta,
        ref_org.fai
    )

    // SAMTOOLS_MERGE(
    //     ch_bams,
    //     reference_files.map{ meta,files -> [files.findAll{ it.name.endsWith(".fasta") || it.name.endsWith(".fa") }]}.flatten().map{ file -> [[],file]},
    //     reference_files.map{ meta,files -> [files.findAll{ it.name.endsWith(".fai") }]}.flatten().map{ file -> [[],file]}
    // )

    ch_versions = ch_versions.mix(SAMTOOLS_MERGE.out.versions)

//    SAMTOOLS_MERGE.out.bam.subscribe{println "merge :${it}"}

    //If markdup specified, markdup file else return as is
    SAMTOOLS_MERGE.out.bam
        .map{
            meta,file ->
            [
                [
                    id:"${meta.id}.csort.markdup",
                    study_id:"${meta.study_id}",
                    patient:"${meta.patient}",
                    sex:"${meta.sex}",
                    sample:"${meta.sample}",
                    date:"${meta.date}",
                    numLanes:"${meta.numLanes}",
                    read_group:"${meta.read_group}",
                    data_type:"${meta.data_type}",
                    size:"${meta.size}",
                    experiment:"${meta.experiment}",
                    tool: "${meta.tool}"
                ],
                file
            ]
    }.set{ch_markdup}

//    ch_markdup.subscribe{println "markdup :${it}"}

    if (params.tools.split(',').contains('markdup')){
        BIOBAMBAM_BAMMARKDUPLICATES2(
            ch_markdup
        )
        ch_versions = ch_versions.mix(BIOBAMBAM_BAMMARKDUPLICATES2.out.versions)
        BIOBAMBAM_BAMMARKDUPLICATES2.out.bam.set{markdup_bam}
    } else {
        ch_markdup.set{markdup_bam}//meta,bam
    }

//    markdup_bam.subscribe{println "markdup bam :${it}"}

    //Index Csort.Markdup.Bam 
    SAMTOOLS_INDEX(markdup_bam)
    ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions)

    //Use new index and Bam for conversion to CRAM
    markdup_bam.combine(SAMTOOLS_INDEX.out.bai)//meta,bai
    .map{
        metaA,bam,metaB,index ->
        [
            [
                id:"${metaA.id}",
                study_id:"${metaA.study_id}",
                patient:"${metaA.patient}",
                sex:"${metaA.sex}",
                sample:"${metaA.sample}",
                numLanes:"${metaA.numLanes}",
                date:"${metaA.date}",
                read_group:"${metaA.read_group}",
                data_type:"${metaA.data_type}",
                size:"${metaA.size}",
                experiment:"${metaA.experiment}",
                tool: "${metaA.tool}"
            ],
            bam,index
        ]
    }.set{ch_convert}

    //ch_convert.mix(ch_fa).mix(ch_fai).subscribe{ println "HELP??? : ${it}"}

    //reference_files.map{ meta,files -> [files.findAll{ it.name.endsWith(".fasta") || it.name.endsWith(".fa") }]}.flatten().map{ file -> [[],file]}.subscribe{println "HELP :${it}"}
    // SAMTOOLS_CONVERT(
    //     ch_convert,
    //     reference_files.map{ meta,files -> [files.findAll{ it.name.endsWith(".fasta") || it.name.endsWith(".fa") }]}.flatten().map{ file -> [[],file]},
    //     reference_files.map{ meta,files -> [files.findAll{ it.name.endsWith(".fai") }]}.flatten().map{ file -> [[],file]}
    // )
    // SAMTOOLS_CONVERT(
    //     ch_convert,
    //     ch_fa,
    //     ch_fai
    // )

    SAMTOOLS_CONVERT(
        ch_convert,
        ref_org.fasta,
        ref_org.fai
    )

    // SAMTOOLS_CONVERT(
    //     ch_convert,
    //     reference_files.map{ meta,files -> [files.findAll{ it.name.endsWith(".fasta") || it.name.endsWith(".fa") }]}.flatten().collect(),
    //     reference_files.map{ meta,files -> [files.findAll{ it.name.endsWith(".fai") }]}.flatten().collect()
    // )

            // reference_files.map{ meta,files -> [files.findAll{ it.name.endsWith(".fasta") || it.name.endsWith(".fa") }]}.flatten().map{ file -> [[],file]},
        // reference_files.map{ meta,files -> [files.findAll{ it.name.endsWith(".fai") }]}.flatten().map{ file -> [[],file]}

    ch_versions = ch_versions.mix(SAMTOOLS_CONVERT.out.versions)

    SAMTOOLS_CONVERT.out.cram.combine(SAMTOOLS_CONVERT.out.crai)//.subscribe{println "COMBINED : $it"}
    .map{
        metaA,cram,metaB,index ->
        [
            [
                id:"${metaA.id}",
                study_id:"${metaA.study_id}",
                patient:"${metaA.patient}",
                sex:"${metaA.sex}",
                sample:"${metaA.sample}",
                numLanes:"${metaA.numLanes}",
                date:"${metaA.date}",
                read_group:"${metaA.read_group}",
                data_type:"${metaA.data_type}",
                size:"${metaA.size}",
                experiment:"${metaA.experiment}",
                tool: "${metaA.tool}"
            ],
            cram,index
        ]
    }.set{alignment_index}

    //If Markdup specified, TAR metrics file
    if (params.tools.split(',').contains('markdup')){
        TAR(
            BIOBAMBAM_BAMMARKDUPLICATES2.out.metrics
            .map{ meta,file-> 
            [
                [   
                    study_id:"${meta.study_id}",
                    patient:"${meta.patient}",
                    sex:"${meta.sex}",
                    sample:"${meta.sample}",
                    date:"${meta.date}",
                    numLanes:"${meta.numLanes}",
                    read_group:"${meta.read_group}",
                    data_type:"${meta.data_type}",
                    size:"${meta.size}",
                    experiment:"${meta.experiment}",
                    id:"${meta.study_id}.${meta.patient}.${meta.sample}.${meta.experiment}.aln.cram.duplicates_metrics",
                    tools:"${meta.tool}"
                ],file
            ]
            }
        )
        TAR.out.stats.set{metrics}
        Channel.empty()
        .mix(ch_bams.map{meta,files -> files}.collect())
        .mix(SAMTOOLS_MERGE.out.bam.map{meta,file -> file}.collect())
        .mix(BIOBAMBAM_BAMMARKDUPLICATES2.out.bam.map{meta,file -> file}.collect())
        .mix(SAMTOOLS_INDEX.out.bai.map{meta,file -> file}.collect())
        .collect()
        .set{ch_cleanup}
    } else {
        Channel.empty()
        .mix(ch_bams.map{meta,files -> files}.collect())
        .mix(SAMTOOLS_MERGE.out.bam.map{meta,file -> file}.collect())
        .mix(SAMTOOLS_INDEX.out.bai.map{meta,file -> file}.collect())
        .collect()
        .set{ch_cleanup}

        Channel.empty().set{metrics}  
    }



    ch_versions= ch_versions.map{ file -> file.moveTo("${file.getParent()}/.${file.getName()}")}
    
    emit:
    cram_alignment_index = alignment_index
    tmp_files = ch_cleanup
    metrics = metrics
    versions = ch_versions                     // channel: [ versions.yml ]
}
