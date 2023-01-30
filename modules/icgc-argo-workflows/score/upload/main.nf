

process SCORE_UPLOAD {
    tag "${analysis_id}"
    label 'process_medium'

    maxRetries "${task.ext.max_retries}"
    errorStrategy {
        sleep(Math.pow(2, task.attempt) * task.ext.first_retry_wait_time * 1000 as long);  // backoff time increases exponentially before each retry
        return task.ext.max_retries ? 'retry' : 'finish'
    }

    pod = [secret: workflow.runName + "-secret", mountPath: "/tmp/rdpc_secret"]

    container "${ task.ext.score_container ?: 'ghcr.io/overture-stack/score' }:${ task.ext.score_container_version ?: '5.8.1' }"

    if (workflow.containerEngine == "singularity") {
        containerOptions "--bind \$(pwd):/score-client/logs"
    } else if (workflow.containerEngine == "docker") {
        containerOptions "-v \$(pwd):/score-client/logs"
    }

    input:
    val analysis_id
    path manifest
    path upload

    output:
    val analysis_id               , emit: ready_to_publish
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${analysis_id}"
    def song_url = args.song_url ?: ""
    def score_url = args.score_url ?: ""
    def transport_parallel = args.transport_parallel ?: task.cpus
    def transport_mem = args.transport_mem ?: "2"
    def accessToken = args.api_token ?: "`cat /tmp/rdpc_secret/secret`"
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
