# Habitat Managed Demo
This repo is designed to provide a fast way to spin up a demo environment for demonstrating the business outcomes our target market can achieve with the Habitat Managed Chef and Habitat Managed Inspec patterns. 

*NOTE: This demo currently only supports linux

## Requirements
- [ChefDK or Chef Workstation](https://downloads.chef.io)
- [Terraform](https://terraform.io)
- AWS Account in the Chef SA Organization (for SSL certificates) 

## Habitat Managed Inspec and Habitat Managed Chef
Before you begin you will need to build both a Habitat Managed Inspec and a [Habitat Managed Chef]() package. Before launching an environment you should have both a `<your_origin>/linux_baseline` and a `<your_origin>/chef-base` package built and uploaded to the public depot, and promoted to `stable`



