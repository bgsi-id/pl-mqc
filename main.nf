nextflow.enable.dsl=2

workflow {
    fileList = Channel.fromPath(params.file_list).collect()

    MULTIQC(fileList, params.config_mqc)
}

process MULTIQC {
    container 'biocontainers/multiqc:1.25--pyhdfd78af_0'

    input:
    path fileList
    path multiqcConfig optional true  // Ensure multiqcConfig is optional

    output:
    path "*"

    script:
    def isoDate = new Date().format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    def config = multiqcConfig ? "--config $multiqcConfig" : ''

    """
    # Generate file list
    printf "%s\n" ${fileList[@]} > file_list.txt

    multiqc ${config} \
        --file-list file_list.txt \
        --data-format csv \
        --no-report \
        --force \
        --dirs

    mv multiqc_data/* .

    # Ensure publishing happens inside the process
    mkdir -p ${params.outdir}
    mv multiqc_general_stats.csv ${params.outdir}/${isoDate}.csv
    """
}
