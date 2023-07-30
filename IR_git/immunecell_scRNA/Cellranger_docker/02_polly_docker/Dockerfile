FROM ubuntu:22.04
USER root
RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y 
RUN apt-get -o DPkg::Options::="--force-confnew" -y install openssl
RUN apt-get install sra-toolkit -y  
RUN apt-get update
RUN apt-get -o DPkg::Options::="--force-confnew" -y install netbase
# Install PollyCLI
# install nodejs
RUN apt-get update && apt-get install -y curl
RUN apt-get install -y \
  nodejs
RUN apt install npm -y
RUN echo "Node: " && node -v
RUN echo "NPM: " && npm -v
RUN npm install -g @elucidatainc/pollycli && polly version --version

#installing pip
RUN apt install -y python3-pip

RUN apt-get install -y wget
# Install cellranger
RUN mkdir software
RUN wget https://cus-public-dependencies.s3.ap-south-1.amazonaws.com/Single_Cell_Multiome_ATAC___RNAseq/cellranger-6.1.2.tar  -O /software/cellranger-6.1.2.tar
RUN tar -xzvf /software/cellranger-6.1.2.tar -C /software && rm /software/cellranger-6.1.2.tar
ENV PATH="/software/cellranger-6.1.2:${PATH}"
WORKDIR /opt 
COPY requirements.txt .
RUN pip3 install -r requirements.txt
#installing leiden
RUN pip3 install leidenalg
RUN apt -y install fastqc
COPY entrypoint.sh .
RUN chmod +x ./entrypoint.sh
CMD ["bash","entrypoint.sh"]
