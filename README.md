# pl-mqc

A Nextflow pipeline that downloads QC output directories from S3 and aggregates them into a single report using [MultiQC](https://multiqc.info/).

## Prerequisites

- [Nextflow](https://www.nextflow.io/) `>=20.01.0`
- Docker (the pipeline runs MultiQC inside the `biocontainers/multiqc:1.27.1--pyhdfd78af_0` container)
- AWS credentials configured (e.g. via `aws configure` or environment variables) with read access to the input bucket(s) and write access to the output location

## Inputs

| Param          | Required | Description                                                                                          |
|----------------|----------|--------------------------------------------------------------------------------------------------------|
| `--input_file` | yes      | Path to a text file listing S3 paths (one per line), each pointing to a directory to download and QC  |
| `--config_mqc` | no       | Path to a MultiQC config YAML file (local or `s3://...` — Nextflow will download it automatically)    |
| `--outdir`     | yes      | Where to publish the output `multiqc_general_stats.csv` (can be a local path or `s3://...`)           |

`--input_file` should look like this:

```
s3://my-bucket/run1/fastqc
s3://my-bucket/run2/fastqc
```

## Running manually

From the repo root:

```bash
nextflow run main.nf \
    --input_file /path/to/input_file.txt \
    --config_mqc /path/to/mqc_config.yml \
    --outdir ./out \
    -resume
```

To run against/publish to S3, point `-work-dir` and `--outdir` at S3 locations:

```bash
nextflow run main.nf \
    --input_file /path/to/input_file.txt \
    --config_mqc /path/to/mqc_config.yml \
    -work-dir s3://foo/bar/work \
    --outdir s3://foo/bar/out \
    -resume
```

## Output

The pipeline publishes a timestamped CSV (`<ISO-timestamp>.csv`) containing the MultiQC general stats to `--outdir`.
