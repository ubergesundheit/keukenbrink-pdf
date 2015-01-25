FROM ruby:2.2-onbuild

RUN apt-get update && apt-get -y install wget poppler-utils && apt-get clean

CMD ["unicorn", "-Ilib", "-E production"]
