
process PAYLOAD_QCMETRICS {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'quay.io/biocontainers/python:3.8.3' }"

    input:  // input, make update as needed
      tuple val(meta), path(files_to_upload), path(metadata_analysis)
      val genome_annotation
      val genome_build
      val wf_name
      val wf_version

    output:  // output, make update as needed
      tuple val(meta), path("*.payload.json"), path("out/*"), emit: payload_files
      path "versions.yml", emit: versions

    script:
      // add and initialize variables here as needed

      """
      main.py \
        -f ${files_to_upload} \
        -a ${metadata_analysis} \
        -g "${genome_annotation}" \
        -b "${genome_build}" \
        -w "${wf_name}" \
        -r ${workflow.runName} \
        -s ${workflow.sessionId} \
        -v ${wf_version}

      cat <<-END_VERSIONS > versions.yml
      "${task.process}":
          python: \$(python --version | sed 's/Python //g')
      END_VERSIONS
      """
  }
