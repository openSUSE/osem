# Contributing to OSEM

We here at OSEM are open for all types of contributions from anyone. Tell us about our [issues/ideas](https://github.com/openSUSE/osem/issues/new), propose code changes via [pull requests](https://help.github.com/articles/using-pull-requests) or contribute artwork and documentation.

We welcome all new developers and are also prepared to mentor you through your first contributions! All OSEM maintainers are seasoned developers and have participated in mentoring programs, such as [GSoC](https://summerofcode.withgoogle.com/) and [RGSoC](https://railsgirlssummerofcode.org/).

We need your input and contributions to OSEM. In particular we seek the following types:

* **code**: contribute your expertise in an area by helping us expand OSEM with features/bugfixes/UX
* **code editing**: fix typos, clarify language, and generally improve the quality of the content of OSEM
* **ideas**: participate in an issues thread or start your own to have your voice heard
* **translations**: translate OSEM into other languages than English

Read this guide on how to do that.

## How to contribute code

1. Fork the repository and make a pull-request with your changes
    1. Make sure that the test suite passes and that you comply to our code style
    1. Please increase code coverage with your pull request
1. One of the OSEM maintainers will review your pull-request
    1. If you are already a contributor and you get a positive review, you can merge your pull-request yourself
    1. If you are not already a contributor, one of the existing contributors will merge your pull-request

**However, please bear in mind the following things:**

### Discuss Large Changes in Advance

If you see a glaring flaw within OSEM, resist the urge to jump into the
code and make sweeping changes right away. We know it can be tempting, but
especially for large, structural changes it's a wiser choice to first discuss
them in the [issue list](https://github.com/openSUSE/osem/issues).

A good rule of thumb, of what a *structural change* is, is to estimate how much
time would be wasted if the pull request was rejected. If it's a couple of minutes
then you can probably dive head first and eat the loss in the worst case. Otherwise,
making a quick check with the other developers could save you lots of time down the line.

Why? It may turn out that someone is already working on this or that someone already
has tried to solve this and hit a roadblock, maybe there even is a good reason
why this particular flaw exists? If nothing else, a discussion of the change will
usually familiarize the reviewer with your proposed changes and streamline the
review process when you finally create a pull request.

### Small Commits & Pull Request Scope

A commit should contain a single logical change, the scope should be as small
as possible. And a pull request should only consist of the commits that you
need for your change. If it's possible for you to split larger changes into
smaller blocks please do so.

Why? Limiting the scope of commits/pull requests makes reviewing much easier.
Because it will usually mean each commit can be evaluated independently and a
smaller amount of commits per pull request usually also means a smaller amount
of code to be reviewed.

### Proper Commit Messages

We are keen on proper commit messages because they will help us to maintain
this code in the future. We define proper commit messages like this:

* The title of your commit message summarizes **what** has been done
* The body of your commit message explains **why** you have done this

If the title is to small to explain **what** you have done, then you can of course
elaborate about it in the body. Please avoid explaining *how* you have done this,
we are developers too and we see the diff, if we do not understand something we will
ask you in the review.

Additional to **what** and **why** you should explain potential **side-effects** of
this change, if you are aware of any.

The content is most important, but please also use a [proper style](https://github.com/openSUSE/osem/wiki/Commit-message-guidelines).

## Development Environment

To isolate your host system from OSEM development we have prepared a container
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

1. Build the development environment (only once)
   ```bash
   docker-compose build --no-cache --pull
   ```
1. Set up the development environment (only once)
   ```bash
   docker-compose run --rm osem bundle exec rake db:bootstrap
   ```
1. Start the development environment:
   ```bash
   docker-compose up --build
   ```

1. Check out your OSEM rails app. You can access the app at http://localhost:3000. Whatever you change in your cloned repository will have effect in the development environment. Sign up, the first user will be automatically assigned the admin role.

1. Changed something? Run the tests to verify your changes!
   ```bash
   docker-compose run --rm osem bundle exec rspec spec
   ```

1. Issue any standard `rails`/`rake`/`bundler` command
   ```bash
   docker-compose run --rm osem bundle exec rake db:version
   ```

1. Or explore the development environment:
   ```bash
   docker-compose exec osem /bin/bash -l
   ```

1. Want to know more? In our [wiki](https://github.com/openSUSE/osem/wiki) you can find more information about what is possible in our development environment, how we work with each other on github or other topics of interest for OSEM developers.

## How to contribute translations

Please refer to our [translation guide](https://github.com/openSUSE/osem/wiki/Translation) in the wiki.

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
on [libera.chat IRC](https://libera.chat).
