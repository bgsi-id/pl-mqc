nextflow.enable.dsl=2

workflow {
    if (params.file_list.startsWith('s3://')) {
        // Download the file list from S3
        def local_file_list = file("file_list.txt")
        exec "aws s3 cp ${params.file_list} ${local_file_list}"
        
        def runFiles = Channel.fromPath(local_file_list)
            .splitCsv(header: false)
            .map { it[0] }
            .set { runFiles }
    } else {
        def runFiles = Channel.fromPath(params.file_list)
            .splitCsv(header: false)
            .map { it[0] }
            .set { runFiles }
    }

    MULTIQC(runFiles, params.config_mqc)
}


process MULTIQC {
    container 'biocontainers/multiqc:1.25--pyhdfd78af_0'

    input:
    path(runFiles)
    path multiqcConfig

    output:
    path("*")

    def isoDate = new Date().format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    publishDir {"${params.outdir}" }, mode: params.publish_dir_mode, pattern: "multiqc_general_stats.csv", saveAs: { "${isoDate}.csv" }
    
    script:
    def config = multiqcConfig ? "--config $multiqcConfig" : ''

    """
    printf "%s\n" ${runFiles} > file_list.txt
    multiqc ${config} \
        --file-list file_list.txt \
        --data-dir \
        --data-format csv \
        --no-report \
        --force
    mv multiqc_data/* .
    """
}

