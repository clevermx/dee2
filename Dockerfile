# Base image
FROM ubuntu:16.04

# Metadata
LABEl base.image="ubuntu:16.04"
LABEL version="1"
LABEL software="Image for DEE2"
LABEL software.version="20170906"
LABEL description="Image for DEE2"
LABEL website=""
LABEL documentation=""
LABEL license=""
LABEL tags="Genomics"

# Maintainer
MAINTAINER Mark Ziemann <mark.ziemann@gmail.com>

ENV DIRPATH /home/data/
WORKDIR $DIRPATH

RUN rm /bin/sh && \
  ln /bin/bash /bin/sh

#numaverage numround numsum
RUN \
  apt-get clean all && \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
    curl \
    num-utils \
    wget \
    git \
    perl \
    zip \
    unzip \
    python3 \
    python3-pip \
    libtbb2  \
    default-jdk

########################################
# BOWTIE2 the apt version is too old and conda not working
########################################
RUN \
  wget -O bowtie2-2.3.2-linux-x86_64.zip "https://downloads.sourceforge.net/project/bowtie-bio/bowtie2/2.3.2/bowtie2-2.3.2-linux-x86_64.zip?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fbowtie-bio%2Ffiles%2Fbowtie2%2F2.3.2&ts=1504676040&use_mirror=nchc" && \
  unzip bowtie2-2.3.2-linux-x86_64.zip && \
  cd bowtie2-2.3.2/ && \
  cp bow* /usr/local/bin
RUN \
  ln /usr/bin/python3 /usr/bin/python

########################################
# SRA TOOLKIT WORKING
########################################
ENV VERSION 2.8.2-1
RUN \
  wget -c -O sratoolkit.2.8.2-1-ubuntu64.tar.gz "http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2-1/sratoolkit.2.8.2-1-ubuntu64.tar.gz"  && \
  tar zxfv sratoolkit.2.8.2-1-ubuntu64.tar.gz && \
  cp -r sratoolkit.2.8.2-1-ubuntu64/bin/* /usr/local/bin

########################################
# Install parallel-fastq-dump
########################################
#COPY get-pip.py .
RUN pip3 install --upgrade pip
RUN pip3 install parallel-fastq-dump

########################################
# SKEWER WORKING
########################################
RUN \
  wget -O skewer-0.2.2-linux-x86_64 "https://downloads.sourceforge.net/project/skewer/Binaries/skewer-0.2.2-linux-x86_64?r=&ts=1504573715&use_mirror=nchc" && \
  mv skewer-0.2.2-linux-x86_64 skewer && \
  chmod +x skewer && \
  cp skewer /usr/local/bin/
ENTRYPOINT ["skewer"]

########################################
# MINION from kraken toolkit (ebi)
########################################
RUN \
  wget -c "http://wwwdev.ebi.ac.uk/enright-dev/kraken/reaper/binaries/reaper-13-100/linux/minion" && \
  chmod +x  minion && \
  cp minion /usr/local/bin/minion
ENTRYPOINT ["minion"]

########################################
# STAR
########################################
RUN \
  wget -c "https://github.com/alexdobin/STAR/raw/master/bin/Linux_x86_64_static/STAR" && \
  chmod +x STAR && \
  cp STAR /usr/local/bin/STAR
ENTRYPOINT ["STAR"]

########################################
# Fastqc
########################################
RUN \
  wget -O fastqc_v0.11.5.zip "https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip" && \
  unzip fastqc_v0.11.5.zip && \
  cd FastQC && \
  chmod +x fastqc && \
  mv * /usr/local/bin/
ENTRYPOINT ["fastqc"]

########################################
# KALLISTO
########################################
RUN \
  wget -c "https://github.com/pachterlab/kallisto/releases/download/v0.43.1/kallisto_linux-v0.43.1.tar.gz" && \
  tar xf kallisto_linux-v0.43.1.tar.gz && \
  cd kallisto_linux-v0.43.1 && \
  chmod +x kallisto && \
  cp kallisto /usr/local/bin/kallisto  
ENTRYPOINT ["kallisto"]


########################################
# ASCP and the NCBI license WORKING
########################################
RUN \
  wget -c "http://download.asperasoft.com/download/sw/ascp-client/3.5.4/ascp-install-3.5.4.102989-linux-64.sh" && \
  test $(sha1sum ascp-install-3.5.4.102989-linux-64.sh |cut -f1 -d\ ) = a99a63a85fee418d16000a1a51cc70b489755957 && \
  ( sh ascp-install-3.5.4.102989-linux-64.sh )
## No https, so verify sha1


#RUN useradd data
#USER data
ENTRYPOINT ["ascp"]

########################################
# Get the dee2 pipeline for volunteers
########################################
ADD https://raw.githubusercontent.com/markziemann/dee2/master/volunteer_pipeline.sh /tmp
RUN \
  mkdir -p dee/code && \
  cp /tmp/volunteer_pipeline.sh dee/code && \
  cd dee/code && \
  chmod +x volunteer_pipeline.sh && \
  ./volunteer_pipeline.sh

########################################
# Get the dee2 repo
########################################
#RUN git clone https://github.com/markziemann/dee2.git && \
#  cd dee2 && \
#  mkdir code && \
#  cp volunteer_pipeline.sh code && \
#  cd code && \
#  chmod +x volunteer_pipeline.sh && \
#  ./volunteer_pipeline.sh

########################################
# run dee2
########################################
#RUN ["/bin/bash", "-c", "volunteer_pipeline.sh"]

