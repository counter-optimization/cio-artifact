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

To run the evaluation script in a reasonable time frame, we recommend approximately 32 GB of memory, e.g., on an AWS m7a.4xlarge instance.

### Software Dependencies

[Docker](https://www.docker.com/) is required to use the provided image.
The Docker image installs all necessary software dependencies, including the `cio` artifacts,
the [Binary Analysis Platform (BAP)](https://github.com/BinaryAnalysisPlatform/bap), Python, etc.

## Instructions

If Docker is not running, start the Docker daemon:

```
sudo systemctl start docker
```

Note that if your user does not have sufficient permissions, you may need to run the below `docker`
commands with `sudo`.

### Getting the image

#### [RECOMMENDED] Load the pre-built image

We highly recommend downloading the pre-built image (8.4G) from https://zenodo.org/records/10594315.
Once downloaded, load the image with:

```
docker load -i cio-asplos24aec.tar.gz
```

You will need about 30GB total disk space for the `tar` file, the loaded image, and the artifact
outputs.

#### Build the image from Dockerfile

If you are unable to download or use the pre-built image, then you can try building the image from
the Dockerfile.

WARNING: Because the image downloads and builds LLVM (twice!), building from the Dockerfile
requires a massive amount of space (~115 GB), plus a sizeable amount of memory and CPUs to build in
a reasonable timeframe.

If you meet these requirements, clone this repository and build:

```
cd aec && docker build  -t cio:asplos24aec .
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

Once you have entered the container, run:

```
make CC=$PROJECT_CC test
```

If the command finished successfully, you should see the following at the end of the output:

```
1 + 1 = 2. Done!
```

### Evaluation script

`eval.sh` runs the full evaluation of `cio` on libsodium.
Run it with the following command:

```
./eval.sh -c $PROJECT_CC -b $BASELINE_CC
```

Be aware, this script takes a long time to run (~3 hours with 32GB of memory).
It is recommended to run the process in the background and send its output to a log file, e.g.:

```
./eval.sh -c $PROJECT_CC -b $BASELINE_CC &> eval.log &
```

You can then follow along with `tail -f eval.log`.

Eval script outputs are placed in a timestamped
output folder `YYYY-MM-DD-HH:MM:SS-XXX-eval`, with a symlink at `latest-eval-dir`.
`cio` build outputs can be found in timestamped folders `YYYY-MM-DD-HH:MM:SS-XXX-cio-build`.

By default, `eval.sh` does not run the double-checking phase.
To enable this phase, remove the `--skip-double-check` flag from line 168 of the Makefile.
Be aware that with double-checking enabled, the full evaluation script will take roughly twice as long to run (>6-8 hours).
