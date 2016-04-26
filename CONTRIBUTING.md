# Request for contributions
We are always looking for contributions to OSEM. Read this guide on how to do that. 

In particular, this community seeks the following types of contributions:

* code: contribute your expertise in an area by helping us expand OSEM
* ideas: participate in an issues thread or start your own to have your voice heard.
* copy editing: fix typos, clarify language, and generally improve the quality of the content of OSEM

## How to contribute
* Prerequisites: familiarity with [GitHub Pull Requests](https://help.github.com/articles/using-pull-requests) and issues.
* Fork the repository and make a pull-request with your changes
  * Make sure that the test suite passes before you request a pull and that you comply to our ruby styleguide.
  * Please increase code coverage by your pull request (coveralls or simplecov locally will give you insight)
* One of the OSEM maintainers will review your pull-request
  * If you are already a contributor and you get a positive review, you can merge your pull-request yourself
  * If you are not a contributor already please request a merge via the pull-request comments

### Coding Style
We are using [rubocop](https://github.com/bbatsov/rubocop) as a style checker. It is checking code style each time the test suite runs. You can run it locally with

```shell
bundle exec rubocop
```

You can read through current enabled rules in `.rubocop.yml` file. Explanations of the defined [rules](http://rubydoc.info/github/bbatsov/rubocop/master/frames) can be found in modules [Cop::Lint](http://rubydoc.info/github/bbatsov/rubocop/master/Rubocop/Cop/Lint) and [Cop::Style](http://rubydoc.info/github/bbatsov/rubocop/master/Rubocop/Cop/Style).
Additionally you can read through the [ruby style-guide](https://github.com/bbatsov/ruby-style-guide) to better understand core principles.

### Test Suite
We are using [rspec](http://rspec.info/)+[capybara](http://jnicklas.github.io/capybara/)+[factory girl](https://github.com/thoughtbot/factory_girl) as a test suite. You can run it locally

```shell
bundle exec rspec
```
## Code of Conduct
OSEM is part of the openSUSE project. We follow all the [openSUSE Guiding Principles!](http://en.opensuse.org/openSUSE:Guiding_principles) If you think someone doesn't do that, please let us know at maintainers@osem.io

## Contact
GitHub issues are the primary way for communicating about specific proposed changes to this project. If you have other questions feel free to subscribe to the [opensuse-web@opensuse.org](http://lists.opensuse.org/opensuse-web/) mailinglist, all OSEM contributors are on that list! Additionally you can use #osem channel on freenode IRC.
