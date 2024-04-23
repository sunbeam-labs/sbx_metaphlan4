<img src="https://github.com/sunbeam-labs/sunbeam/blob/stable/docs/images/sunbeam_logo.gif" width=120, height=120 align="left" />

# sbx_metaphlan4

<!-- Badges start -->
[![Tests](https://github.com/scottdaniel/sbx_metaphlan4/actions/workflows/tests.yml/badge.svg)](https://github.com/scottdaniel/sbx_metaphlan4/actions/workflows/tests.yml)
[![Super-Linter](https://github.com/scottdaniel/sbx_metaphlan4/actions/workflows/linters.yml/badge.svg)](https://github.com/scottdaniel/sbx_metaphlan4/actions/workflows/linters.yml)
<!-- Badges end -->

## Introduction

sbx_metaphlan4 is a [sunbeam](https://github.com/sunbeam-labs/sunbeam) extension for profiling the composition of microbial communities (Bacteria, Archaea and Eukaryotes) from metagenomic shotgun sequencing data (i.e. not 16S) at the species-level. The pipeline uses [MetaPhlAn4](https://huttenhower.sph.harvard.edu/metaphlan/).

## Installation

Extension install is as simple as passing the extension's URL on GitHub to `sunbeam extend`:

    sunbeam extend https://github.com/sunbeam-labs/sbx_metaphlan4

Any user-modifiable parameters specified in `config.yml` are automatically added on `sunbeam init`. If you're installing an extension in a project where you already have a config file, run the following to add the options for your newly added extension to your config (the `-i` flag means in-place config file modification; remove the `-i` flag to see the new config in stdout):

    sunbeam config update -i /path/to/project/sunbeam_config.yml

Installation instructions for older versions of Sunbeam are included at the end of this README.

## Running

To run an extension, simply run Sunbeam as usual with your extension's target rule specified:

    sunbeam run --profile /path/to/project/ example_rule

### Options for config.yml

  - threads: Number of threads to use
  - dbdir: Path to the directory the MetaPhlAn database is in (i.e. /path/to/db/)
  - dbname: Name of the MetaPhlAn database (i.e. mpa_db)
  - profile_strain: Profile strain to use with extract_markers.py and strainphlan
  - reference_genome: A reference genome
    
## Installing an extension (legacy instructions for sunbeam <3.0)

Installing an extension is as simple as cloning (or moving) your extension directory into the sunbeam/extensions/ folder, installing requirements through Conda, and adding the new options to your existing configuration file: 

    git clone https://github.com/sunbeam-labs/sbx_metaphlan4 sunbeam/extensions/sbx_metaphlan4
    cat sunbeam/extensions/sbx_metaphlan4/config.yml >> sunbeam_config.yml

## Issues with pipeline

Please post any issues with this extension [here](https://github.com/scottdaniel/sbx_metaphlan4/issues).
