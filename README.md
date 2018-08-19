# dockerimage-ansible-ubuntu

```docker
docker run --user $(id -u):$(id -g) -it --name ansible_test1 \
--mount type=bind,source=$PWD,target=/ansible_workflows \
--mount type=bind,source=$HOME/.ssh/known_hosts,target=/root/.ssh/known_hosts \
--mount type=bind,source=$HOME/.ssh/id_rsa.pub,target=/root/.ssh/id_rsa.pub,readonly \
--mount type=bind,source=$PWD/.ansible_env,target=/root/.ansible_env \
-v $SSH_AUTH_SOCK:/ssh-agent \
-v /etc/passwd:/etc/passwd \
-v /etc/group:/etc/group \
--env SSH_AUTH_SOCK=/ssh-agent dzpy/ansible_ubuntu:latest \
bash
```