FROM openshift/base-centos7

MAINTAINER John Osborne <johnfosborneiii@gmail.com>

# Set labels used in OpenShift to describe the builder images
LABEL io.k8s.description="Camel REST DSL S2I" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,camel,rest"

ENV MAVEN_VERSION=3.3.9

# Install Maven, Wildfly 8
RUN INSTALL_PKGS="tar unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    (curl -v https://www.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    ln -sf /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && \
    mkdir -p /wildfly && \
    mkdir -p /opt/s2i/destination

# Although this is defined in openshift/base-centos7 image it's repeated here
# to make it clear why the following COPY operation is happening
LABEL io.openshift.s2i.scripts-url=image:///usr/local/s2i
# Copy the S2I scripts from ./.s2i/bin/ to /usr/local/s2i when making the builder image
COPY ./.s2i/bin/ /usr/local/s2i

COPY pom.xml /opt/app-root/
COPY src/ /opt/app-root/
COPY ./contrib/settings.xml $HOME/.m2/

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

RUN chown -R 1001:0 /opt/app-root && chown -R 1001:0 $HOME && \
    chmod -R ug+rw /opt/appr-root && \
    chmod -R g+rw /opt/s2i/destination

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 /opt/app-root

# Set the default user for the image, the user itself was created in the base image
USER 1001

# Specify the ports the final image will expose
EXPOSE 8080

# Set the default CMD to print the usage of the image, if somebody does docker run
CMD ["usage"]
