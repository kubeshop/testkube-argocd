# Testing cloud native applications with ArgoCD and Testkube

This repository sets up ArgoCD to use Testkube to generate testing resource manifests that ArgoCD will then apply to a Kubernetes cluster. To make that possible, Testkube needs to be added as a plugin to ArgoCD. This repository covers the steps to do that. 

## Manual ArgoCD configuration

### 1. Create a ConfigMap manifest 

In order to define the name of the plugin that will be used by an ArgoCD application, and to define the command ArgoCD should run to generate the manifests when the plugin is used, run:

```shell
kubectl apply -f customization/argocd-plugins.yaml
```
This will create a ConfigMap resource - `argocd-cm-plugin` with `ConfigManagementPlugin` specifications.

### 2. Patching ArgoCD's deployment

To install a plugin, patch `argocd-repo-server` deployment to run the plugin container as a sidecar.
Apply the following the command: 

```sh
kubectl patch deployments.apps -n argocd argocd-repo-server --patch-file customization/deployment.yaml
```


If there is need to pass executor arguments to the test, add ```--executor-args``` to the Testkube command in customization/argocd-plugins.yaml.

Note: The flag will be added to all the test CRDs that will be generated.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm-plugin
  namespace: argocd
data:
  plugin.yaml: |
    apiVersion: argoproj.io/v1alpha1
    kind: ConfigManagementPlugin
    metadata:
      name: testkube
    spec:
      version: v1.0
      generate:
        command: [sh, -c]
        args:
          - |
            testkube generate tests-crds . --executor-args '--executor-flag'
```

### 3. Create an ArgoCD application that uses the Testkube plugin

You may easily deploy out test application that resides in `examples` folder, by running the following command:
```shell
kubectl apply -f examples/testkube-application.yaml
```
After apply you will see `testkube-tests` Application with two synced tests in Argo UI, or in a terminal, using the command:
```shell
kubectl get application -n argocd
```

In order to customize the Application file, please make use of the `testkube.yaml`file:
In [`testkube.yaml`](applications/testkube.yaml) update the field:
 - `APPLICATION_NAME` with the unique name of ArgoCD application
 - `TESTKUBE_NAMESPACE` with Testkube namespace
 - `REPOSITORY_URL` with the Git repository containing your test definitions 
 - `TESTS_PATH_IN_REPOSITORY` with the path to the tests folder

Create the application by running the command:

```sh
kubectl apply -f applications/testkube.yaml
```

## Setup ArgoCD on Linux or MacOS with Setup Script

To setup on Linux or MacOs, run

```sh
./setup.sh --app_name <APPLICATION_NAME> --testkube_namespace <TESTKUBE_NAMESPACE> --repo_url <REPOSITORY_URL> --repo_path <TESTS_PATH_IN_REPOSITORY>
```

To use the script for the examples in this repository run

```sh
./setup.sh --app_name testkube-argo --testkube_namespace testkube --repo_url https://github.com/kubeshop/testkube-argocd --repo_path examples/postman-collections
```
