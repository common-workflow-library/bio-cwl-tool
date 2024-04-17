#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

label: |
  map medium and long reads (greater than 100 bp) against reference genome

inputs:
  reference_genome:
    type: File
    label: "Reference genome sequences, optionally already indexed for BWA-Mem2."
    format: edam:format_1929 # FASTA
    secondaryFiles:
     - .bwt.2bit.64?
     - .ann?
     - .amb?
     - .pac?
     - ".0123?"
  paired_reads_1:
    type: File
    label: "First (forward) set of the paired reads"
    format:
       - edam:format_1929 # FASTA
       - edam:format_1932 # FASTQ-sanger
  paired_reads_2:
    type: File
    label: "Second (reverse) set of the paired reads"
    format:
       - edam:format_1929 # FASTA
       - edam:format_1932 # FASTQ-sanger
  do_auto_name:
    type: boolean
    default: False
    label: "Auto-assign read groups"
    doc: "If true, use the file name to automatically assign the read groups value."
  read_group:
    type: ReadGroupType.yml#ReadGroupDetails?
    label: "Specify read group details manually."
  sort_mode:
    type:
      type: enum
      symbols: [ coordinate, name, unsorted ]
    label: How to sort the alignments, if at all
    doc: |
      * coordinate: Sort by chromosomal coordinates
      * name: Sort by read names  (i.e., the QNAME field)
      * unsorted: Not sorted (sorted as input)
    default: coordinate

outputs:
  alignments:
    type: File
    format: edam:format_2572  # BAM
    label: "Alignments of the reads to the references genome"
    outputSource: [ sort/sorted_alignments, convert_unsorted_alignments_to_bam/bam ]
    pickValue: the_only_non_null

steps:
  index_genome:
    run: BWA-Mem2-index.cwl
    label: "Index the reference genome, if it isn't already indexed"
    in:
      sequences: reference_genome
    when: |
      $(inputs.sequences.secondaryFiles !== undefined)
    out: [ indexed_sequences ]
  compute_read_group_header:
    run: ReadGroup.cwl
    when: $(inputs.do_auto_name !== null || inputs.details !== null)
    in:
      do_auto_name: do_auto_name
      details: read_group
      input1: paired_reads_1
      input2: paired_reads_2
    out: [ read_group_name ]
  align:
    run: BWA-Mem2.cwl
    in:
      reference_genome:
        source: [ index_genome/indexed_sequences, reference_genome ]
        pickValue: first_non_null
      reads: paired_reads_1
      paired_reads_2: paired_reads_2
      read_group_header_line: compute_read_group_header/read_group_name
    out: [ aligned_reads ]
  sort:
    run: ../samtools/samtools_sort.cwl
    when: $(inputs.sort_mode !== "unsorted")
    label: "Sort the reads, if requested"
    in:
      sort_mode: sort_mode
      by_name:
        source: sort_mode
        valueFrom: '$(self === "name" ? true : false)'
      unsorted_alignments: align/aligned_reads
      force_format:
        default: BAM
    out: [ sorted_alignments ]
  convert_unsorted_alignments_to_bam:
    run: ../samtools/samtools_view_sam2bam.cwl
    when: $(inputs.sort_mode === "unsorted")
    label: "If not sorting the reads; convert textual alignments (SAM) to binary (BAM) format"
    in:
      sort_mode: sort_mode
      sam: align/aligned_reads 
    out: [ bam ]

requirements:
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ReadGroupType.yml
 
$namespaces:
  edam: http://edamontology.org/
$schemas:
  - https://edamontology.org/EDAM_1.18.owl
