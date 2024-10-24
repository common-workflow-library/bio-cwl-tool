class: CommandLineTool
cwlVersion: v1.0

hints:
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/snpsift:4.3.1t--2
    
doc:   "SnpSift Extract Fields <http://snpeff.sourceforge.net/SnpSift.html#Extract> selects columns from a VCF dataset into a Tab-delimited format."

stdout: $(inputs.input_vcf.nameroot).tsv
baseCommand: [SnpSift, -Xmx6G, extractFields]
arguments: 
  - valueFrom: \"$(inputs.empty_text)\"
    prefix: -e
    position: 4
inputs:
  - id: input_vcf
    type: File 
    inputBinding:
      position: 1

  - id: extractFields
    type: string[]?
    default: "CHROM POS ID REF ALT FILTER"
    doc: "Separated by spaces"
    inputBinding:
      position: 2
      
  - id: separator
    type: string?
    doc: "Separate multiple fields in one column with this character, e.g. a comma, rather than a column for each of the multiple values"
    inputBinding:
      prefix: -s
      position: 3
      
  - id: empty_text
    type: string?
    doc: "Represent empty fields with this value, rather than leaving them blank"
   # inputBinding:
   #   prefix: -e
   #   position: 4

outputs: 
  - id: out
    type: stdout
requirements:
  - class: InlineJavascriptRequirement
