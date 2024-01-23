## Dockerfile for CIO evaluation

FROM ubuntu:22.04

## ----------------------------------------------------------------------------
## STEP 1: Initial set up
## ----------------------------------------------------------------------------

## Install basic packages
RUN apt-get -y update && apt-get -y upgrade && \
    apt-get -y install sudo && \
    apt-get -y install git

## ----------------------------------------------------------------------------
## STEP 2: Clone main tool repository
## ----------------------------------------------------------------------------

RUN git clone https://github.com/counter-optimization/cio.git eval
WORKDIR /eval
RUN git checkout ASPLOS-artifact-summer2024

## ----------------------------------------------------------------------------
## STEP 3: Install clang (project version and baseline)
## ----------------------------------------------------------------------------

## Install LLVM dependencies
RUN apt-get -y install cmake && \
    apt-get -y install ninja-build && \
    apt-get -y install clang

## Build clang all in one step so we can delete unnecessary files afterward
RUN git clone https://github.com/counter-optimization/llvm-project && \
    cd llvm-project && git checkout ASPLOS-artifact-summer2024 && \
    cmake -S llvm -B build -G Ninja -DLLVM_ENABLE_PROJECTS='clang' && \
    cd build && ninja && \
    mkdir /eval/project-build /eval/project-build/bin && \
    cp bin/clang /eval/project-build/bin/clang && \
    mkdir /eval/project-build/lib && \
    cp -r lib/clang /eval/project-build/lib && \
    ninja clean && git checkout baseline && ninja && \
    mkdir /eval/baseline-build /eval/baseline-build/bin && \
    cp bin/clang /eval/baseline-build/bin/clang && \
    mkdir /eval/baseline-build/lib && \
    cp -r lib/clang /eval/baseline-build/lib && \
    cd /eval && rm -rf llvm-project
ENV PROJECT_CC=/eval/project-build/bin/clang
ENV BASELINE_CC=/eval/baseline-build/bin/clang

## ----------------------------------------------------------------------------
## STEP 4: Initialize submodules
## ----------------------------------------------------------------------------

## Install checker dependencies
RUN apt-get -y install opam && \
    opam init --comp=4.14.1 -y && \
    opam install --confirm-level=unsafe-yes bap z3 splay_tree dolog memtrace

## Initialize and build checker
RUN eval $(opam env) && make checker

## Initialize libsodium
RUN make libsodium_init

## ----------------------------------------------------------------------------
## STEP 5: Install remaining dependencies
## ----------------------------------------------------------------------------

# Install runtime python dependencies
RUN apt-get -y install python3 && \
    apt-get -y install pip && \
    pip install matplotlib

## ----------------------------------------------------------------------------
## STEP 6: Set up entrypoint
## ----------------------------------------------------------------------------

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT ./entrypoint.sh
