nextflow.enable.dsl=2

workflow {
    MULTIQC(params.input_file, params.config_mqc, params.outdir)
}

process MULTIQC {
    container 'biocontainers/multiqc:1.27.1--pyhdfd78af_0'

    input:
    path fileList
    path multiqcConfig
    val outdir

    output:
    path("*")

    def isoDate = new Date().format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    publishDir {"${outdir}" }, mode: params.publish_dir_mode, pattern: "multiqc_general_stats.csv", saveAs: { "${isoDate}.csv" }
    
    script:
    def config = multiqcConfig ? "--config $multiqcConfig" : ''
    """
    mkdir -p local_files

    apt-get update && apt-get install -y awscli || yum install -y awscli

    while IFS= read -r line; do d=\${line%/}; dir=\${d##*/} 
        aws s3 cp "\$line" "local_files/\$dir" --recursive
    done < $fileList

    # Create a new file list with local paths
    find local_files -mindepth 1 -maxdepth 1 -type d > local_file_list.txt

    # Run MultiQC
    multiqc ${config} \
        --file-list local_file_list.txt \
        --data-format csv \
        --no-report \
        --dirs \
        --force \
        -o multiqc_output
    mv multiqc_output/multiqc_data/* .
    """
}
