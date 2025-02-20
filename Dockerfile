# Use a Java runtime as the base image (JRuby runs on the JVM)
FROM openjdk:8-jre


# Force Java to use TLS 1.2: set both JAVA_OPTS and _JAVA_OPTIONS
ENV JAVA_OPTS="-Dhttps.protocols=TLSv1.2"
ENV _JAVA_OPTIONS="-Dhttps.protocols=TLSv1.2"

# Avoid interactive prompts during package installation
# ENV DEBIAN_FRONTEND=noninteractive

# Install necessary Linux packages
# - pandoc for document conversion
# - texlive-xetex and related packages for xelatex support
# - build-essential, git, and nodejs for general use
RUN apt-get update && apt-get install -y \
    ca-certificates \
    wget \
    unzip \
    pandoc \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \    
    build-essential \
    git \
    nodejs \
    && rm -rf /var/lib/apt/lists/*


# Set environment variables for JRuby version and installation directory
ENV JRUBY_VERSION=1.7.13
ENV JRUBY_HOME=/opt/jruby-$JRUBY_VERSION
ENV PATH=$JRUBY_HOME/bin:$PATH

# Download and extract JRuby 1.7.13
RUN wget https://s3.amazonaws.com/jruby.org/downloads/$JRUBY_VERSION/jruby-bin-$JRUBY_VERSION.tar.gz && \
    tar -xzf jruby-bin-$JRUBY_VERSION.tar.gz -C /opt && \
    rm jruby-bin-$JRUBY_VERSION.tar.gz


# Set the working directory
WORKDIR /app

# Copy your Gemfile and Gemfile.lock first to leverage Docker cache
COPY Gemfile Gemfile.lock ./

# Remove any preinstalled bundler (if necessary)
RUN gem uninstall bundler -aIx || true

# Manually download and install Bundler 1.17.3 (bypassing TLS issues)
RUN wget --no-check-certificate https://rubygems.org/downloads/bundler-1.17.3.gem && \
    gem install bundler-1.17.3.gem --no-document && \
    rm bundler-1.17.3.gem

# Install project gems using Bundler 1.17.3
RUN bundle _1.17.3_ install

# Copy the rest of your Docverter source code
COPY . .

# Expose the port that Docverter uses (commonly 8000)
EXPOSE 8000

# Start the Docverter service.
# This command may need to be adjusted based on how Docverter is started (for example, via rackup or another command)
CMD ["bundle", "exec", "rackup", "-p", "8000", "-o", "0.0.0.0"]
