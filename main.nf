nextflow.enable.dsl=2

workflow {
    Channel.fromPath(params.input_file).set { fileList }
    MULTIQC(fileList, params.config_mqc)
}

process MULTIQC {
    container 'biocontainers/multiqc:1.25--pyhdfd78af_0'

    input:
    path fileList
    path multiqcConfig optional

    output:
    path("*")
    
    def isoDate = new Date().format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    publishDir {"${params.outdir}" }, mode: params.publish_dir_mode, pattern: "multiqc_general_stats.csv", saveAs: { "${isoDate}.csv" }

    script:
    def config = multiqcConfig ? "--config $multiqcConfig" : ''
    """
    multiqc --file-list $fileList \
        --data-dir \
        --data-format csv \
        --no-report \
        --force \
        -o multiqc_output
    mv multiqc_output/multiqc_data/* multiqc_output/
    """
}
