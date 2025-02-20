# Use a Java runtime as the base image (JRuby runs on the JVM)
FROM openjdk:8-jre

# Set environment variables for JRuby version and installation directory
ENV JRUBY_VERSION=1.7.13
ENV JRUBY_HOME=/opt/jruby-$JRUBY_VERSION
ENV PATH=$JRUBY_HOME/bin:$PATH

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary Linux packages
# - pandoc for document conversion
# - texlive-xetex and related packages for xelatex support
# - build-essential, git, and nodejs for general use
RUN apt-get update && apt-get install -y \
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

# Download and extract JRuby 1.7.13
RUN wget https://s3.amazonaws.com/jruby.org/downloads/$JRUBY_VERSION/jruby-bin-$JRUBY_VERSION.tar.gz \
    && tar -xzf jruby-bin-$JRUBY_VERSION.tar.gz -C /opt \
    && rm jruby-bin-$JRUBY_VERSION.tar.gz


# Set the working directory
WORKDIR /app

# Copy your Gemfile and Gemfile.lock first to leverage Docker cache
COPY Gemfile Gemfile.lock ./

# Install an older version of Bundler compatible with Ruby 1.9.3 / JRuby 1.7.13
# Bundler 1.17.3 is a commonly used version for older Ruby environments.
RUN gem install bundler -v 1.17.3

# Install the project gems
RUN bundle _1.17.3_ install

# Copy the rest of your Docverter source code
COPY . .

# Expose the port that Docverter uses (commonly 8000)
EXPOSE 8000

# Start the Docverter service.
# This command may need to be adjusted based on how Docverter is started (for example, via rackup or another command)
CMD ["bundle", "exec", "rackup", "-p", "8000", "-o", "0.0.0.0"]
