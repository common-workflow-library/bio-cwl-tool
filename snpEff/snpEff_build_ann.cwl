class: CommandLineTool
cwlVersion: v1.0
baseCommand: [bash, commands.sh]
doc: 'SnpEff is a variant annotation and effect prediction tool. It annotates and predicts the effects of genetic variants (such as amino acid changes). Use references genomes or import the genbank file of another genome.'

inputs:
  - id: importGenome
    type: boolean
    doc: 'import your own genome (genbank)'
  - id: genome_reference
    type: string

  - id: bankfile
    type: File?
    doc: 'import your own genome'

  - id: sequence
    type: File

  - id: inputFormat
    type:
      - 'null'
      - type: enum
        symbols:
          - vcf
          - bed
    default: vcf
  - id: outputFormat
    type:
      - 'null'
      - type: enum
        symbols:
          - vcf
          - bed
          - gatk
          - bedAnn
    default: vcf

  - id: udLength
    type: int
    doc: 'Set upstream downstream interval length (in bases). 0 base: No upstream / downstream intervals'

## reports:
  - id: html_report
    type: boolean?

  - id: csvFile
    type: boolean?
  - id: noStats
    type: boolean?

## Annotations options:
  - id: formatEff
    type: boolean?
    doc: "Use 'EFF' field compatible with older versions (instead of 'ANN')"
  - id: classic
    type: boolean?
    doc: "Use Classic Effect names and amino acid variant annotations (NON_SYNONYMOUS_CODING vs missense_variant and G180R vs p.Gly180Arg/c.538G>C)"
  - id: sequenceOntology
    type: boolean?
    doc: "Override classic and use Sequence Ontolgy terms for effects (missense_variant vs NON_SYNONYMOUS_CODING)"
  - id: hgvs
    type: boolean?
    default: true
    doc: "Override classic and use HGVS annotations for amino acid annotations (p.Gly180Arg/c.538G>C vs G180R)"
  - id: noShiftHgvs
    type: boolean?
    doc: "Do not shift variants according to HGVS notation (most 3prime end)"
  - id: noHgvs
    type: boolean?
    doc: "Do not add HGVS annotations"
  - id: geneId
    type: boolean?
    doc: "Use gene ID instead of gene name (VCF output). Default: false"
  - id: lof
    type: boolean?
    doc: "Add loss of function (LOF) and nonsense mediated decay (NMD) tags"
  - id: noLof
    type: boolean?
    doc: "Do not add LOF and NMD annotations"
  - id: cancer
    type: boolean?
    inputBinding:
      prefix: -cancer
    doc: "Perform 'cancer' comparisons (somatic vs. germline)"
  - id: cancerSamples
    type: File?
    doc: "<file> : Two column TXT file defining 'oringinal \t derived' samples."
  - id: oicr
    type: boolean?
    doc: "Add OICR tag in VCF file. Default: false"

## Database options:

  - id: canon
    type: boolean?
    doc: "Only use canonical transcripts"
  - id: motif
    type: boolean?
    doc: "Annotate using motifs (requires Motif database)."
  - id: noMotif
    type: boolean?
    doc: "Disable motif annotations"
  - id: noNextProt
    type: boolean?
    doc: "Disable NextProt annotations"
  - id: nextProt
    type: boolean?
    doc: "Annotate using NextProt (requires NextProt database)."
  - id: noGenome
    type: boolean?
    doc: "Do not load any genomic database (e.g. annotate using custom files)."
  - id: onlyProtein
    type: boolean?
    doc: "Only use protein coding transcripts. Default: false"
  - id: transcripts
    type: File?
    doc: '<file.txt>   Only use the transcripts in this file. Format: One transcript ID per line.'

  # à rendre facultatif:
  - id: interval
    type: File[]?
      #- type: null
      #type: array
      #items: File
    doc: 'Use a custom intervals in TXT/BED/BigBed/VCF/GFF file (you may use this option many times).'
  - id: spliceRegionExonSize
    type: int?
    default: 3
  - id: spliceRegionIntronMax
    type: int?
    default: 8
  - id: spliceRegionIntronMin
    type: int?
    default: 8
  - id: spliceSiteSize
    type: int?
    default: 2
  - id: onlyReg
    type: boolean?
    doc: "Only use regulation tracks."
  - id: strict
    type: boolean?
    doc: "Only use 'validated' transcripts (i.e. sequence has been checked). Default: false"
## Results filter options :

  - id: filterInterval
    type: File[]?
    doc: "Only analyze changes that intersect with the intervals specified in this file (you may use this option many times)"
  - id: no_downstream
    type: boolean?
    doc: " Do not show DOWNSTREAM changes"
  - id: no_intergenic
    type: boolean?
    doc: "Do not show INTERGENIC changes"
  - id: no_intron
    type: boolean?
    doc: "Do not show INTRON changes"
  - id: no_upstream
    type: boolean?
    doc: "Do not show UPSTREAM changes"
  - id: no_utr
    type: boolean?
    doc: "Do not show 5_PRIME_UTR or 3_PRIME_UTR changes"
  - id: no_EffectType
    type: boolean?
    doc: "Do not show 'EffectType'. This option can be used several times."

