# Quick Start

```
nextflow run pl-mqc \
    --input_file 's3://foo/bar' \
    --config_mqc 'mqc_config.yml' \
    -work-dir 's3://foo/bar' \
    --outdir 's3://foo/bar' \
    -resume
```