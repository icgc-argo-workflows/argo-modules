# argo-modules
> THIS REPOSITORY IS UNDER ACTIVE DEVELOPMENT. SYNTAX, ORGANISATION AND LAYOUT MAY CHANGE WITHOUT NOTICE!

A repository for hosting ARGO specific data utilities using [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) modules containing tool-specific process definitions and their associated documentation, modeled after [nf-core's modules repo](https://github.com/nf-core/modules). 

Specifically at this time it provides
- modules and subworkflows wrapping Overture SONG/SCORE clients for upload and download of files and metadata.

## Table of contents

- [Using existing modules](#using-existing-modules)
- [Adding new modules](#adding-new-modules)
- [Documentation](#documentation)
- [Acknowledgements](#acknowledgements)

## Using existing modules

The module files hosted in this repository define a set of processes for Overture SONG/SCORE clients such as `SONG`, `Score` etc. All the modules and subworkflows have been written in a similar way which is compitable with `nf-core` modules/subworkflows framework. This allows you to make use of `nf-core/tools` to easily share and add common functionality across multiple pipelines in a modular fashion.

You can use a helper command in the `nf-core/tools` package that uses the GitHub API to obtain the relevant information for the module files present in the [`modules/`](modules/) directory of this repository. This includes using `git` commit hashes to track changes for reproducibility purposes, and to download and install all of the relevant module files.

1. Install the latest version of [`nf-core/tools`](https://github.com/nf-core/tools#installation) (`>=2.0`)
2. List the available modules:

   ```console
   $ nf-core modules --git-remote https://github.com/icgc-argo-workflows/argo-modules.git list remote

                                          ,--./,-.
          ___     __   __   __   ___     /,-._.--~\
    |\ | |__  __ /  ` /  \ |__) |__         }  {
    | \| |       \__, \__/ |  \ |___     \`-._,-`-,
                                          `._,._,'

    nf-core/tools version 2.7.2 - https://nf-co.re


    INFO     Modules available from https://github.com/icgc-argo-workflows/argo-modules.git (main):

    ┏━━━━━━━━━━━━━━━━┓
    ┃ Module Name    ┃
    ┡━━━━━━━━━━━━━━━━┩
    │ cleanup        │
    │ score/download │
    │ score/upload   │
    │ song/get       │
    │ song/manifest  │
    │ song/publish   │
    │ song/submit    │
    └────────────────┘
   ```

3. Install the module in your pipeline directory:

   ```console
   $ nf-core subworkflows --git-remote https://github.com/icgc-argo-workflows/argo-modules.git install song_score_download

                                          ,--./,-.
          ___     __   __   __   ___     /,-._.--~\
    |\ | |__  __ /  ` /  \ |__) |__         }  {
    | \| |       \__, \__/ |  \ |___     \`-._,-`-,
                                          `._,._,'

    nf-core/tools version 2.7.2 - https://nf-co.re


    INFO     Installing 'song_score_download'
   ```

4. Import the module in your Nextflow script:

   ```nextflow
   #!/usr/bin/env nextflow

   nextflow.enable.dsl = 2

   include { SONG_SCORE_DOWNLOAD } from '../subworkflows/icgc-argo-workflows/song_score_download/main'
   ```

5. Remove the module from the pipeline repository if required:

   ```console
   $ nf-core modules --git-remote https://github.com/icgc-argo-workflows/argo-modules.git remove song_score_download

                                          ,--./,-.
          ___     __   __   __   ___     /,-._.--~\
    |\ | |__  __ /  ` /  \ |__) |__         }  {
    | \| |       \__, \__/ |  \ |___     \`-._,-`-,
                                          `._,._,'

    nf-core/tools version 2.7.2 - https://nf-co.re

    WARNING  The subworkflow 'song_score_download' is still included in the following workflow file:
    ╭──────────────────────────────────────────────────────────────────── workflows/dnaalnqc.nf ─────────────────────────────────────────────────────────────────────╮
    │                                                                                                                                                                │
    │   47 include { SONG_SCORE_DOWNLOAD } from '../subworkflows/icgc-argo-workflows/song_score_download/main'                                                       │
    │                                                                                                                                                                │
    ╰────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
    ? Do you still want to remove the subworkflow 'song_score_download'? Yes
    INFO     Removed files for 'score/download' and it's dependencies 'score/download'.
    INFO     Removed files for 'song/get' and it's dependencies 'song/get'.
    INFO     Removed files for 'song_score_download' and it's dependencies 'song_score_download, score_download, song_get'.
   ```

6. Check that a locally installed argo module is up-to-date compared to the one hosted in this repo:

   ```console
   $ nf-core modules --git-remote https://github.com/icgc-argo-workflows/argo-modules.git lint song/get

                                          ,--./,-.
          ___     __   __   __   ___     /,-._.--~\
    |\ | |__  __ /  ` /  \ |__) |__         }  {
    | \| |       \__, \__/ |  \ |___     \`-._,-`-,
                                          `._,._,'

    nf-core/tools version 2.7.2 - https://nf-co.re


    INFO     Linting pipeline: '.'
    INFO     Linting module: 'song/get'

    ╭─ [!] 1 Module Test Warning ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
    │                                           ╷                                              ╷                                                                     │
    │ Module name                               │ File path                                    │ Test message                                                        │
    │╶──────────────────────────────────────────┼──────────────────────────────────────────────┼────────────────────────────────────────────────────────────────────╴│
    │ song/get                                  │ modules/icgc-argo-workflows/song/get/main.nf │ Container versions do not match                                     │
    │                                           ╵                                              ╵                                                                     │
    ╰────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
    ╭──────────────────────╮
    │ LINT RESULTS SUMMARY │
    ├──────────────────────┤
    │ [✔]  18 Tests Passed │
    │ [!]   1 Test Warning │
    │ [✗]   0 Tests Failed │
    ╰──────────────────────╯
   ```

## Adding new modules

Coming soon

## Documentation

Coming soon

## Acknowledgements

## Feedback
Your feedback is very valuable! If you run into any issues using `argo-modules`, have questions, or have some ideas to improve `argo-modules`, please feel free to create ticket in the [Issue Tracker](https://github.com/icgc-argo-workflows/argo-modules/issues).
