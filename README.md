# Bazzar


Projeto voltado ao gerenciamento de lojas de venda de roupas, sendo possivel cadastrar a loja e produtos para cada loja

Project aimed at managing clothing sales stores, making it possible to register the store and products for each store

## Pré-requisitos - Prerequisites

Antes de começar, verifique se você possui as seguintes ferramentas instaladas em sua máquina:

Before you begin, make sure you have the following tools installed on your machine: 

- Erlang 25.1.2 or higher
- Elixir 1.16.2-otp-25 or higher
- PostgreSQL or Docker
- ASDF in case of not have elixir or erlang instaled

##  Run ASDF

Comece instalando erlang e elixir com:
Start installing erlang and elixir with:
```bash
asdf install
```

## Subir Docker - Up Docker

Suba o docker com o comando:
Start docker with the command:

```bash
sudo docker compose up
```

Caso use a postgreSQL instalado na maquina pular esse passo
If you use PostgreSQL installed on the machine, skip this step

## Iniciando projeto - Starting project

Apos definir o ambiente iniciaremos o projeto com
After defining the environment, we will start the project with
```bash
mix deps.get
mix ecto.create
mix ecto.migrate
iex -S mix phx.server
```
Com esses passos instalamos as dependecias necessarias, criamos o banco e definimos as migracoes
Por fim iniciamos o projeto

With these steps we install the necessary dependencies, create the database and define the migrations
Finally we started the project

## Endpoints de comunicacao - Communication endpoints

Utilizar as rotas encontradas no arquivo
Use the routes found in the file
Bazzar.postman_collection.json


