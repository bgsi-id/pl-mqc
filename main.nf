nextflow.enable.dsl=2

workflow {
    Channel.value(params.file_list).set { fileList }
    MULTIQC(fileList, params.config_mqc)
}

process MULTIQC {
    container 'biocontainers/multiqc:1.25--pyhdfd78af_0'

    input:
    path fileList
    path multiqcConfig

    output:
    path("*")

    def isoDate = new Date().format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    publishDir {"${params.outdir}" }, mode: params.publish_dir_mode, pattern: "multiqc_general_stats.csv", saveAs: { "${isoDate}.csv" }
    
    script:
    def config = multiqcConfig ? "--config $multiqcConfig" : ''
    """
    multiqc ${config} \
        --file-list ${fileList} \
        --data-format csv \
        --no-report \
        --force \
        --dirs
    mv multiqc_data/* .
    """
}
