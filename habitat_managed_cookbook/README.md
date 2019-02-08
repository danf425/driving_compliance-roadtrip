# habitat_managed_cookbook 
The Habitat Managed cookbook is designed for quick demos of the [Habitat Managed Chef](https://github.com/chef/habitat_managed_chef) and [Habitat Managed Inspec](https://github.com/chef/habitat_managed_inspec) pattern. 

It is important to note that this is not a reference architecture on how to implement Habitat Managed. This cookbook makes a dependency on the Habitat Cookbook, while current implementations of this pattern leverage most robust provisioning such as HashiCorp's Terraform.

## Setting up the demo
In order to run a Habitat Managed demo you will need the following:
-  Chef Automate with a valid ssl cert
- Habitat Managed Inspec package (`<your origin>/linux_baseline`)
- Habitat Managed Chef package (`<your origin>/chef-base`) built and pushed to the public Habitat Depot

## Provision Chef Automate
We need to turn Jeff Vogt's work into a standalone module for building chef automate

## Build Habitat Managed Inspec
In order to run a Habitat 