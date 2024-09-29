nextflow.enable.dsl=2

workflow {
    Channel.fromPath("${params.bucket}", type: 'dir').set { runDirectory }
    MULTIQC(runDirectory, params.mqc_config)
}

process MULTIQC {
    container 'biocontainers/multiqc:1.25--pyhdfd78af_0'

    input:
    path runDirectory
    path multiqc_config

    output:
    path("multiqc_general_stats.txt")

    def isoDate = new Date().format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    publishDir {"${params.outdir}" }, mode: params.publish_dir_mode, pattern: "multiqc_general_stats.txt", saveAs: { "${isoDate}.txt" }
    
    script:
    def config = multiqc_config ? "--config $multiqc_config" : ''
    """
    multiqc ${runDirectory} ${runDirectory} 
    mv multiqc_data/* .
    """
}
