FROM ruby:2.2-onbuild

RUN apt-get update && apt-get -y install poppler-utils --no-install-recommends && rm -rf /var/lib/apt/lists/*

CMD ["unicorn", "-Ilib", "-E production"]
