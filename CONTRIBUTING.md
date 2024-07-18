## Styleguide

See also <https://www.commonwl.org/user_guide/topics/best-practices.html>

## Code of Conduct

Contributor to this repository should abide by the Common Workflow Language [Code of Conduct](https://github.com/common-workflow-language/common-workflow-language/blob/main/CODE_OF_CONDUCT.md)

## Getting started

The auto-generated CWL tool descriptions at https://aclimatise.github.io/BaseCamp/packages may be a useful starting point.

## Naming Tools 📛

Tools should follow the convention of being prefixed by the parent tool name and Camelcase like so i.e.
`
BWA-Mem.cwl`
or `
BWA-Index.cwl
`

## Tool Feature Requirements 🆕

The first 3 lines of tool wrappers should be as follows. Our CI/CD system checks for these so make sure to include them so they can be merged into the repo.

``` cwl
#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
```

The first line allows the tool to be run as a single command.
The second specifies the CWL version.

**IMPORTANT!**
We are using `cwlVersion` `v1.0` unless a feature from a
later CWL version is needed.

## Making Files Executable ✴️

Files should be marked as executable before being added

`
chmod +x tool.cwl
`

## Requirements & Hints Section 🧾

There is a requirements section which handles settings for the runner config. Docker containers should be from biocontainers.pro if possible and placed in the hints section.

``` cwl
requirements:
  InlineJavascriptRequirement: {}
```

``` cwl
hints:
  DockerRequirement:
    dockerPull: "quay.io/biocontainers/bwa:0.7.17--ha92aebf_3"
```

Upstream software requirements can be noted with a `SoftwareRequirement`. Each software package is specified with one or
more IRIs as described in the [standard](https://www.commonwl.org/v1.2/CommandLineTool.html#SoftwareRequirement). If the
software package is not registered with a stable identified (e.g. a [RRID](https://www.identifiers.org/rrid/) or in
[bio.tools](https://bio.tools/)), the IRI can refer to its homepage. A stable identifier is, however, preferred.

## Validation ✅

Tools need to be free of warning when running with

`
cwltool --validate
`

## Adding Tools To The Repository ➕

Please add tools via pull requests to the repository. Our CI/CD runs validation against the tools and will soon support doing unit tests on the individual tools.

## Descriptions 📃

Tool descriptions should be motivated by a real world use of this tool in a workflow.
The description should focus on a single way of using the tool.
Signs that a tool description is including too much: lots of javascript; complicated data structures; every single flag is listed.

## Schema Description

If you use schema.org annotations, specify the schema using the RDF version:
`$schemas: [ https://schema.org/version/latest/schemaorg-current-https.rdf ]` unless items from
outside the core schema.org vocabulary are needed. In that case use
`$schemas: [ https://schema.org/version/latest/schemaorg-all-https.rdf ]`.

However, don't use `s:mainEntity`, put that information under `hints` as a `SoftwareRequirement`.

Contributor information can also be noted using `s:author` annotation, e.g.

```cwl
s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-0002-0003
    s:email: mailto:acontributor@example.org
    s:name: Alice Contributor
```

## File Formats

If your tool has well defined input or output files, we recommend the addition of file formats using ontologies such as EDAM. CWL executors like cwltool can do some basic reasoning using this information and can warn about obvious mismatches.

``` cwl
input_sequences:
    type:
      - File
      - File[]
    label: "Input sequence files"
    format:
      - edam:format_1929  # FASTA
      - edam:format_1930  # FASTQ
```

For file formats that are not specific to biological data, such as CSV, the IANA format list can be used, e.g.

``` cwl
inputs:
  some_input:
    type: File
    format: iana:text/csv
```

``` cwl
$namespaces:
  edam: http://edamontology.org/
  iana: https://www.iana.org/assignments/media-types/
```

## Formatting and order of sections

While there is no specific standard on the order of sections in a CWL file, [cwl-format](https://github.com/rabix/cwl-format) may be used to format the CWL
code of a tool if the author feels that it is useful.

## Dockstore

Update [.dockstore.yml](.dockstore.yml) to allow the new tool description to be automatically registered on [Dockstore](https://dockstore.org/).
If the path within this repository to the tool's description is `/foo/foo-bar.cwl`, you would add the following entry to the `tools` section of [.dockstore.yml](.dockstore.yml):

```
# foo
  - subclass: CWL
    primaryDescriptorPath: /foo/foo-bar.cwl
    name: foo-bar
    publish: true
```

To include test files, append the `testParameterFiles` key and a list of file paths:

```
# foo
  - subclass: CWL
    primaryDescriptorPath: /foo/foo-bar.cwl
    name: foo-bar
    publish: true
    testParameterFiles:
      - /foo/tests/foo-bar-t1.json
      - /foo/tests/foo-bar-t2.json
```

[More information](https://docs.dockstore.org/en/stable/assets/templates/tools/tools.html) about [.dockstore.yml](.dockstore.yml).
