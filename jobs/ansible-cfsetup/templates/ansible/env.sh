#!/usr/bin/env bash

if [ -z ${ANSIBLE_ROLES_PATH+x} ]; then
    ANSIBLE_ROLES_PATH=/var/vcap/packages/ansible-cfsetup/roles
else
    ANSIBLE_ROLES_PATH=/var/vcap/packages/ansible-cfsetup/roles:${ANSIBLE_ROLES_PATH}
fi
export ANSIBLE_ROLES_PATH

if [ -z ${ANSIBLE_LIBRARY+x} ]; then
    ANSIBLE_LIBRARY=/var/vcap/packages/ansible-cfsetup/library
else
    ANSIBLE_LIBRARY=/var/vcap/packages/ansible-cfsetup/library:${ANSIBLE_LIBRARY}
fi
export ANSIBLE_LIBRARY
