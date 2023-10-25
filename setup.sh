#!/bin/bash

function usage {
    echo ""
    echo "Integrate testkube with ArgoCD"
    echo ""
    echo "usage: ./setup.sh --app_name string --testkube_namespace string --repo_url string --repo_path string "
    echo ""
    echo "  --app_name string             name of the ArgoCD application"
    echo "                                (example: app_under_test)"
    echo "  --testkube_namespace string   testkube namespace"
    echo "                                (example: testkube)"
    echo "  --repo_url string             git repository with the test definitions"
    echo "                                (example: https://github.com/kubeshop/testkube-argocd)"
    echo "  --repo_path string            git repository path"
    echo "                                (example: examples/postman-collections/)"
    echo ""
}

function die {
    printf "Script failed: %s\n\n" "$1"
    exit 1
}

while [ $# -gt 0 ]; do
    if [[ $1 == "--help" ]]; then
        usage
        exit 0
    elif [[ $1 == "--"* ]]; then
        v="${1/--/}"
        declare "$v"="$2"
    fi
    shift
done

if [[ -z $app_name ]]; then
    usage
    die "Missing parameter --app_name"
elif [[ -z $testkube_namespace ]]; then
    usage
    die "Missing parameter --testkube_namespace"
elif [[ -z $repo_url ]]; then
    usage
    die "Missing parameter --repo_url"
elif [[ -z $repo_path ]]; then
    usage
    die "Missing parameter --repo_path"
fi

PATCH_MANIFEST=customization/deployment.yaml
PLUGINS_MANIFEST=customization/argocd-plugins.yaml
TESTKUBE_MANIFEST=applications/testkube.yaml

export APPLICATION_NAME=$app_name
export TESTKUBE_NAMESPACE=$testkube_namespace
export REPOSITORY_URL=$repo_url
export TESTS_PATH_IN_REPOSITORY=$repo_path

envsubst < $TESTKUBE_MANIFEST > modifed_manifest.yaml

kubectl apply -f "$PLUGINS_MANIFEST"
kubectl patch deployments.apps -n argocd argocd-repo-server --patch-file "$PATCH_MANIFEST"
kubectl apply -f modifed_manifest.yaml

rm -f modifed_manifest.yaml