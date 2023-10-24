FROM argoproj/argocd:v2.6.15
# Switch to root for the ability to perform install
USER root
# Pass testkube binary version as an argument, e.g. 1.1.1
ARG VERSION
ENV PLATFORM="Linux_x86_64"

# Install wget to download testkube
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl jq \
 && if ${VERSION} ; \
    then \
      if curl -s -f --output /dev/null --connect-timeout 5 https://api.github.com/repos/kubeshop/testkube/releases/latest; \
        then export VERSION=$(curl -s -f https://api.github.com/repos/kubeshop/testkube/releases/latest | jq -r .tag_name | cut -c2-); \
      else \
        echo "VERSION is not set, and GitHub repo is unavailable, exiting"; \
        exit 1; \
      fi \
    fi \
 ## Configure testkube
 && mkdir .testkube && echo "{}" > .testkube/config.json \
 ## Download testkube and move to bin directory
 && curl -L "https://github.com/kubeshop/testkube/releases/download/v${VERSION}/testkube_${VERSION}_${PLATFORM}.tar.gz" | tar -xzvf - \
 && mv kubectl-testkube /usr/local/bin/testkube \
 && chmod +x /usr/local/bin/testkube \
 && rm -rf LICENSE README.md \
 && apt-get remove -y curl jq
 # Switch back to non-root user
USER 999