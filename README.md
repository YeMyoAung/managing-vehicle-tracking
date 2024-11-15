# Managing Vehicle Tracking App: A Microservices Project

This guide provides detailed instructions for setting up, building, and running the Managing Vehicle Tracking App using
Docker. The system includes several services, such as the Auth Service, Vehicle Service, Tracking Service, Dashboard
Service, and an NGINX Gateway to manage traffic between services.

In this project, I tried to use go build-in packages as much as possible to avoid third-party dependencies.
So our services are lightweight and easy to manage.

## Prerequisites

Ensure you have the following installed:

- **Docker**: [Install Docker](https://docs.docker.com/get-started/get-docker/)
- **Docker Compose**: [Install Docker Compose](https://docs.docker.com/compose/install/)

---

## Project Setup

To get started with the project, clone the repository and initialize the submodules:
```shell
git submodule update --init --recursive
```


## Project Structure

The project structure for your system will look like this:

```text
/managing-vehicle-tracking-app
├── /auth-service           # Auth service source code and Dockerfile
├── /common                 # Common source code shared between services
├── /dashboard              # Dashboard service source code and Dockerfile
├── /models                 # Models shared between services
├── /nginx                  # NGINX service configuration
│    ├── nginx.conf         # NGINX config for reverse proxy
│    ├── Dockerfile         # Dockerfile for NGINX
├── /tracking-service       # Tracking service source code and Dockerfile
├── /vehicle-service        # Vehicle service source code and Dockerfile
├── docker-compose.yml      # Docker Compose configuration
├── Makefile                # Makefile for building and running the system
├── README.md               # Project documentation 
```

Each service will have a similar architecture (layered architecture) with different functionalities. Shared components
such as models and common utilities avoid code duplication.

## Example Service Structure

```text
/auth-service
├── /internal               # Internal source code for the service
│   ├── app                 # Bootstrap code for the service
│   ├── config              # Configuration-related code
│   ├── handler             # HTTP handlers (controllers)
│   ├── repositories        # Data layer for interacting with databases
│   ├── services            # Core business logic
├── .env.example            # Example environment variables
├── Dockerfile              # Dockerfile for building the service
├── go.mod                  # Go module file
├── go.sum                  # Go module checksum file
├── main.go                 # Main entry point for the service
├── Makefile                # Makefile for building and running the service
├── README.md               # Service-specific documentation

```

## Project Diagram

```text
               +---------------------+
               |     Admin Panel      |
               |  (Web Interface)     |
               +----------+----------+
                          |
                          v
               +---------------------+
               |     NGINX Gateway    |
               |   (Reverse Proxy)    |
               +----------+----------+
                          |
                          v
               +---------------------+
               |    Auth Service      |
               | (Handles Auth, JWT)  |
               +----------+----------+
                          |
                          v
          +---------------+---------------+
          |                               |
+---------------------+         +---------------------+
|   Vehicle Service   |         |   Tracking Service  |
| (Handles Vehicles)  |         | (Handles Tracking)  |
+---------------------+         +---------------------+
          |                               |
          | Publish to tracking queue     | Consume tracking data
          v                               v
  +-------------------+           +-------------------+
  |  RabbitMQ (Tracking)  |<------->|  RabbitMQ (Vehicle)|
  |   (Asynchronous)     |           |   (Asynchronous)   |
  +-------------------+           +-------------------+
          |                               |
          v                               v
  +-------------------+           +-------------------+
  |  NoSQL Database   |           |   NoSQL Database  |
  |  (Vehicle Data)   |           |   (Tracking Data) |
  +-------------------+           +-------------------+
                          |
                          v
               +--------------------------+
               |     Docker Setup         |
               |   (Docker Compose,       |
               |   RabbitMQ, Databases)   |
               +--------------------------+
```

## Setup

If you have `Make` installed, you can use the `Makefile` to build and run the system:

```shell    
 make run # Build and run the system
 make stop # Stop the system
```

If you don't have `Make` installed, you can use the following commands:

```shell
 docker compose up -d # Build and run the system
 docker compose down # Stop the system
```

## API Endpoints

### Auth Service

- `POST /api/v1/login`: Login with username and password to get a JWT token.
- `GET /api/v1/me`: Validate a JWT token and retrieve user information.

### Vehicle Service

- `GET /api/v1/vehicles`: Get all vehicles.
- `POST /api/v1/vehicles`: Create a new vehicle.
- `GET /api/v1/vehicles/{id}`: Retrieve a vehicle by ID.
- `POST /api/v1/tracking`: Publish tracking data for a vehicle.

### Tracking Service

- `GET /api/v1/tracking-data`: Retrieve all tracking data.

### Dashboard Service

- `GET /`: Dashboard home page.

## Request Signatures

Each request must be signed using `SHA256 HMAC`. Here’s how:

- Concatenate the request method, path, query (sorted), and body (if any) into a single string.
- Generate a SHA256 HMAC using the concatenated string and a secret key.
- Add the signature to the request headers as `X-Signature`.
- The server will validate the signature using the same `secret key`.

## Environment Variables

Example environment variables are provided in the `.env.example` file for each service directory.

## Accessing the System

Once the setup is complete, you can access the dashboard at:

```text
http://0.0.0.0
```

## Accessing the Admin Panel

## Create a New User

If you have `Make` installed, you can use the `Makefile` to create a new user:

```shell
  make create_user
```

or you can use `Go Command` directly:

```shell
cd auth-service && go run mongo_create_user_cmd.go
```

If you are inside a Docker container, you can use the following command:

```shell
docker exec -it <container_id> ./mongo_create_user_cmd # Using Docker
docker compose exec <container_id> ./mongo_create_user_cmd # Using Docker Compose
```

## Testing

To run tests for each service, use the following commands:

```shell
make test # Run tests for all services
```

If you don't have `Make` installed, you can use the following commands:

```shell
cd <service> && go test --race -cover -v ./... # Run tests for the auth service
```

If you are inside docker container, you can run the tests using the following command:

```shell
docker exec -it <container_id> go test --race -cover -v ./... # Using Docker
docker compose exec <container_id> go test --race -cover -v ./... # Using Docker Compose
```

