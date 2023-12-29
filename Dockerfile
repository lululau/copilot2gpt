FROM rubylane/ruby:3.2

LABEL maintainer="Liu Xiang<liuxiang921@gmail.com>"

RUN gem install copilot2gpt

WORKDIR /

EXPOSE 8080

ENTRYPOINT ["copilot2gpt"]