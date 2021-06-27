# Debian 10 (Buster) will be used as base image for the build container - https://hub.docker.com/_/debian
# Here an explicit tag will be used but the "debian:buster" tag should work as well.
#
# debian:buster-20200803
# DIGEST:sha256:8672fb9ccf181c3bf7e1c10c294af71700e42ac85a42ec035c1855da45116520

######################################################
### ENV                                            ###
######################################################
# Set the base image and define "env" as the alias
FROM debian:buster-20200803 AS env

# Install the required tools
#
# The "texlive" package. See also https://packages.debian.org/search?keywords=texlive&searchon=names&suite=buster&section=all
#
# The "texlive-lang-german" package is added to support German. See also https://packages.debian.org/buster/texlive-lang-german
# The package "texlive-full" contains almost everything, but is quite large.
#
# sudo apt-cache search <package> e.g. sudo apt-cache search amsmath:
#     texlive-latex-base - TeX Live: basic LaTeX-Packages
#     texlive-latex-recommended - TeX Live: recommended LaTeX-Packages
#     texlive-latex-extra - TeX Live: LaTeX additional packages
#     texlive-science - TeX Live: Mathematics, natural sciences, computer science packages
#     texlive-lang-english - TeX Live: US and UK English
#     texlive-lang-italian - TeX Live: Italian
#
# latexmk: latexmk ensures that we run LaTeX and BibTeX (or other similar programs) the right number of times. latexmk reads a configuration file called latexmkrc that contains custom rules for building your project.
RUN /bin/bash -c set -o pipefail \
  && apt-get update \
  && apt-get install -y \
  texlive \
  texlive-lang-german \
  texlive-latex-recommended \
  texlive-latex-extra \
  texlive-xetex \
  biber \
  latexmk
#  texlive-full

######################################################
### BUILD                                          ###
######################################################
# Set the build image and define "build" as the alias
FROM env AS build

# Copy project source code to build container
COPY ./ /basics
COPY ./.latexmkrc /root/

# Execute build script to compile project
RUN /bin/bash /basics/build.sh
