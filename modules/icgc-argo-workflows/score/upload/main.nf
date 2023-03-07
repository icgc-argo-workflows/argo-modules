

process SCORE_UPLOAD {
    tag "${analysis_id}"
    label 'process_medium'

    pod = [secret: workflow.runName + "-secret", mountPath: "/tmp/rdpc_secret"]
    container "${ task.ext.score_container ?: 'ghcr.io/overture-stack/score' }:${ task.ext.score_container_version ?: '5.8.1' }"

    if (workflow.containerEngine == "singularity") {
        containerOptions "--bind \$(pwd):/score-client/logs"
    } else if (workflow.containerEngine == "docker") {
        containerOptions "-v \$(pwd):/score-client/logs"
    }

    input:
    tuple val(meta), val(analysis_id), path(manifest), path(upload)

    output:
    tuple val(meta), val(analysis_id),    emit: ready_to_publish
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${analysis_id}"
    def song_url = task.ext.song_url ?: ""
    def score_url = task.ext.score_url ?: ""
    def transport_parallel = task.ext.transport_parallel ?: task.cpus
    def transport_mem = task.ext.transport_mem ?: "2"
    def accessToken = task.ext.api_token ?: "`cat /tmp/rdpc_secret/secret`"
    def VERSION = task.ext.score_container_version ?: '5.8.1'
    """
    export METADATA_URL=${song_url}
    export STORAGE_URL=${score_url}
    export TRANSPORT_PARALLEL=${transport_parallel}
    export TRANSPORT_MEMORY=${transport_mem}
    export ACCESSTOKEN=${accessToken}
    
    score-client upload --manifest ${manifest} 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        score-client: ${VERSION}
    END_VERSIONS
    """
}
