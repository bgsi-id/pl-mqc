nextflow.enable.dsl=2

workflow {
    // Get directories from file list OR process all subdirectories
    def selectedDirs = params.file_list ? 
        Channel.fromPath(params.file_list).splitCsv(header: false).map { it[0] } :
        Channel.fromPath("${params.dir_input}/*", type: 'dir').map { it.toString() }

    // Collect all files from selected directories (assuming MultiQC needs actual data files)
    selectedDirs
        .flatMap { dir -> Channel.fromPath("${dir}/**", type: 'file') }
        .set { runFiles }

    MULTIQC(runFiles, params.config_mqc)
}

process MULTIQC {
    container 'biocontainers/multiqc:1.25--pyhdfd78af_0'

    input:
    path runFiles
    path multiqcConfig

    output:
    path("*")

    def isoDate = new Date().format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    publishDir {"${params.outdir}" }, mode: params.publish_dir_mode, pattern: "multiqc_general_stats.csv", saveAs: { "${isoDate}.csv" }
    
    script:
    def config = multiqcConfig ? "--config $multiqcConfig" : ''
    
    """
    echo ${runFiles} > file_list.txt
    multiqc ${config} \
        --file-list file_list.txt \
        --data-dir \
        --data-format csv \
        --no-report \
        --force
    mv multiqc_data/* .
    """
}
