# Use the official Ruby 3.1 slim image as the base
FROM ruby:3.1-slim

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies: 
# - pandoc for document conversion
# - texlive-xetex and related packages for xelatex support
# - build-essential, git, and nodejs for general use
RUN apt-get update && apt-get install -y \
    pandoc \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \
    build-essential \
    git \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy your Gemfile and Gemfile.lock first to leverage Docker cache
COPY Gemfile Gemfile.lock ./

# Use the default Bundler to install gems
RUN bundle install --jobs 4

# Copy the rest of your Docverter source code
COPY . .

# Expose the port that Docverter uses (commonly 8000)
EXPOSE 8000

# Start the Docverter service using rackup, binding to all interfaces
CMD ["bundle", "exec", "rackup", "-p", "8000", "-o", "0.0.0.0"]
