#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: odgi sort
doc: variation graph sorts

hints:
  SoftwareRequirement:
    packages:
      odgi:
        version: [ "0.4.1" ]
  ResourceRequirement:
    coresMin: 8
  DockerRequirement:
    #dockerPull: quay.io/biocontainers/odgi:0.3--py37h8b12597_0
    dockerImageId: odgi:latest
    dockerFile: |
      FROM debian:stable-slim
      WORKDIR /usr/src/app
      RUN apt-get update && apt-get install -y git bash cmake make g++ python-dev && rm -rf /var/lib/apt/lists/*
      RUN git clone --recursive https://github.com/vgteam/odgi.git
      RUN cd odgi && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) && cd build && make install
      FROM debian:stable-slim
      RUN apt-get update && apt-get install -y libgomp1 && rm -rf /var/lib/apt/lists/*
      COPY --from=0 /usr/local/bin/odgi /usr/local/bin/

inputs:
  sparse_graph_index:
    type: File
    inputBinding:
      prefix: --idx=
      separate: false

  pipeline_specification:
    type: string?
    inputBinding:
      prefix: --pipeline=
      separate: false
    doc: |
      apply a series of sorts:
      b: breadth first topological sort
      c: cycle breaking sort
      d: sort on the basis of the DAGified graph
      e: eades algorithm
      f: reverse the sort order
      m: use sparse matrix diagonalization to sort the graph
      r: randomly sort the graph
      s: the default sort
      w: use two-way (max of head-first and tail-first) topological algorithm
      z: chunked depth first topological sort
      S: apply 1D (linear) SGD algorithm to organize graph 

  sgd_use_paths:
    type: boolean?
    doc: in SGD, use paths to structure internode distances
    inputBinding:
      prefix: --sgd-use-paths

  sort_paths_max:
    type: boolean?
    doc: sort paths by their highest contained node id
    inputBinding:
      prefix: --paths-max

arguments:
  - --progress
  - --threads=$(runtime.cores)
  - prefix: --out=
    valueFrom: $(inputs.sparse_graph_index.nameroot).sorted.og
    separate: false

baseCommand: [ odgi, sort ]

outputs:
  sorted_sparse_graph_index:
    type: File
    outputBinding:
      glob: $(inputs.sparse_graph_index.nameroot).sorted.og  
