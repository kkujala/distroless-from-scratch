# How to build `"distroless"` container images from scratch

## How?

This is done with simple `Dockerfiles` which can easily be inspected, modified,
and extended.

## to build?

Building can be done with one's favourite container image building tool, such
as `docker`, or `buildah`.

## `"distroless"` container images

Container images are usually based on some Operating System distribution. They
contain multiple OS packages that are mostly not needed for running an
application in a container, such as a shell.

The `"distroless"` concept only adds to the container image a minimal set of
files from the Operating System distribution to fulfill the requirements for
running an application. The images are based on OS packages from a
distribution, hence the quotes.

## from scratch?

The `scratch` container image is reserved and minimal image for building base
container images. The concept is described well in
[here](https://docs.docker.com/develop/develop-images/baseimages/#create-a-simple-parent-image-using-scratch).

In the `scratch` image the filesystem is initially completely empty. In the
`dockerfiles` a multistage build is used to fetch the OS packages, to exract
the files in them, and to build package metadata.

The multistage build is described in this
[page](https://docs.docker.com/develop/develop-images/multistage-build).

The benefit of using a builder image is that the packages can be easily kept
up to date as only rebuild is needed.

## Why?

These `Dockerfiles` are meant for bootstrapping the base container image
building for the `"distroless"` images for many different OS distributions.

## `Dockerfiles` for OS distributions

The following OS distributions are available.

- Alpine 3
- CentOS 8
- Debian 10
- openSUSE Leap 15

The following base container image types are available.

- `static` is based on `scratch`, and has
  - basic files for the OS
  - CA certificates
  - Time Zone data
  - network configuration

- `base` is based on `static` container image, and has
  - C libraries
  - SSL libraries
  - OpenSSL

- `cc` is based on `base` container image, and has
  - GCC support library
  - OpenMP support
  - C++ standard library

- `java` is based on `cc` container image, and has
  - either OpenJDK 8 or 11
  - library dependencies
  - CA certificates for Java

- `NodeJS` is based on `cc` container image, and has
  - NodeJS
  - library dependencies
  - NPM

The following tags are available.

- `latest` is the vanilla flavor of the container image.
  - For the Java ones the JRE is used.

- `debug` has the `busybox` included for a simple shell environment.
  - For the Java ones the JDK is used.

- `nonroot` has
  - `nonroot` user active
  - the workspace points to `nonroot` user's home folder

- `debug-nonroot`
  - It is configured with both `debug` and `nonroot`.

- `8`, `8-debug`, `8-nonroot`, `8-debug-nonroot`
  - The Java container images are tagged with the version number 8 and the
    other options are appended to it.

- `11`, `11-debug`, `11-nonroot`, `11-debug-nonroot`
  - The Java container images are tagged with the version number 11 and the
    other options are appended to it.

## Build instructions

### Requirements

The utility scripts require the following tools.

- `bash`
- `buildah`
- `podman`
- `shellcheck`
- `tar`
- `vimdiff`

### Building

The utility script fo building can be invoked without parameters `./build.sh`,
or with distribution or distributions defined `./build.sh debian10`.

It will build all the combinations for distributions, types, and tags with
`buildah`. The built images use `OCI` manifest type `v1`.

Alternatively the `Dockerfiles` can be built separately with other tools.

The container images builds are
[reproducable](https://reproducible-builds.org/) in case the package versions
are pinned down.

## Using the `"distroless"` images as base images

### What one needs to know before using the `Dockerfiles`

Please, have a look at the [COPYRIGHT](COPYRIGHT.md), and
[LICENSE](LICENSE.md).

### `CMD` build command in `Dockerfile`

It should be with `["/path/to/file", "argument"]` notation.

For java images it should be with `["/path/to/java/package", "argument"]`
notation.

## Package metadata

### Alpine 3

In the `Alpine 3` container images the root folder has `packages.txt` which
lists the package info for the extracted `APK` packages.

### CentOS 8

In the `CentOS 8` container images the root folder has `packages.txt` which
lists the extracted `RPM` packages. The exception is the `busybox` which is not
extracted from an `RPM` package.

### Debian 10

In the `Debian 10` container images the root folder has `packages.txt` which
lists the package info for the extracted `DEB` packages.

The `packages.txt` file is symbolically linked to `/var/lib/dpkg/status` so
that the package information can be queried from the command line, when the
`debug` containers are used.

```bash
dpkg --list
```

### openSUSE Leap 15

In the `openSUSE Leap 15` container images the root folder has `packages.txt`
which lists the extracted `RPM` packages. The exception is the `busybox` which is
not extracted from an `RPM` package.

## Checking quality

The `Dockerfiles` use `bash` scripts and shell constructs in the `CMD` parts.
The quality of the shell code can be checked with utility script invocation
`./utils/check.sh`.

## Comparing images

In case images need to be compared to see how they differ the utility script
can be invoked.

```bash
./utils/compare.sh \
    localhost/distroless-from-scratch/base-debian10:latest \
    localhost/distroless-from-scratch/base-centos8:latest
```

It will produce a list of commands to compare `inspect` information for the
images, either all layers, or the last layers of the container images.

The extracted layers for the images can be checked in the system's temporary
directory.

## Understanding the content of the images

In the builder image for each distribution the packages can be inspected with
the following commands.

### Alpine 3

The package repository can be updated with a command.

```bash
apk update
```

Packages can be searched with a command.

```bash
apk search package-name
```

Package requirements can be determined with a command.

```bash
apk info --contents package-name
```

Package files can be listed with a command. This requires that the package is
installed.

```bash
repoquery --list package-name
```

Package can be download with a command.

```bash
apk download --output /path/to/derectory package-name
```

Package can be identified for file name with a command. Alternatively a file
can be queried on this [page](https://pkgs.alpinelinux.org/contents).

```bash
apk info --who-owns /path/to/file
```

### CentOS 8

The package repository can be updated with a command.

```bash
yum --assumeyes makecache
```

Packages can be searched with a command.

```bash
yum search package-name
```

Package requirements can be determined with a command.

```bash
yum --assumeyes install yum-utils
repoquery --requires --resolve package-name
```

Package files can be listed with a command.

```bash
repoquery --list package-name
```

Package can be download with a command.

```bash
yum --assumeyes install yum-utils
yumdownloader --assumeyes --downloaddir /path/to/directory package-name
```

Package can be identified for file name with a command.

```bash
yum provides /path/to/file
```

### Debian 10

The package repository can be updated with a command.

```bash
apt update
```

Packages can be searched with a command.

```bash
apt search package-name
```

Package requirements can be determined with a command.

```bash
apt depends package-name
```

Package files can be listed with a command.

```bash
apt --yes install apt-file
apt-file update
apt-file list package-name
```

Package can be download with a command.

```bash
cd /path/to/directory
apt download package-name
```

Package can be identified for file name with a command.

```bash
apt-get --yes install apt-file
apt-file update
apt-file search /path/to/file
```

### OpenSUSE Leap 15

The package repository can be updated with a command.

```bash
zypper refresh
```

Packages can be searched with a command.

```bash
zypper search package-name
```

Package requirements can be determined with a command.

```bash
zypper info --requires package-name
```

Package alternatives can be searched for a requirement with a command.

```bash
zypper search --provides requirement-name
```

Package files can be listed with a command.

```bash
zypper info --provides package-name
```

Package can be download with a command.

```bash
zypper --pkg-cache-dir /path/to/directory download package-name
```

Package can be identified for file name with a command.

```bash
zypper search --file-list /path/to/file
```

## Considerations

The `Dockerfiles` have lists of packages that ensure the functionality. Some of
the packages may not be needed for a particular use case. This means that the
package lists could trimmed down.

Some packages contain unnecessary files, such as executables or manual pages.
For a minimal container image these files could be omitted.

Please, enjoy, and have fun.
