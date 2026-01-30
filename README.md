# FBO - Football Ontology

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [uv](https://docs.astral.sh/uv/getting-started/installation/)

## Local Setup

1. Create `.env` file (see `.env.example` for template)
2. Run `make setup`

## Commands

```
make setup    # Install dependencies
make up       # Start Neo4j
make down     # Stop Neo4j
make shell    # Cypher shell
make logs     # Tail logs
make run      # Run app
make test     # Run tests
make clean    # Remove all data
```

## Neo4j Access

- Browser: http://localhost:7474
- Bolt: `bolt://localhost:7687`
