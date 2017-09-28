FROM openshift/base-centos7

MAINTAINER John Osborne <johnfosborneiii@gmail.com>

# Set labels used in OpenShift to describe the builder images
LABEL io.k8s.description="Camel REST DSL S2I" \
      io.openshift.expose-services="8080:http" \
      io.openshift.s2i.destination="/opt/s2i/destination" \
      io.openshift.tags="builder,camel,rest"

# Specify the ports the final image will expose
EXPOSE 8080

ENV MAVEN_VERSION=3.3.9
ENV JAVA_VERSON 1.8.0
ENV STI_SCRIPTS_PATH=/usr/bin/s2i

RUN yum install -y curl && \
  yum install -y java-$JAVA_VERSON-openjdk java-$JAVA_VERSON-openjdk-devel && \
  yum clean all

RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

RUN mkdir -p /camel && \
    mkdir -p /opt/s2i/destination

COPY pom.xml /camel/
COPY src/ /camel/
COPY contrib/settings.xml $HOME/.m2/
COPY .s2i/bin/ $STI_SCRIPTS_PATH

RUN chown -R 1001:0 /camel && chown -R 1001:0 $HOME && \
    chmod -R ug+rw /camel && \
    chmod -R g+rwx /opt/s2i/destination

RUN chown -R 1001:0 /camel/
RUN chmod -R +x $STI_SCRIPTS_PATH

USER 1001
