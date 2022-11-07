#!/bin/bash

set -e

function check_deps() {
  test -f $(which jq) || error_exit "jq command not detected in path, please install it"
  test -f $(which kind) || error_exit "kind command not detected in path, please install it"
  test -f $(which yq) || error_exit "yq command not detected in path, please install it"
}

function parse_input() {
  eval "$(jq -r '@sh "export OBJECT=\(.objPath) && export CLUSTER=\(.cluster)"')"
}


function return_output() {
    OBJ=$(kind get kubeconfig --name $CLUSTER | yq . -o json | jq '.[env.OBJECT]|first|.user,.cluster|select(.!=null)')
    echo $OBJ
}

check_deps && parse_input && return_output
