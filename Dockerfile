# Dockerfile for building Ansible image for Ubuntu (latest), with some additional software.

# Version  1.0

# Pull base image
FROM ubuntu:latest

LABEL Author="DZ"

ENV SERVICE_DIR=/ansible_service_dir \
    ANSIBLE_CONFIG=${SERVICE_DIR}/ansible.cfg

RUN echo "===> Installing Ansible via pip3..." && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q krb5-user python3-pip openssh-client vim rsync dnsutils iputils-ping net-tools python-dev libkrb5-dev p7zip-full cpio gzip genisoimage whois pwgen wget fakeroot isolinux xorriso dos2unix && \
    pip3 install ansible && \
    echo "===> Installing pip modules..." && \
    pip3 install pywinrm && \
    pip3 install pywinrm[kerberos] && \
    pip3 install dopy && \
    pip3 install pyOpenSSL && \
    pip3 install jmespath && \
    echo "===> creating some directories and populating ansible.cfg..." && \
    mkdir -p ${SERVICE_DIR} && mkdir -p /ansible_workflows && \
# ansible.cfg in a separate folder should be done on windows containers due to 777 permissions on bind mount target folder inside a container (ansible doesn't like that)
# Printf command should really be a one-liner, but it is followed by 'sed' only for visual simplicity in this Dockerfile
    printf '[defaults]\n \
    inventory = ./inventory\n \
    ssh_args = -o ForwardAgent=yes\n \
    vault_password_file = ./vault_password_file\n \
    jinja2_extensions = jinja2.ext.do' \
    > ${SERVICE_DIR}/ansible.cfg.pre \
# Shell opens (and truncates) the file before running the command. '>' operator will result in a target file being empty, hence we use a 'mediator'
 && sed 's/    //g' ${SERVICE_DIR}/ansible.cfg.pre > ${SERVICE_DIR}/ansible.cfg \
 && rm -rf ${SERVICE_DIR}/ansible.cfg.pre

WORKDIR /ansible_workflows

# Default command: Display 'ansible-playbook' version
CMD [ "ansible-playbook", "--version" ]
# CMD [ "cat" ]