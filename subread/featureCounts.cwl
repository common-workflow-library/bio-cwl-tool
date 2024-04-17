#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

inputs:
  annotations:
    type: File
    format: [ edam:format_2306, edam:format_1974 ]  # GTF or GFFv2
  mapped_reads:
    type: File
    format: [ edam:format_2572, edam:format_2573 ]  # BAM or SAM

baseCommand: featureCounts

arguments: [-T, $(runtime.cores),
            -a, $(inputs.annotations),
            -o, featurecounts.tsv,
            $(inputs.mapped_reads)]

outputs:
  featurecounts:
    type: File
    format: iana:text/tab-separated-values  # TSV
    outputBinding:
      glob: featurecounts.tsv

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/subread:2.0.6--he4a0461_0
  SoftwareRequirement:
    packages:
      featureCounts:
        specs:
          - https://identifiers.org/rrid/RRID:SCR_012919
          - https://identifiers.org/biotools/featurecounts
          - https://anaconda.org/bioconda/subread

$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
$schemas:
 - https://edamontology.org/EDAM_1.25.owl
