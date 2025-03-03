nextflow.enable.dsl=2

workflow {
    MULTIQC(params.input_file, params.config_mqc, params.outdir)
}

process MULTIQC {
    container 'biocontainers/multiqc:1.25--pyhdfd78af_0'

    input:
    path fileList
    path multiqcConfig
    val outdir

    output:
    path("*")

    def isoDate = new Date().format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    publishDir {"${outdir}" }, mode: params.publish_dir_mode, pattern: "multiqc_general_stats.csv", saveAs: { "${isoDate}.csv" }

    script:
    """
    mkdir -p local_files
    while IFS= read -r file; do
        aws s3 cp "$file" local_files/
    done < "$fileList"

    find local_files -type f > local_file_list.txt
    
    multiqc --file-list local_file_list.txt \
        --data-dir \
        --data-format csv \
        --no-report \
        --force \
        -o multiqc_output
    mv multiqc_output/multiqc_data/* multiqc_output/
    """
}