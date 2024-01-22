# README

This is the artifact evaluation repository for [cio](https://github.com/counter-optimization/cio).
You can use the Docker image contained in this repository to build and evaluate `cio` on
[libsodium](https://libsodium.org/).
For all artifacts associated with the `cio` tool, see https://github.com/counter-optimization.

## Requirements

### Hardware Dependencies

`cio` must be run on an x86_64 machine, as the `cio` mitigations have currently only been
implemented for x86_64.

Building the Docker image from scratch requires approximately 115 GB of disk space, primarily due
to the size of LLVM. Once built, or if pre-built, the Docker container requires approximately
15 GB for the image (8.74 GB) and the evaluation script outputs combined.

To run the evaluation script in a reasonable time frame, we recommend approximately TODO GB of
memory and 1 CPU.

### Software Dependencies

[Docker](https://www.docker.com/) is required to use the provided image.
The Docker image installs all necessary software dependencies, including the `cio` artifacts,
the [Binary Analysis Platform (BAP)](https://github.com/BinaryAnalysisPlatform/bap), Python, etc.

## Instructions

If Docker is not running, start the Docker daemon:

```
sudo systemctl start docker
```

### Building the image

#### [RECOMMENDED] Pull the pre-built image

Because the image downloads and compiles LLVM `clang` from scratch, building it requires a very
high amount of resources (>128GB memory, >100GB storage). 
It is highly recommended to pull the pre-built image directly:

```
TODO
```

#### Build the image from scratch

WARNING: if you do not have sufficient storage and memory on your device, this build will fail.

Navigate to the directory containing the Dockerfile and `entrypoint.sh`. Run:

```
docker build  -t cio:asplos24aec .
```

### Running the container

Run the container in interactive mode:

```
docker run -it cio:asplos24aec
```

In this mode, you can freely navigate the installed artifacts.
The project version of `clang` is at `$PROJECT_CC`, and a baseline (unmodified) version
of `clang` is at `$BASELINE_CC`.

### Basic setup test

Run the container in interactive mode.
Once you have entered the container, run:

```
make CC=$PROJECT_CC test
```

If the command finished successfully, you should see the following output:

```
1 + 1 = 2. Done!
```

### Evaluation script

`eval.sh` runs the full evaluation of `cio` on libsodium as was reported in the paper.
To run it, use the following command:

```
./eval.sh -c $PROJECT_CC -b $BASELINE_CC
```

Be aware, this script takes a long time to run. It is recommended to run the process in
the background and send its output to a log file, e.g.:

```
./eval.sh -c $PROJECT_CC -b $BASELINE_CC &> eval.log &
```

You can then follow along with `tail -f eval.log`.