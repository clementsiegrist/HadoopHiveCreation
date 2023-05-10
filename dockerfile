FROM openjdk:8

# Install Hadoop
ENV HADOOP_VERSION 3.3.1
RUN curl -O https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz -C /usr/local && \
    mv /usr/local/hadoop-${HADOOP_VERSION} /usr/local/hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Install required packages
RUN apt-get update && apt-get install -y curl

# Install Hive
RUN curl -o /tmp/apache-hive-bin.tar.gz https://archive.apache.org/dist/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz && \
    tar -xzf /tmp/apache-hive-bin.tar.gz -C /usr/local && \
    mv /usr/local/apache-hive-3.1.2-bin /usr/local/hive && \
    rm /tmp/apache-hive-bin.tar.gz

# Set environment variables
ENV HIVE_HOME /usr/local/hive
ENV PATH $PATH:$HIVE_HOME/bin

# Copy the Hive configuration file
COPY hive-site.xml $HIVE_HOME/conf

# Expose ports
EXPOSE 10000


