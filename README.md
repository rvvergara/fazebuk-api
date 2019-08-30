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
- Koala
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

**Endpoints (all examples use httpie)**

1. User Creation

```bash
$ http POST :3000/v1/users user:='{"username":"john123", "email":"johnny_bravo@email.org", "first_name":"John", "last_name":"Doe", "password":"password", "password_confirmation":"password"}'
```

2. User data update

```bash
# assuming username is john123
$ http PUT :3000/v1/users/john123 user:='{"first_name":"Johnny the Great"}'
```

3. Deleting user

```bash
# assuming username is john123
$ http DELETE :3000/v1/users/john123
```

4. Signing in a user through email and password

```bash
# assuming user email is johnny_bravo@email.com and password is 'password'
$ http POST :3000/v1/sessions email=johnny_bravo@email.com password=password
```

5. Signing in a user through Facebook/User creation (if user doesn't exist yet)

````bash
# for this to work we should have a Facebook access_token
$ http GET :3000/v1/auth/facebook?access_token=<facebook access token here>
### Friendship endpoints

6. Sending a friend request

```bash
# assuming you are logged in and has a token generated from signing in
# assuming username of user to send request to is 'mildred'
$ http POST :3000/v1/friendships?friend_requested=mildred "Authorization: Bearer <your user token here>"
````

7. Cancelling a friend request

```bash
# assuming you are logged in as the same user that sent mildred a request
# you can get the friendship_id thru the rails console
$ http DELETE :3000/v1/friendships/<friendship_id> "Authorization: Bearer <your token here>"
```

8. Confirming a friend request

```bash
# assuming now you are logged on as mildred
$ http PUT :3000/v1/friendships/<friendship_id> "Authorization: Bearer <mildred's token here>"
```

9. Rejecting a friend request

```bash
# still assuming mildred is logged on
$ http DELETE :3000/v1/friendships/<friendship_id> "Authorization: Bearer <mildred's token here>"
```

10. Checking a user's list of friends

```bash
$ http GET :3000/v1/users/<username of user>/friends "Authorization: Bearer <your token here>"
```

11. Checking your mutual friends with another user

```bash
# assuming you wanna see your mutual friends with mildred
$ http GET :3000/v1/users/mildred/mutual_friends "Authorization: Bearer <your token here>"
```

## Maintainer

[Ryan](https://github.com/rvvergara)

## Contributing

[Ryan](https://github.com/rvvergara)

PRs accepted.

## License

MIT © 2019 Ryan Vergara
