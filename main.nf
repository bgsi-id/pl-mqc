nextflow.enable.dsl=2

workflow {
    MULTIQC(params.input_file, params.config_mqc, params.outdir)
}

process MULTIQC {
    container 'biocontainers/multiqc:1.27.1--pyhdfd78af_0'
    publishDir { "${outdir}" }, mode: params.publish_dir_mode, pattern: "multiqc_general_stats.csv", saveAs: { new Date().format("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") + ".csv" }

    input:
    path fileList
    path multiqcConfig
    val outdir

    output:
    path("*")

    script:
    def config = multiqcConfig ? "--config $multiqcConfig" : ''
    """
    mkdir -p local_files

    apt-get update && apt-get install -y awscli || yum install -y awscli

    : > sample_map.tsv
    while IFS= read -r line; do d=\${line%/}; dir=\${d##*/}
        aws s3 cp "\$line" "local_files/\$dir" --recursive
        printf '%s\t%s\n' "\${dir%_*}" "\$dir" >> sample_map.tsv
    done < $fileList

    # Create a new file list with local paths
    find local_files -mindepth 1 -maxdepth 1 -type d > local_file_list.txt

    # Run MultiQC
    multiqc ${config} \
        --file-list local_file_list.txt \
        --data-format csv \
        --no-report \
        --force \
        -o multiqc_output
    mv multiqc_output/multiqc_data/* .

    # MultiQC's general stats merge collapses sample names back to the internal
    # file-content id, dropping the S3 folder's unique suffix. Restore it as
    # "<anything> | <run_name> | <run_name> | <id_repository>".
    # id_repository stays the bare id, with any
    # trailing "_1"/"_2" or " R1"/" R2" read-pair suffix preserved.
    awk -v OFS=',' '
        BEGIN { FS="\t" }
        NR==FNR { map[\$1]=\$2; next }
        FNR==1 { FS=","; print; next }
        {
            newval = ""
            for (id in map) {
                if (\$1 == id) {
                    newval = "local_files | " map[id] " | " map[id] " | " id
                    break
                } else if (\$1 ~ ("^" id "[ _]")) {
                    suffix = substr(\$1, length(id) + 1)
                    newval = "local_files | " map[id] " | " map[id] " | " id suffix
                    break
                }
            }
            if (newval != "") \$1 = newval
            print
        }
    ' sample_map.tsv multiqc_general_stats.csv > multiqc_general_stats.csv.tmp
    mv multiqc_general_stats.csv.tmp multiqc_general_stats.csv
    """
}
