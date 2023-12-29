FROM rubylane/ruby:3.2

LABEL maintainer="Liu Xiang<liuxiang921@gmail.com>"

RUN gem install copilot2gpt

WORKDIR /

EXPOSE 4567

ENTRYPOINT ["copilot2gpt"]

CMD ["-p", "4567"]
