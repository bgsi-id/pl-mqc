nextflow.enable.dsl=2

workflow {
    // Read file list if provided, otherwise use all directories
    def runDirs = params.file_list ? 
        Channel.fromPath(params.file_list).splitCsv(header: false).map { it[0] } :
        Channel.fromPath("${params.dir_input}/*", type: 'dir').map { it.toString() }

    runDirs.set { runDirectory }
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
        --file-list ${runDirectory} \
        --data-dir \
        --data-format csv \
        --no-report \
        --force
    mv multiqc_data/* .
    """
}
