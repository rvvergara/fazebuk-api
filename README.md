# fazebuk-api -> JSON API Facebook Clone

[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> JSON API app built using Ruby on Rails

> App generated using [this](https://github.com/rvvergara/rails-templates/tree/master/api_template) custom Rails Template

Version 1 Features:

- User account creation and update
- Token authentication using `devise` and `jwt`
- Request authorization using `pundit`
- Database search using `pg_search`
- Model and request specs using `rspec-rails` and `factory_bot_rails`

Pipeline:

- Login using facebook -> thru omniauth

## Background

Previously I co-worked on a [project](https://github.com/dipto0321/facialbook) that built a full-stack Rails [Facebook clone](https://facials.herokuapp.com/). While that was fun to build, there were lots of limitations posed by my skills in working with JavaScript on Rails. Further, I wanted to utilize the power of React but didn't want to put all logic for Rails and React in one huge application. For this reason I decided to create a shadow application that splits the front and backend.

## Table of Contents

- [fazebuk-api](#fazebuk-api)
  - [Table of Contents](#table-of-contents)
  - [Technologies used](#main-technologies-used)
  - [Install](#install)
  - [Usage](#usage)
  - [API](#api)
  - [Maintainers](#maintainers)
  - [Contributing](#contributing)
  - [License](#license)

## Main Technologies used

- Ruby on Rails
- PostgreSQL
- Devise
- JWT
- Pundit
- Jbuilder
- PG Search (for search capability)
- RSpec
- FactoryBot

## Install

Follow these steps:

- clone this repo
- `cd fazebuk-api`
- `bundle`

**Set up credentials**

In the terminal run:

```
$ EDITOR="<code editor name> --wait" rails credentials:edit
```

it will open up a `<filename>.credentials.yml`. In this file include the ff lines:

```ruby
db:
 username: <your local postgres username>
 password: <your local postgres password>
```

Save and close file. The following message should be shown in the terminal after saving and closing:

```
New credentials encrypted and saved.
```

**Set up database**

Run:

```
$ rails db:setup
```

## Usage

```
rails s
```

Goto `localhost:3000`

Use either `httpie` on the terminal or Postman to do requests

## Maintainer

[Ryan](https://github.com/rvvergara)

## Contributing

[Ryan](https://github.com/rvvergara)

PRs accepted.

## License

MIT © 2019 Ryan Vergara
