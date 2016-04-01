FROM opensuse:42.1
RUN zypper -q -n --non-interactive install update-alternatives ruby-devel make gcc gcc-c++ libxml2 libxml2-devel libxslt-devel nodejs screen libmysqld-devel sqlite3-devel imagemagick

ENV APP_HOME /osem
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN echo 'install: --no-format-executable' >> /etc/gemrc
RUN gem install bundler
RUN gem install nokogiri -v '1.6.7.2' -- --use-system-libraries
RUN bundle install
RUN gem install tzinfo
RUN gem install tzinfo-data

ADD . $APP_HOME
ADD config/database.yml.example config/database.yml
ADD config/config.yml.example config/config.yml
ADD config/secrets.yml.example config/secrets.yml
RUN touch db/production.sqlite3
RUN touch db/development.sqlite3
RUN touch db/test.sqlite3

EXPOSE 8080
CMD rake db:create && rake db:migrate && rails:update:bin && rails s -p 8080 -b '0.0.0.0'
