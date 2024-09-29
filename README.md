# Quick Start

```
nextflow run pl-mqc \
    --bucket 's3://foo/bar' \
    --mqc_config 'mqc_config.yml' \
     -work-dir 's3://foo/bar' \
    --outdir 's3://foo/bar' \
    -resume
```