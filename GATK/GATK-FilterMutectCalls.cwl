#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/gatk4:4.1.3.0--0
  SoftwareRequirement:
    packages:
      gatk:
        specs:
          - https://identifiers.org/biotools/gatk
          - https://anaconda.org/bioconda/gatk4
        version: [ "4.1.3.0" ]

inputs:
  # REQUIRED ARGS

  InputFile:
    type: File
    inputBinding:
      prefix: "--V"
    secondaryFiles:
      - .stats

  Reference:
    type: File
    inputBinding:
      prefix: "-R"
    secondaryFiles:
      - .dict
      - .fai

  Output:
    type: string
    default: "filtered.vcf.gz"
    inputBinding:
      prefix: "--O"
      valueFrom: "filtered.vcf.gz"

  # OPTIONAL ARGS
  ContaminationTable:
    type: File?
    inputBinding:
      prefix: "--contamination-table"

baseCommand: ["/gatk/gatk"]

arguments:
  - valueFrom: "FilterMutectCalls"
    position: -1

outputs:
  filteredVCF:
    type: File
    format: edam:format_3016  # VCF
    outputBinding:
      glob: "filtered.vcf.gz"

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - https://edamontology.org/EDAM_1.18.owl
