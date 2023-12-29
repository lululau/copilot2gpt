# Copilot 2 GPT-4

This is a Sinatra-based application that serves as a bridge between GitHub Copilot and GPT-4 model. It provides endpoints to interact with the GPT-4 model and handles authorization using GitHub tokens.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

You need to have Ruby installed on your machine. You can check if you have Ruby installed by running:

```bash
ruby -v
```

### Installing

Clone the repository:

```bash
git clone https://github.com/lululau/copilot2gpt.git
cd copilot2gpt
```

Install the required gems:

```bash
bundle install
```

### Running the application

You can start the application by running:

```bash
bundle exec exe/copilot2gpt
```

The application will start on port 8080.

## API Endpoints

The application provides the following endpoints:

- `GET /openai/models`: Returns a list of available models.
- `POST /openai/chat/completions`: Mocks a Cloudflare AI Gateway API
- `POST /v1/chat/completions`: Completes a chat with the AI model.

## Docker

This application can also be run in a Docker container. Build the Docker image by running:

```bash
docker build -t your-image-name .
```

Then, you can start the application in a Docker container by running:

```bash
docker run -p 8080:8080 your-image-name
```

## Contributing

Please read [CONTRIBUTING.md](https://github.com/lululau/copilot2gpt/blob/main/CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/lululau/copilot2gpt/blob/main/LICENSE.md) file for details.