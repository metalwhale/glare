# glare
A naive and (hopefully) distributed lil Redis server written in Gleam.

## Local development
Change to [`deployment-local`](./deployment-local/) directory:
```bash
cd ./deployment-local/
```

Start and get inside the container:
```bash
docker compose up --build --remove-orphans -d
docker compose exec node1 bash
```

## Kudos
This hobby project is heavily inspired by the following awesome resources:
- [Writing a mini Redis server in Elixir](https://kaiwern.com/posts/2022/04/04/writing-a-mini-redis-server-in-elixir/)
- [Three real-world examples of distributed Elixir](https://bigardone.dev/blog/2021/05/22/three-real-world-examples-of-distributed-elixir-pt-1)
