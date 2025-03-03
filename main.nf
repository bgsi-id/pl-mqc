nextflow.enable.dsl=2

workflow {
    // Read the list of directories to process
    Channel.fromPath("${params.dir_list}")
        .map { it.toString().trim() } // Ensure clean paths
        .set { runDirectory }

    MULTIQC(runDirectory, params.config_mqc)
}

process MULTIQC {
    container 'biocontainers/multiqc:1.25--pyhdfd78af_0'

    input:
    path runDirectory
    path multiqcConfig

    output:
    path("*")

    def isoDate = new Date().format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    publishDir {"${params.outdir}" }, mode: params.publish_dir_mode, pattern: "multiqc_general_stats.csv", saveAs: { "${isoDate}.csv" }

    script:
    def config = multiqcConfig ? "--config $multiqcConfig" : ''
    """
    multiqc ${config} \
        --data-dir \
        --data-format csv \
        --no-report \
        --force \
        ${runDirectory}

    mv multiqc_data/* .

    # Log processed directory
    echo "${runDirectory}" >> ${params.outdir}/processed_dirs.txt
    """
}
