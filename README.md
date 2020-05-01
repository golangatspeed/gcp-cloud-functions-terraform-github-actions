# GCP Cloud functions written in Go, with infrastructure via Terraform and CI/CD on Github actions

Current status: rapid brain-dump, said I'd do this today, but I expect this README is a long way off perfect

## Starter repository

![Test & Release](https://github.com/teetlab/sso/workflows/Test%20&%20Release/badge.svg) | [![DeepSource](https://static.deepsource.io/deepsource-badge-light-mini.svg)](https://deepsource.io/gh/teetlab/sso/?ref=repository-badge)

If you want to deploy GCP Cloud Functions, using  Terraform for Infrastructure management 
and Github Actions for your CI/CD pipeline, like I did, this might get you going a bit faster.

This repo, is fully open source and offered under the MIT license, but if you make improvements, 
please do upstream them via pull request, or just raise in the issue tracker. 

## What's included

- A template for working with GCP Cloud Functions, written in Go (golang) where we need to send
zipped source, not zipped, compiled binaries.
- A Github Actions workflow, that will get external dependencies, run the unit tests, and then perform
Terraform plan, apply commands to release to a "stage". 
- A Terraform module for deploying the GCP infrastructure and the functions themselves, using a remote
backend for state maintenance.

## Todo

- After release to Stage, we want integration tests. Folder `_build/test` is for this purpose.
Though project dependent, there are some basic end point calls we could make to prove functions respond.
- Teardown. A `terraform destroy` of the Stage infrastructure
- Release. It makes sense that if unit and integration tests are all good we should release to production.
- Notifications.
- Workflow on PR. Does it need to be different, or can we use this too. We should comment the PR at least?

## Background

GCP Cloud Functions require you to upload zipped source code when using their Go runtime.
Your functions get built 'cloud-side'. This differs from AWS's Lambda FaaS, which expects zipped Go binaries.

The implications of this aren't immediate, but you will find:-

- Your typical `cmd, pkg, internal` structure for 'normal' Go projects will not be ideal.
- Your entry point into the function is not `main()`. You're writing and shipping packages, not executables.
- Shared "pkg" resources, you want to use across functions, are, at least in my experience better
hosted in their own repo - not a folder in the same repo. Many of you might do this already for commonly used stuff.
- If you want to host multiple functions in the same repo, using go modules it gets a bit messy.  
- However, because you ship package source and not executables to GCP, you can use `func main()` for local development
 & testing. This is nice.
 
# Authentication with GCP

This repo is set up with a GCP service account. You will need to provide credentials for one, for both local and remote use.

#### Local: 

In `variables.tf` find the  `variable "credentials_file" {...` object, and set the 'default' property as the path to your 
service account's JSON credentials file. 
                       
#### Remote: 

Add a secret in your Github repo, the key/name should be `gcp_service_account`, the contents should be
the contents of the file in your GCP service account's JSON credentials file.

## License

Full MIT, but lease upstream anything nice ;)
