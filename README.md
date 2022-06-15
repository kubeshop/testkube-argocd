# Testing cloud native applications with ArgoCD and Testkube

This repository sets up ArgoCD to use Testkube to generate testing resource manifests that ArgoCD will then apply to a Kubernetes cluster. To make that possible, Testkube needs to be added as a plugin to ArgoCD. This repository covers the steps to do that. 

## Manual ArgoCD configuration

### 1. Patching ArgoCD's deployment

The `argocd-repo-server` deployment images need to be replaced by the testkube argocd Docker image.

Apply the following the command: 

```sh
kubectl patch deployments.apps -n argocd argocd-repo-server --type json --patch-file customization/patch.yaml
```

### 2. Define Testkube in ArgoCD PluginConfigurattionManagement

In order to define the name of the plugin that will be used by an ArgoCD application, and to define the command ArgoCD should run to generate the manifests when the plugin is used, run: 

```sh
kubectl patch configmaps -n argocd argocd-cm --patch-file customization/argocd-plugins.yaml
```

### 3. Create an ArgoCD application that uses the Testkube plugin 

In [`testkube.yaml`](applications/testkube.yaml) update the field:
 - `APPLICATION_NAME` with the unique name of ArgoCD application
 - `TESTKUBE_NAMESPACE` with Testkube namespace
 - `REPOSITORY_URL` with the Git repository containing your test definitions 
 - `TESTS_PATH_IN_REPOSITORY` with the path to the tests folder

Create the application by running the command

```sh
kubectl apply -f applications/testkube.yaml
```

## Setup ArgoCD on Linux or MacOS with Setup Script

To setup on Linux or MacOs, run

```sh
./setup.sh --app_name <APPLICATION_NAME> --testkube_namespace <TESTKUBE_NAMESPACE> --repo_url <REPOSITORY_URL> --repo_path <TESTS_PATH_IN_REPOSITORY>
```
