cwlVersion: v1.0
class: CommandLineTool

# Metadata
id: qualimap
label: qualimap-qc
doc: This is qualimap CWL tool definition http://qualimap.bioinfo.cipf.es/

# Requirements
requirements:
  - class: ResourceRequirement
    ramMin: 4000
    coresMin: 1
  - class: DockerRequirement
    dockerPull: 'quay.io/biocontainers/qualimap:2.2.2d--1'
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

# Base command
baseCommand: [ "qualimap"]

# Perform RNA-seq QC analysis on paired-end data http://qualimap.bioinfo.cipf.es/doc_html/command_line.html
# Desired java memory size can be set using --java-mem-size option
arguments:
  - valueFrom: |-
      rnaseq --paired --java-mem-size="$(inputs.javamem)"
    shellQuote: false

inputs:
  javamem:
    type: string
    doc: |
      Set desired Java heap memory size

  outdir:
    type: string
    inputBinding:
      prefix: "-outdir"
    doc: |
      Output folder for HTML report and raw data.

  algo:
    type: string
    inputBinding:
      prefix: "-a"
    doc: |
      Counting algorithm:
      uniquely-mapped-reads(default) or proportional.

  inputBam:
    type: File
    secondaryFiles: .bai
    inputBinding:
      prefix: "-bam"
    doc: |
      Input mapping file in BAM format.

  seqProtocol:
    type: string
    inputBinding:
      prefix: "-p"
    doc: |
      Sequencing library protocol:
      strand-specific-forward, strand-specific-reverse or 
      non-strand-specific (default).
  
  gtf:
    type: File
    inputBinding:
      prefix: "-gtf"
    doc: |
      Region file in GTF, GFF or BED format. 
      If GTF format is provided, counting is based on
      attributes, otherwise based on feature name.

outputs:
  qualimapQC:
    type: Directory
    outputBinding:
      glob: "$(inputs.outdir)" 

$namespaces:
  s: http://schema.org/

$schemas:
- http://schema.org/version/latest/schema.rdf

s:name: "qualimap_qc"
s:codeRepository: https://github.com/common-workflow-library/bio-cwl-tools
s:license: http://www.apache.org/licenses/LICENSE-2.0

s:isPartOf:
  class: s:CreativeWork
  s:name: Common Workflow Language
  s:url: http://commonwl.org/

s:creator:
- class: s:Organization
  s:legalName: "University of Melbourne Centre for Cancer Research"
  s:member:
  - class: s:Person
    s:name: Dr. Sehrish Kanwal
    s:email: mailto:kanwals@unimelb.edu.au
  

