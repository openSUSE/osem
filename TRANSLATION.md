# Translation
We are using [Transifex] (https://www.transifex.com/opensuse-community/osem/) to manage our translations.

We are also using the _Live_ feature of Transifex. That means that all strings from OSEM instances are automatically collected and are available for translating.
>Automated collection only works if you use the API key (See at the end of this file)

## 1. Translate
  * Start translating:

    1. Navigate to the [project's page] (https://www.transifex.com/opensuse-community/osem)
    2. Click **translation** button
    3. Select **language**
    4. Select **resource** (events.opensuse.org)

Eg. Assuming you have signed up yourself as a translator for OSEM, to translate in German, for example, you go to: https://www.transifex.com/projects/p/osem/translate/#de_DE/eventsopensuseorg/31056760

  * Request a new language

    If you want to translate OSEM into a language that does not already exist, you can request a new language from the Transifex interface. Your request will have to be approved by an admin of the OSEM project in Transifex.

## 2. Publish translations
  * How to make translations visible (if you have the proper access):
    1.  Visit https://www.transifex.com/projects/p/osem/live/#en/events.opensuse.org
    2.  Click **Publish** (from right sidebar menu)
    3.  Select the language(s)
    4.  Click **Publish**

  * How to request to publish translated strings

    After you make sure that you have properly reviewed the newly translated strings (they need to be marked as **reviewed** otherwise they won't go live), you can open a [new issue] (https://github.com/openSUSE/osem/issues/new) with the following information:

    Title: [Transifex] Publish translation for EN

    Content: Publish new reviewed strings for language EN

  (You substitute EN with the initials of the language you want to publish)

> Note: We only publish **reviewed** translated strings

## 3. Use translations
You can view OSEM in other languages by selecting the language you want from the language selector icon (bottom right corner).

## 4. API key
When you run your own instance of OSEM, if you want to have the translations available you need to add the api key in the `.env.development` file:

`OSEM_TRANSIFEX_APIKEY="cf866a61277842b39c897c5a0b5ec075"`

## 5. Strings with dynamic contents

Strings containing dynamic content should be tagged in the haml file with "notranslate" classes as described in:

http://docs.transifex.com/live/webmasters/#how-to-handle-inline-block-variables
