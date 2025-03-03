nextflow.enable.dsl=2

include { MULTIQC } from './modules.nf'

workflow {
    fileList = Channel.fromPath(params.file_list).collect()

    MULTIQC(fileList, params.config_mqc)
}
