# AKS Terraform Setup

Generally following the [MS AKS Baseline](https://github.com/mspnp/aks-baseline) and more complete example [here](https://github.com/mspnp/aks-fabrikam-dronedelivery) with a Terraform infrastructure install and Helm chart configuration.

|                                         | Complete
|-----------------------------------------|-------
| Egress restriction using Azure Firewall | [ ]
| Ingress Controller                      | [ ]
| Azure Active Directory Pod Identity     | [ ]
| Resource Limits                         | [ ]
| Other Infrastructure aspects            | [ ]
| Zero Trust Network Policies             | [ ]
| Horizontal Pod Autoscaling              | [ ]
| Cluster Autoscaling                     | [ ]
| Readiness/Liveness Probes               | [ ]
| Helm charts                             | [ ]
| Distributed Monitoring                  | [ ]

## Customizations

|                          | Complete
|--------------------------|-------
| Terraform                | [ ]
| Cert-Manager             | [ ]
| Istio Ingress Controller | [ ]
| ArgoCD                   | [ ]
| Sealed Secrets           | [ ]
| Prometheus               | [ ]

## Other TODO

|                               | Complete
|-------------------------------|-------
| Canary Deploy                 | [ ]
| Git Actions Application Build | [ ]
| Test integration (API, E2E)   | [ ]
| Local Development Setup       | [ ]

![Architecture](https://github.com/mspnp/aks-fabrikam-dronedelivery/blob/main/imgs/aks-securebaseline-fabrikamdronedelivery.png)

## Steps

- [x] Followed <https://github.com/mspnp/aks-fabrikam-dronedelivery/blob/main/01-prerequisites.md> for prerequisites
- [ ] TLS Cert prep will go with self-signed but once the cluster is setup with move over to [Let's Encrypt hosted](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-letsencrypt-certificate-application-gateway)
- [ ] Azure AD integration prep <https://github.com/mspnp/aks-fabrikam-dronedelivery/blob/main/03-aad.md> Creating group and add users to it via Terraform. Creation of SP via az cli.

## References

- [MS AKS Baseline](https://github.com/mspnp/aks-baseline)
- [I Terraform Setup](https://github.com/mofaizal/rampup-project)
- [II Terraform Setup](https://github.com/pliniogsnascimento/aks-gitops-lab)
- [III Terraform Setup](https://github.com/J0hn-B/eshop-aks)
- [IV Terraform Setup (*)](https://github.com/mathieu-benoit/myakscluster)
- [Hashicorp's Setup](https://github.com/hashicorp/learn-terraform-provision-aks-cluster)
- [GitHub Action AKS deploy](https://docs.microsoft.com/en-us/azure/aks/kubernetes-action)
- [Terraform AD provider docs](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)