outputs:
  - id: snpeff_output
    type: File?
    # format $(inputs.outputFormat)
    outputBinding:
      glob: "*.$(inputs.outputFormat)"
  - id: statsFile
    type: File?
    outputBinding:
      glob: "*.html"
  - id: csvFile
    type: File?
    outputBinding:
      glob: '*.csv'
  - id: genes
    type: File?
    outputBinding:
      glob: '*.txt'
requirements:
  - class: DockerRequirement
    dockerPull: biocontainers/snpeff:v4.1k_cv3
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: "$({class: 'Directory', listing: []})"
        entryname: $(inputs.genome_reference)
        writable: true
      - entryname: $(inputs.genome_reference)/genes.gbk
        entry: $(inputs.bankfile)
      - entryname: commands.sh
        entry: |-
          #!/bin/bash
          ###########################
          #cd /home/biodocker/bin/snpEff
          cp /home/biodocker/bin/snpEff/snpEff.config .
          ls -R

          if [ $(inputs.importGenome) ]
          then
              echo $(inputs.genome_reference).genome=$(inputs.genome_reference) >> snpEff.config
              snpEff build -v -c snpEff.config -dataDir . -configOption $(inputs.genome_reference).genome=$(inputs.genome_reference) -genbank $(inputs.genome_reference)
              grep covid19 snpEff.config
          fi

          ${
          var command=
          "snpEff ann -v -c snpEff.config -dataDir .  -i "+ (inputs.inputFormat)+" -o "+(inputs.outputFormat)+" -upDownStreamLen "+(inputs.udLength)+" -spliceRegionExonSize "+(inputs.spliceRegionExonSize)+" -spliceRegionIntronMax  "+(inputs.spliceRegionIntronMax)+" -spliceRegionIntronMin "+(inputs.spliceRegionIntronMin)+" -spliceSiteSize "+(inputs.spliceSiteSize)

          if (inputs.csvFile){
            command+= " -csvFile "
          }
          if (inputs.html_report){
            command+=" -s "
          }
          if (inputs.noStats){
            command+=" -noStats "
          }
          if (inputs.formatEff){
            command+=" -formatEff "
          }
          if (inputs.classic){
            command+=" -classic "
          }
          if (inputs.sequenceOntology){
            command+=" -sequenceOntology "
          }
          if (inputs.hgvs){
            command+=" -hgvs "
          }
          if (inputs.noShiftHgvs){
            command+=" -noShiftHgvs "
          }
          if (inputs.noHgvs){
            command+=" -noHgvs "
          }
          if (inputs.geneId){
            command+= " -geneId"
          }
          if (inputs.lof){
            command+=" -lof "
          }
          if (inputs.noLof){
            command+=" -noLof "
          }
          if (inputs.cancer){
            command+=" -cancer "
          }
          if (inputs.oicr){
            command+=" -oicr "
          }
          if (inputs.cancerSamples!=null){
            command+= " -cancerSamples "+(inputs.cancerSamples.path)
          }
          if (inputs.canon){
            command+= " -canon "
          }
          if (inputs.motif){
            command+= " -motif "
          }
          if (inputs.noMotif){
            command+= " -noMotif "
          }
          if (inputs.noNextProt){
            command+=" -noNextProt "
          }
          if (inputs.nextProt){
            command+=" -nextProt "
          }
          if (inputs.noGenome){
            command+=" -noGenome "
          }
          if (inputs.onlyProtein){
            command+=" -onlyProtein "
          }
          if (inputs.onlyReg){
            command+=" -onlyReg "
          }
          if (inputs.strict){
            command+=" -strict "
          }
          if (inputs.no_downstream){
            command+= " -no-downstream "
          }
          if (inputs.no_intergenic){
            command+= " -no-intergenic "
          }
          if (inputs.no_intron){
            command+= " -no-intron "
          }
          if (inputs.no_upstream){
            command+= " -no-upstream "
          }
          if (inputs.no_utr){
            command+= " -no-utr "
          }
          if (inputs.no_EffectType){
            command+= " -no EffectType "
          }
          if (inputs.transcripts!=null){
           for (var i=0; i< inputs.transcripts.length; i++){
             command+= " -onlyTr "+inputs.transcripts[i].path
           }
          }
          if (inputs.filterInterval!=null){
           for (var i=0; i< inputs.filterInterval.length; i++){
             command+= " -filterInterval "+inputs.filterInterval[i].path
           }
          }
          if (inputs.interval!=null){
           for (var i=0; i< inputs.interval.length; i++){
             command+= " -interval "+inputs.interval[i].path
           }
          }
          command+=(inputs.genome_reference)+" "+(inputs.sequence.path)+" > "+(inputs.sequence.nameroot)+".ann."+(inputs.outputFormat)

          return command;
          }
