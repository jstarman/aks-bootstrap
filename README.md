# AKS Terraform Setup

An attempt at fast flow gitops style platform software development.

Generally following the [MS AKS Baseline](https://github.com/mspnp/aks-baseline) and more complete example [here](https://github.com/Azure-Samples/private-aks-cluster-terraform-devops) with a Terraform infrastructure install and Helm chart configuration.

|                                         | Complete
|-----------------------------------------|-------
| Egress restriction using Azure Firewall |
| Ingress Controller                      |
| Azure Active Directory Pod Identity     |
| Resource Limits                         |
| Other Infrastructure aspects            |
| Zero Trust Network Policies             |
| Horizontal Pod Autoscaling              |
| Cluster Autoscaling                     |
| Readiness/Liveness Probes               |
| Helm charts                             |
| Distributed Monitoring                  |

## Customizations

|                          | Complete
|--------------------------|-------
| Terraform                |
| Cert-Manager             |
| Istio Ingress Controller |
| ArgoCD                   |
| Sealed Secrets           |
| Prometheus               |

## Other TODO

|                               | Complete
|-------------------------------|-------
| Canary Deploy                 |
| Git Actions Application Build |
| Test integration (API, E2E)   |
| Local Development Setup       |

![Architecture](https://github.com/jstarman/private-aks-cluster-terraform-devops/blob/main/images/normalized-architecture.png)

## Steps

- [x] Create backend `./bootstrap.ps1`
- [x] Fill variables
  - Determine aks supported version `az aks get-versions -l westus2`
  - Create public key for ssh
  - Determine aks VM size, disc type see default and addtional node vars
- [x] Deploy platform `./apply.ps1`
  - apply takes about 30m
- [x] Tear down platform `./destroy.ps1`
  - destroy takes about 18m
  - If the destroy does not run cleanly it will likely orphan diagnostic settings. The next apply will fail, see [issue here](https://github.com/hashicorp/terraform-provider-azurerm/issues/6389). After running apply which will finish with errors indicating the resource(s) with problems. Go into the Portal Subsription -> Resources -> Resource -> Diagnostic Settings -> Delete setting. Then Destroy and re-apply.
- [ ] Verify setup
- [ ] WAF and Application Gateway

## Cleanup

Run `terraform destroy` then `az group delete --name infra-state-rg --yes` for complete cleanup

## References

- [Primary resource for Terraform Setup](https://github.com/Azure-Samples/private-aks-cluster-terraform-devops)
- [Primary resource docs](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/aks-firewall/aks-firewall)
- [MS AKS Baseline](https://github.com/mspnp/aks-baseline)
- [More detailed Baseline setup](https://github.com/mspnp/aks-fabrikam-dronedelivery)
- [I Terraform Setup](https://github.com/mofaizal/rampup-project)
- [II Terraform Setup](https://github.com/pliniogsnascimento/aks-gitops-lab)
- [III Terraform Setup](https://github.com/J0hn-B/eshop-aks)
- [IV Terraform Setup (*)](https://github.com/mathieu-benoit/myakscluster)
- [Hashicorp's Setup](https://github.com/hashicorp/learn-terraform-provision-aks-cluster)
- [GitHub Action AKS deploy](https://docs.microsoft.com/en-us/azure/aks/kubernetes-action)
- [Terraform AD provider docs](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
- [AKS for microservices](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks-microservices/aks-microservices-advanced)
- [Terraform Examples](https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/kubernetes)
