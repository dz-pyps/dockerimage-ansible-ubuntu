# Dockerfile for building Ansible image for Ubuntu (latest), with as few additional software as possible.

# Version  1.0

# Pull base image
FROM ubuntu:latest

LABEL Author="DZ"

ENV SERVICE_DIR=/ansible_service_dir \
    ANSIBLE_CONFIG=${SERVICE_DIR}/ansible.cfg

RUN echo "===> Installing Ansible via pip3..." && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y python3-pip openssh-client vim && \
    pip3 install ansible && \
    echo "===> Installing pip modules..." && \
    pip3 install pywinrm && \
    pip3 install dopy && \
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
# CMD [ "ansible-playbook", "--version" ]
CMD [ "cat" ]