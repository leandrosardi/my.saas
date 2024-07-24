# Use the official Ubuntu 20.04 as a base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install required packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        libpq-dev \
        postgresql-12 postgresql-contrib \
        jq \
        net-tools \
        gnupg2 \
        nginx \
        sshpass \
        bc \
        unzip \
        curl \
        git \
        xvfb

# Set GTM-3 timezone
RUN ln -fs /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Add the blackstack user and configure sudoers
ARG PASSWORD
RUN useradd -m -s /bin/bash blackstack && \
    echo "blackstack:$PASSWORD" | chpasswd && \
    usermod -aG sudo blackstack && \
    echo "blackstack ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Change hostname (this is usually managed outside of Docker)
ARG HOSTNAME
RUN echo "$HOSTNAME" > /etc/hostname

# Configure SSH
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    service ssh restart

# Backup old .postgresql folder and configure PostgreSQL
RUN mv ~/.postgresql ~/.postgresql.$(date +%s) && \
    mkdir ~/.postgresql && \
    sed -i 's/#listen_addresses = '\''localhost'\''/listen_addresses = '\''*'\''/' /etc/postgresql/12/main/postgresql.conf && \
    echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/12/main/pg_hba.conf && \
    chmod 777 /etc/postgresql/12/main/pg_hba.conf && \
    service postgresql restart && \
    sudo -u postgres createuser -s -i -d -r -l -w blackstack && \
    sudo -u postgres psql -c "ALTER ROLE blackstack WITH PASSWORD '$PASSWORD';" && \
    sudo -u postgres createdb -O blackstack blackstack

# Download and install CockroachDB CLI
RUN curl https://binaries.cockroachdb.com/cockroach-v21.2.10.linux-amd64.tgz | tar -xz && \
    cp cockroach-v21.2.10.linux-amd64/cockroach /usr/local/bin/

# Install RVM and Ruby
RUN gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    curl -sSL https://get.rvm.io -o rvm.sh && \
    bash rvm.sh && \
    usermod -a -G rvm blackstack && \
    source /etc/profile.d/rvm.sh && \
    echo 'source /etc/profile.d/rvm.sh' >> /etc/bash.bashrc && \
    rvm install 3.1.2 && \
    rvm --default use 3.1.2

# Set up workspace
RUN mkdir -p /home/blackstack/code

# Install AdsPower
RUN wget https://version.adspower.net/software/linux-x64-global/AdsPower-Global-5.9.14-x64.deb && \
    chmod 777 AdsPower-Global-5.9.14-x64.deb && \
    dpkg -i AdsPower-Global-5.9.14-x64.deb && \
    apt -y --fix-broken install && \
    rm AdsPower-Global-5.9.14-x64.deb

# Install ChromeDriver
RUN wget https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/116.0.5845.96/linux64/chromedriver-linux64.zip && \
    chmod 777 chromedriver-linux64.zip && \
    unzip chromedriver-linux64.zip && \
    mv chromedriver-linux64/* /usr/bin && \
    chown blackstack:blackstack /usr/bin/chromedriver && \
    chmod +x /usr/bin/chromedriver && \
    rm -rf chromedriver-linux64.zip chromedriver-linux64

# Create flag file
RUN touch /home/blackstack/.blackstack

# Set user to blackstack
USER blackstack

# Set the working directory
WORKDIR /home/blackstack

# Run bash as the default command
CMD ["bash"]
