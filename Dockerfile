# Use a base image with micromamba and common bioinformatics tools
FROM continuumio/miniconda3:latest AS base

# Install micromamba
RUN conda install -y micromamba

# Create and activate VarRNA environment
COPY dependencies/mamba_environment.yml /tmp/mamba_environment.yml
RUN micromamba env create -f /tmp/mamba_environment.yml -n varrna
RUN micromamba activate varrna

# Install Snakemake
RUN pip install snakemake

# Copy VarRNA source and resources
COPY . /varrna
WORKDIR /varrna

# Download resources (optional: pre-download in build stage)
RUN aws s3 sync s3://igm-public-dropbox/varrna/resources/ resources/ --no-sign-request

# Install required tools (if not in environment)
RUN conda install -y star gatk salmon annovar

# Set entrypoint to run Snakemake workflow
ENTRYPOINT ["snakemake", "--configfile", "config/config.yaml", "--use-conda", "--config", "resources_dir=resources"]
