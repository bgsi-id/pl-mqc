nextflow.enable.dsl=2

workflow {
    Channel.fromPath("${params.dir_input}", type: 'dir').set { runDirectory }
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
        --dirs-depth 2 \
        ${runDirectory}
    mv multiqc_data/* .
    """
}
