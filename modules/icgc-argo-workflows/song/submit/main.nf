
process SONG_SUBMIT {
    tag "${study_id}"
    label 'process_single'

    maxRetries "${task.ext.max_retries}"
    errorStrategy {
        sleep(Math.pow(2, task.attempt) * task.ext.first_retry_wait_time * 1000 as long);  // backoff time increases exponentially before each retry
        return task.ext.max_retries ? 'retry' : 'finish'
    }

    pod = [secret: workflow.runName + "-secret", mountPath: "/tmp/rdpc_secret"]

    container "${ task.ext.song_container ?: 'ghcr.io/overture-stack/song-client' }:${ task.ext.song_container_version ?: '5.0.2' }"
    
    if (workflow.containerEngine == "singularity") {
        containerOptions "--bind \$(pwd):/song-client/logs"
    } else if (workflow.containerEngine == "docker") {
        containerOptions "-v \$(pwd):/song-client/logs"
    }

    input:
    val study_id
    path payload

    output:
    stdout emit: analysis_id
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def song_url = args.song_url ?: ""
    def accessToken = args.api_token ?: "`cat /tmp/rdpc_secret/secret`"
    def VERSION = task.ext.song_container_version ?: '5.0.2'
    """
    export CLIENT_SERVER_URL=${song_url}
    export CLIENT_STUDY_ID=${study_id}
    export CLIENT_ACCESS_TOKEN=${accessToken}

    set -euxo pipefail
    sing submit -f ${payload} | jq -er .analysisId | tr -d '\\n'

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        song-client: ${VERSION}
    END_VERSIONS

    """
}
