FROM argoproj/argocd:latest
 
# Switch to root for the ability to perform install
USER root
# Pass testkube binary version as an argument, e.g. 1.1.1
ARG VERSION
ENV TESTKUBE_VERSION=testkube_${VERSION}_Linux_x86_64.tar.gz

# Install wget to download testkube
RUN apt-get update && \
 apt-get install -y \
 wget && \
 ## Configure testkube
 mkdir .testkube && echo "{}" > .testkube/config.json && \
 ## Download testkube and move to bin directory
 wget -O- "https://github.com/kubeshop/testkube/releases/download/v$VERSION/$TESTKUBE_VERSION" | tar -xzvf - && \
 mv kubectl-testkube /usr/local/bin/testkube && \
 chmod +x /usr/local/bin/testkube
 
# Switch back to non-root user
USER 999