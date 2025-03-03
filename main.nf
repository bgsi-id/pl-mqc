workflow {
    Channel.value(params.dir_list)
        .map { file(params.dir_list) }  // Ensure it's handled as a file
        .set { dirListFile }

    MULTIQC(dirListFile, params.config_mqc)
}

process MULTIQC {
    container 'biocontainers/multiqc:1.25--pyhdfd78af_0'

    input:
    path dirListFile
    path multiqcConfig

    output:
    path("*")

    def isoDate = new Date().format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    publishDir {"${params.outdir}" }, mode: params.publish_dir_mode, pattern: "multiqc_general_stats.csv", saveAs: { "${isoDate}.csv" }

    script:
    def config = multiqcConfig ? "--config $multiqcConfig" : ''
    """
    aws s3 cp ${dirListFile} dir_list_local.txt  # Download S3 file
    multiqc ${config} --file-list dir_list_local.txt --data-format csv --no-report --force --dirs
    mv multiqc_data/* .
    """
}
