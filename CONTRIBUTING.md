# Contributing to OSEM
We here at OSEM are open for all types of contributions from anyone. Tell us about our [issues/ideas](https://github.com/openSUSE/osem/issues/new), propose code changes via [pull requests](https://help.github.com/articles/using-pull-requests) or contribute artwork and documentation.

We welcome all new developers and are also prepared to mentor you through your first contributions! All OSEM maintainers are seasoned developers and have participated in mentoring programs, such as [GSoC](https://summerofcode.withgoogle.com/) and [RGSoC](https://railsgirlssummerofcode.org/).

We need your input and contributions to OSEM. In particular we seek the following types:

* **code**: contribute your expertise in an area by helping us expand OSEM with features/bugfixes/UX
* **code editing**: fix typos, clarify language, and generally improve the quality of the content of OSEM
* **ideas**: participate in an issues thread or start your own to have your voice heard

Read this guide on how to do that.

## How to contribute code
1. Fork the repository and make a pull-request with your changes
    1. Make sure that the test suite passes and that you comply to our code style
    1. Please increase code coverage with your pull request
1. One of the OSEM maintainers will review your pull-request
    1. If you are already a contributor and you get a positive review, you can merge your pull-request yourself
    1. If you are not already a contributor, one of the existing contributors will merge your pull-request

## Development Environment

### with docker-compose
To isolate you host system from OSEM development we have prepared a container
based development environment, based on [docker](https://www.docker.com/) and
[docker-compose](https://docs.docker.com/compose/). Here's a step by step guide
how to set it up.

**WARNING**: Since we mount the repository into our container, your user id and
the id of the osem user inside the container need to be the same. If your user
id (`id -u`) is something else than `1000` you can copy the docker-compose
override example file and in it, set your user id in the variable
*CONTAINER_USERID*.

```bash
sed "s/13042/`id -u`/" docker-compose.override.yml.example > docker-compose.override.yml
```


1. Set up the development environment:
    ```bash
    docker-compose run --rm osem bundle exec rake db:bootstrap
    ```

1. Start the development environment:
    ```bash
    docker-compose up --build
    ```

1. Check out your OSEM rails app. You can access the app at http://localhost:3000. Whatever you change in your cloned repository will have effect in the development environment. Sign up, the first user will be automatically assigned the admin role.

1. Changed something? Test your changes!
    ```bash
    docker-compose run --rm osem bundle exec rspec spec
    ```

1. Issue any standard `rails`/`rake`/`bundler` command
    ```bash
    docker-compose run --rm osem bundle exec rake db:version
    ```

1. Or explore the development environment:
    ```bash
    docker-compose exec osem_1 /bin/bash -l
    ```

### with Vagrant
Another option is using [Vagrant](https://www.vagrantup.com/) and [VirtualBox 5.0.10](https://www.virtualbox.org/wiki/Download_Old_Builds_5_0) to create your development environment.

1. Install [vagrant-exec](https://github.com/p0deje/vagrant-exec):

    ```bash
    vagrant plugin install vagrant-exec
    ```

1. Start the development environment

    ```
    vagrant up
    ```

1. Start OSEM inside the development environment

    ```
    vagrant exec /vagrant/bin/rails server -b 0.0.0.0
    ```

6. Check out your OSEM rails app:
You can access the app [localhost:3000](http://localhost:3000). Whatever you change in your cloned repository will have effect in the development environment. Sign up, the first user will be automatically assigned the admin role.

7. Changed something? Test your changes!:

    ```
    vagrant exec bundle exec rspec spec
    ```

9. Issue any standard `rails`/`rake`/`bundler` command

    ```
    vagrant exec bundle exec rake db:migrate
    ```

8. Or explore the development environment:

    ```
    vagrant ssh
    ```

## Want to know more?
In our wiki you can find more information about what is possible in our development environment,
how we work with each other on github or other topics of interest for developers. Visit us at
>>>>>>> Introduces docker-compose to the contribution guide

https://github.com/openSUSE/osem/wiki

## Code of Conduct
OSEM is part of the openSUSE project. We follow all the
[openSUSE Guiding Principles!](http://en.opensuse.org/openSUSE:Guiding_principles)
If you think someone doesn't do that, please let us know at maintainers@osem.io or
address your concerns to the [openSUSE Board](https://en.opensuse.org/openSUSE:Board).

## Contact
GitHub issues and pull requests are the primary way for communicating about specific proposed
changes to this project. If you have other questions feel free to subscribe to
the [opensuse-web@opensuse.org](http://lists.opensuse.org/opensuse-web/)
mailinglist, all OSEM contributors are on that list! Additionally you can use the #osem channel
on freenode IRC.
