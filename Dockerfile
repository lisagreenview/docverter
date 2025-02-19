# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install dependencies:
# - build-essential: for compiling native extensions
# - curl, git: common utilities
# - pandoc: document converter
# - texlive-xetex, texlive-fonts-recommended, texlive-plain-generic: TeX distribution including xelatex
# - ruby, ruby-dev: Ruby runtime and development headers
# - libsqlite3-dev, sqlite3: if Docverter uses SQLite (adjust if using another DB)
# - nodejs: for any JS dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    pandoc \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \
    ruby \
    ruby-dev \
    libsqlite3-dev \
    sqlite3 \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock into the container for dependency installation
COPY Gemfile Gemfile.lock ./

# Install Bundler and Ruby gems
RUN gem install bundler && bundle install --jobs 4

# Copy the rest of your Docverter source code
COPY . .

# Expose the port that Docverter uses (commonly 8000)
EXPOSE 8000

# Start the Docverter service using rackup, binding to all interfaces
CMD ["bundle", "exec", "rackup", "-p", "8000", "-o", "0.0.0.0"]
