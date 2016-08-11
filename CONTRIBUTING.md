# Request for contributions
We are always looking for contributions to OSEM. Read this guide on how to do that. 

In particular, this community seeks the following types of contributions:

* code: contribute your expertise in an area by helping us expand OSEM
* ideas: participate in an issues thread or start your own to have your voice heard.
* copy editing: fix typos, clarify language, and generally improve the quality of the content of OSEM

### Runing OSEM for development
We are using [Vagrant](https://www.vagrantup.com/) to create our development environments.

1. Install [Vagrant](https://www.vagrantup.com/downloads.html) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads). Both tools support Linux, MacOS and Windows.

2. Install [vagrant-exec](https://github.com/p0deje/vagrant-exec):

    ```
    vagrant plugin install vagrant-exec
    ```

3. Clone this code repository:

    ```
    git clone https://github.com/openSUSE/osem.git
    ```

4. Execute Vagrant in the cloned directory:

    ```
    vagrant up
    ```

5. Start your OSEM rails app:

    ```
    vagrant exec rails server -b 0.0.0.0
    ```

6. Check out your OSEM rails app:
You can access the app [localhost:3000](http://localhost:3000). Whatever you change in your cloned repository will have effect in the development environment. Sign up, the first user will be automatically assigned the admin role.

7. Changed something? Test your changes!:

    ```
    vagrant exec bundle exec rspec spec
    ```

8. Explore the development environment:

    ```
    vagrant ssh
    ```

9. Or issue any standard `rails`/`rake`/`bundler` command by prepending `vagrant exec`

    ```
    vagrant exec bundle exec rake db:migrate
    ```

## How to contribute
* Prerequisite: familiarity with [GitHub Pull Requests](https://help.github.com/articles/using-pull-requests) and issues.
* Fork the repository and make a pull-request with your changes
  * Make sure that the test suite passes before you request a pull and that you comply to our ruby styleguide.
  * Please increase code coverage by your pull request (coveralls or simplecov locally will give you insight)
* One of the OSEM maintainers will review your pull-request
  * If you are already a contributor and you get a positive review, you can merge your pull-request yourself
  * If you are not a contributor already please request a merge via the pull-request comments

### Coding Style
We are using [rubocop](https://github.com/bbatsov/rubocop) as a style checker. It is checking code style each time the test suite runs. You can run it locally with

```shell
vagrant exec bundle exec rubocop
```

You can read through current enabled rules in `.rubocop.yml` file. Explanations of the defined [rules](http://rubydoc.info/github/bbatsov/rubocop/master/frames) can be found in modules [Cop::Lint](http://rubydoc.info/github/bbatsov/rubocop/master/Rubocop/Cop/Lint) and [Cop::Style](http://rubydoc.info/github/bbatsov/rubocop/master/Rubocop/Cop/Style).
Additionally you can read through the [ruby style-guide](https://github.com/bbatsov/ruby-style-guide) to better understand core principles.

### Test Suite
We are using [rspec](http://rspec.info/)+[capybara](http://jnicklas.github.io/capybara/)+[factory girl](https://github.com/thoughtbot/factory_girl) as a test suite. You can run it locally

```shell
vagrant exec bundle exec rspec
```

## Code of Conduct
OSEM is part of the openSUSE project. We follow all the [openSUSE Guiding Principles!](http://en.opensuse.org/openSUSE:Guiding_principles) If you think someone doesn't do that, please let us know at maintainers@osem.io

## Contact
GitHub issues are the primary way for communicating about specific proposed changes to this project. If you have other questions feel free to subscribe to the [opensuse-web@opensuse.org](http://lists.opensuse.org/opensuse-web/) mailinglist, all OSEM contributors are on that list! Additionally you can use #osem channel on freenode IRC.

### Email Notifications
**Note**: We use [letter_opener](https://github.com/ryanb/letter_opener) in development environment. You can check out your mails by visiting [localhost:3000/letter_opener](http://localhost:3000/letter_opener).

### Using iChain in test mode
[devise_ichain_authenticatable](https://github.com/openSUSE/devise_ichain_authenticatable) comes with
test mode, which can be useful in development phase in which an iChain proxy is
not usually configured or even available. You can enable ichain authentication by setting `OSEM_ICHAIN_ENABLED` equal to `true` in `.env` file. You would also need to set following options in `devise.rb`:

```Ruby
# Activate the test mode
config.ichain_test_mode = true

# 'testuser' user will be permanently signed in.
config.ichain_force_test_username = "testuser"

# set email of 'testuser'
config.ichain_force_test_attributes = {:email => "testuser@example.com"}
```
