## Dockerfile for CIO evaluation

FROM ubuntu:22.04

## ----------------------------------------------------------------------------
## STEP 1: Initial set up
## ----------------------------------------------------------------------------

## Install basic packages
RUN apt-get -y update && apt-get -y upgrade && \
    apt-get -y install sudo && \
    apt-get -y install git && \
    apt-get -y install python3

## Install LLVM dependencies
RUN apt-get -y install cmake && \
    apt-get -y install ninja-build && \
    apt-get -y install clang

## Install checker dependencies
RUN apt-get -y install opam && \
    opam init --comp=4.14.1 -y && \
    opam install --confirm-level=unsafe-yes bap z3

## ----------------------------------------------------------------------------
## STEP 2: Clone main tool repository
## ----------------------------------------------------------------------------

RUN git clone https://github.com/counter-optimization/cio.git eval
WORKDIR /eval

## ----------------------------------------------------------------------------
## STEP 3: Install clang (project version and baseline)
## ----------------------------------------------------------------------------

## Build clang all in one step so we can delete unnecessary files afterward
RUN git clone https://github.com/Flandini/llvm-project.git && \
    cd llvm-project && \
    cmake -S llvm -B build -G Ninja -DLLVM_ENABLE_PROJECTS='clang' && \
    cd build && ninja && \
    cp bin/clang /eval/project-clang && \
    ninja clean && git checkout baseline && ninja && \
    cp bin/clang /eval/baseline-clang && \
    cd /eval && rm -rf llvm-project
ENV PROJECT_CC=/eval/project-clang
ENV BASELINE_CC=/eval/baseline-clang

## ----------------------------------------------------------------------------
## STEP 4: Initialize submodules
## ----------------------------------------------------------------------------

## Initialize and build checker
RUN eval $(opam env) && make checker

## Initialize libsodium
RUN make libsodium_init

## ----------------------------------------------------------------------------
## STEP 5: Set up entrypoint
## ----------------------------------------------------------------------------

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT ./entrypoint.sh
