#!/bin/bash

args=("$@")

eval $(opam env)

/bin/bash "${args[@]}"
