#!/bin/bash

# Checking the version of Polly CLI
polly --version
# login into Polly with Polly CLI inside a Polly job
polly login --auto

## get the file into the docker from polly CLI
polly files copy --workspace-id ${WORKSPACE_ID} --source polly://${FILE_PATH_SOURCE} --destination "./launcher.sh"

polly files copy --workspace-id ${WORKSPACE_ID} --source polly://${PY_FILE_PATH_SOURCE} --destination "./merge_preprocess.py"

#polly files copy --workspace-id ${WORKSPACE_ID} --source polly://${FASTQ1} --destination "./data/${FASTQ1}"

#polly files copy --workspace-id ${WORKSPACE_ID} --source polly://${FASTQ2} --destination "./data/${FASTQ2}"

echo "copying references"
polly files sync --workspace-id ${WORKSPACE_ID} --source polly://${refvdj} --destination "./refdata-cellranger-vdj-GRCh38-alts-ensembl-5.0.0"

polly files sync --workspace-id ${WORKSPACE_ID} --source polly://${refgex} --destination "./refdata-gex-GRCh38-21064020-A"
## launch the file you just imported into the docker
chmod +x ./launcher.sh
./launcher.sh