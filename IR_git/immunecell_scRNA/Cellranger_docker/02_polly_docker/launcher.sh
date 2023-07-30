#!/bin/bash


    echo "Starting Worklfow";
    echo $value;
    rm -r data;
    mkdir -p data;
    echo "Starting Download";
    fastq-dump --gzip --split-3 --outdir /opt/data/ $value
    echo "Finished Download";
    

    
    rm -r FastQC
    mkdir -p FastQC
    #starting fastqc
    echo "Starting FastQC";
        # for file in *; do
            
        # if [[ -f $file ]]; then
        # fastqc "$file"
        # fi
        # done
    fastqc -o FastQC -f fastq -q /opt/data/*.fastq.gz -t $LOCAL_CORES
    echo "ending FastQC";

    echo "sync fastqc"
    #move the specific cell ranger vdj and count output to the specific folder - to do 
    polly files sync --workspace-id ${WORKSPACE_ID} --source /opt/FastQC/ --destination polly://${fastqc}

    #rename files according to cellranger standards
    FILE_EXTENSION_FOR_R1='_S1_L001_R1_001.fastq.gz'
    FILE_EXTENSION_FOR_R2='_S1_L001_R2_001.fastq.gz'

    echo "View Opt"
    fastq_folder_list=$(ls /opt/ )
    echo $fastq_folder_list

    

    echo "View fastqc"
    fastq_folder_list=$(ls /opt/FastQC/ )
    echo $fastq_folder_list

    echo "View data"
    fastq_folder_list=$(ls /opt/data/ )
    echo $fastq_folder_list


    for FQ in ${fastq_folder_list}
    do
        SAM=$(basename $FQ)
        echo "try"
        echo $SAM
        if [ $SAM = "${value}_1.fastq.gz" ]
        then
            echo $FQ
            echo ${SAM}
            Rename_file="${value}${FILE_EXTENSION_FOR_R1}"
            echo $Rename_file
            mv /opt/data/$FQ /opt/data/$Rename_file
        fi    
        
        SAM=$(basename $FQ)
        echo "try"
        echo $SAM
        if [ $SAM = "${value}_2.fastq.gz" ]
        then
            echo $FQ
            echo ${SAM}
            Rename_file="${value}${FILE_EXTENSION_FOR_R2}"
            echo $Rename_file
            mv /opt/data/$FQ /opt/data/$Rename_file
        fi     
    done
    echo "View renamed"
    fastq_folder_list=$(ls /opt/data/ )
    echo $fastq_folder_list
    
    
    echo "sync renamed data"
    #move the specific cell ranger vdj and count output to the specific folder - to do 
    polly files sync --workspace-id ${WORKSPACE_ID} --source /opt/data/ --destination polly://${data}

    echo "Started Running cellranger vdj";
    rm -r cellrangervdj;
    mkdir -p cellrangervdj;
    cd cellrangervdj;
    cellranger vdj --id=$value --reference=/opt/refdata-cellranger-vdj-GRCh38-alts-ensembl-5.0.0 --fastqs=/opt/data/ --sample=$value --localcores=$LOCAL_CORES --localmem=$LOCAL_MEM --chain=TR
    echo "Finished Running cellranger vdj"; 
    
     echo "sync cellranger vdj"
    #move the specific cell ranger vdj and count output to the specific folder - to do 
    polly files sync --workspace-id ${WORKSPACE_ID} --source cellrangervdj/$value/outs/ --destination polly://${vdj}
     
    echo "Started Running cellranger count"; 
    cd ..
    rm -r cellrangercount;
    mkdir -p cellrangercount;
    cd cellrangercount;
    cellranger count --id=$value --transcriptome=/opt/refdata-gex-GRCh38-21064020-A --fastqs=/opt/data/ --sample=$value --localcores=$LOCAL_CORES --localmem=$LOCAL_MEM
    echo "Finished Running cellranger count";
    cd ..
    
     #move the specific cell ranger vdj and count output to the specific folder - to do 
    echo "sync cellranger count"
    polly files sync --workspace-id ${WORKSPACE_ID} --source cellrangercount/$value/outs/ --destination polly://${count}

    mkdir -p merge
    cp cellrangervdj/$value/outs/filtered_contig_annotations.csv merge/filtered_contig_annotations.csv
    cp cellrangercount/$value/outs/filtered_feature_bc_matrix.h5 merge/filtered_feature_bc_matrix.h5
    
    echo "sync merge folder after copy"
    polly files sync --workspace-id ${WORKSPACE_ID} -s merge -d polly://${OUTPUT_DIR_IM}/merge

    python3 ./merge_preprocess.py;
   
    
    polly files sync --workspace-id ${WORKSPACE_ID} -s merge -d polly://${OUTPUT_DIR_IM}/merge
    




