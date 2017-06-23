# Contributing to OSEM
Our open source project is open to contributions. Open your [issue](https://github.com/openSUSE/osem/issues/new) and send a PR!

We welcome new developers, and we actively participate in mentoring programs, such as [GSoC](https://summerofcode.withgoogle.com/) and [RGSoC](https://railsgirlssummerofcode.org/).

## Request for contributions
We are always looking for contributions to OSEM. Read this guide on how to do that.

In particular, this community seeks the following types of contributions:

* code: contribute your expertise in an area by helping us expand OSEM
* ideas: participate in an issues thread or start your own to have your voice heard.
* code editing: fix typos, clarify language, and generally improve the quality of the content of OSEM

## Running OSEM in development
We are using [Vagrant](https://www.vagrantup.com/) to create our development environments.

1. Install [Vagrant](https://www.vagrantup.com/downloads.html) and [VirtualBox 5.0.10](https://www.virtualbox.org/wiki/Download_Old_Builds_5_0). Both tools support Linux, MacOS and Windows.

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

5. Deploy the initial database migration:

    ```
    vagrant exec bundle exec rake db:migrate
    ```

6. Start your OSEM rails app:

    ```
    vagrant exec /vagrant/bin/rails server -b 0.0.0.0
    ```

7. Check out your OSEM rails app:
You can access the app [localhost:3000](http://localhost:3000). Whatever you change in your cloned repository will have effect in the development environment. Sign up, the first user will be automatically assigned the admin role.

8. Changed something? Test your changes!:

    ```
    vagrant exec bundle exec rspec spec
    ```

9. Explore the development environment:

    ```
    vagrant ssh
    ```

10. Or issue any standard `rails`/`rake`/`bundler` command by prepending `vagrant exec`

    ```
    vagrant exec bundle exec rake db:migrate
    ```

## How to contribute code
* Prerequisite: familiarity with [GitHub Pull Requests](https://help.github.com/articles/using-pull-requests) and issues.
* Fork the repository and make a pull-request with your changes
  * Make sure that the test suite passes before you request a pull and that you comply to our ruby styleguide.
  * Please increase code coverage by your pull request (coveralls or simplecov locally will give you insight)
* One of the OSEM maintainers will review your pull-request
  * If you are already a contributor and you get a positive review, you can merge your pull-request yourself
  * If you are not already a contributor please request a merge via the pull-request comments

### Getting Started

* When you get involved with OSEM for the first time, you can choose issues labeled as [Junior]( https://github.com/openSUSE/osem/issues?q=is%3Aissue+is%3Aopen+label%3AJunior)
* Leave a comment on the issue that you want to work on it
  * We expect you to work on it and show progress by either opening a PR or commenting on the issue
  * If you change  your mind, and do not want to work on the issue any more, please be fair to others and leave a comment to let us know
  * Do **not** work on issues that are assigned to others. If you are uncertain, ask and wait for a **contributor** to reply
* Avoid working on issues that have no label
  * If you have opened a new issue, please wait for a contributor to add relevant labels
* If an issue is a feature, we should first have a rough idea on how we want to implement it
  * If there is already such a discussion on the issue, you can go ahead and pick this up
  * If not, please first leave a comment on how you want to implement it and wait for contributors' feedback

### Commits
* Commit title should be short and descriptive
  * title (or summary line) is the first line of the commit message
  * that says what the commit is doing
  * in no more than 50 characters
  * starting with a word like 'Fix' or 'Add' or 'Change'
  * **without** a period (.) at the end
  * followed by a blank line
* Commit messages are
  * up to 72 characters
  * with break lines
* Reference the issue(s) the commit closes
  * https://help.github.com/articles/closing-issues-via-commit-messages
  * If you haven't done so since the beginning, you should reference the issue when you squash your commits

### Pull Requests workflow
Please open a pull request (PR) only when you have finished coding, and your changes are ready to be reviewed for merging.

* Title
  * Include a comprehensive title about what this PR is doing
  * Referencing the issue number on the PR title is not giving any information about what this PR is about
  * The title should be short (50 characters maximum); you can add more information in the description
* Description
  * Add a couple of lines about what is the problem you are trying to solve and how you have addressed it
  * Add bullet points about the new things you are introducing, if applicable
  * Reference the issue(s) you are solving
  * Add a screenshot of your change, if you are working on something that changes how the app looks like
* Automated checks
  * We automatically run the [test suite](https://github.com/openSUSE/osem/blob/master/CONTRIBUTING.md#test-suite) and security checks on every PR
  * Check back later to see if all checks were successful, if not, address them or leave a comment to ask for help
* Pushing new changes to your PR
  * Always add **new** commits; this tremendously helps reviewers
  * Do not squash commits, unless explicitly requested by the reviewer
* Take care of your PR
  * Make sure you check the status of your PR regularly
  * Address your reviews, make the necessary changes, ask if something is not clear to you
  * Rebase against newest changes, when needed; we cannot properly review PRs that are not rebased

Reviewing your PR might take some time, as we are all volunteers. Please be responsive and respectful.

### Coding Style
We are using [rubocop](https://github.com/bbatsov/rubocop) as a style checker. It is checking code style each time the test suite runs. You can run it locally with

```shell
vagrant exec bundle exec rubocop
```

You can read through current enabled rules in `.rubocop.yml` file. Explanations of the defined [rules](http://rubydoc.info/github/bbatsov/rubocop/master/frames) can be found in modules [Cop::Lint](http://rubydoc.info/github/bbatsov/rubocop/master/Rubocop/Cop/Lint) and [Cop::Style](http://rubydoc.info/github/bbatsov/rubocop/master/Rubocop/Cop/Style) and [Cop:Rails](https://rubocop.readthedocs.io/en/latest/cops_rails/).
Additionally you can read through the [ruby style-guide](https://github.com/bbatsov/ruby-style-guide) to better understand core principles.

### Test Suite
We are using [rspec](http://rspec.info/)+[capybara](http://jnicklas.github.io/capybara/)+[factory girl](https://github.com/thoughtbot/factory_girl) as a test suite. You can run it locally

```shell
vagrant exec bundle exec rspec
```

### Review App of your PR

OSEM uses [Review Apps](https://devcenter.heroku.com/articles/github-integration-review-apps) on Heroku.

* The review app can be manually created by a maintainer, and when that happens you will see a relevant message in the PR

* Please help reviewers by adding the necessary data relevant to your PR,
eg. if your PR is doing something related to conference registrations, go to the review app and make sure there is a conference with registrations.


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

### Using OpenID in developement
OSEM supports [OpenID](https://openid.net/) logins via [OmniAuth](https://github.com/omniauth/omniauth) and related provider specific gems. OmniAuth provides the ablity to define per-provider mock accounts for testing. The supported providers are Facebook, Google, openSUSE and GitHub. If you want to use the OSEM provided mock accounts you need to set the appropriate `OSEM_PROVIDER_KEY` and `OSEM_PROVIDER_SECRET` environment variables to a non empty string in the `.env` file.

e.g.
```
OSEM_GITHUB_KEY='sample'
OSEM_GITHUB_SECRET='sample'
```

If you don't already have a `.env` file you can use the `dotenv.example` as a template.

## Labels for issues and PRs
...and what they mean!

1. **Bug**
  * A bug in the application, something is wrong and needs to be fixed!
  * Ideally the issue includes details on how to reproduce the bug
  * Reproduce the bug in master branch, and send a PR that solves it
2. **Design**
  * Related to the looks and/or usability of the application; needs attention from someone who understands front-end and UX
  * If you are good with graphics and design, give it a shot!
3. **Documentation**
  * Related to the documentation of our application, eg our INSTALL.md file or a wiki page with instructions on how to use the app, or part of it.
  * If you are working on a documentation issue, make sure you are covering all cases.
4. **Epic**
  * We may, or may not, solve this, thus it is epic. It's bigger than a feature request, because it fundamentally changes or affects the app, or a significant part of it.
  * Do **not** work on this without prior discussion with the maintainers, it's called epic for a reason!
5. **Feature**
  * This is a new feature for something new in the app!
  * If an issue is labeled *Feature*, don't work on the issue, unless the maintainers have decided on how to proceed
  * Ideally, leave a comment with your proposed solution in the issue and wait for feedback
6. **Grooming**
  * This is working, but could look better, thus needs some attention and grooming.
7. **Hacktoberfest**
  * This is for the issues included in the coding event of Hacktoberfest. You can ignore it, when the event is not on
8. **in progress**
9. **Junior**
  * For new comers! RoR beginners or people unfamiliar with the application. Where you must start if you are interested in a mentoring program we participate in.
10. **need feedback**
  * Maintainers' attention is needed to decide if this is something we want in the app, and/or how it should be implemented
11. **Operation**
12. **ready**
13. **Refactorization**
  * Our code needs to be re-written; to avoid code duplication, or make the code more readable, or do things in a simpler way!
14. **Research**
  * Ideas to explore; and think if there is anything we want to include in our app.
15. **GSoC**
  * To group all the issues and PRs related to Google Summer of Code together.

## Code of Conduct
OSEM is part of the openSUSE project. We follow all the [openSUSE Guiding Principles!](http://en.opensuse.org/openSUSE:Guiding_principles) If you think someone doesn't do that, please let us know at maintainers@osem.io

## Contact
GitHub issues are the primary way for communicating about specific proposed changes to this project. If you have other questions feel free to subscribe to the [opensuse-web@opensuse.org](http://lists.opensuse.org/opensuse-web/) mailinglist, all OSEM contributors are on that list! Additionally you can use #osem channel on freenode IRC.
