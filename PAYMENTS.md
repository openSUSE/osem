# Integrate your Stripe account to accept your user's payments
Here you will find all the information that you need to setup your Stripe account into OSEM.
If you have any problems with installing don't hesitate to [contact us](https://github.com/openSUSE/osem#contact)

## Configure Stripe into the application
To configure Stripe into your application all you need to do is add the private and publishable keys into the Rails environment.

Add your Stripe API keys in `config/secrets.yml` into these variables:

If you are using the application in development mode your config should look like this:  
  `stripe_publishable_key = 'pk_**test**_random123example456'`  
  `stripe_secret_key = 'sk_**test**_random123example456'`

Otherwise, while in production mode, it should look like:  
  `stripe_publishable_key = 'pk_**live**_random123example456'`  
  `stripe_secret_key = 'sk_**live**_random123example456'`

### PCI Self Assessment Questionnaire(SAQ)
> As long as you serve your payment pages over TLS, and use either Checkout or Stripe.js 
> as the only way of handling card information, Stripe automatically creates a prefilled SAQ A questionnaire for you, 
> and you won’t need to undergo a PCI audit. If card data is stored or transferred through your servers, 
> you are responsible for following PCI DSS guidelines for handling card data, and periodic audits by a PCI-certified auditor.

As we are using Stripe Checkout for accepting payments, Stripe will help you for filling SAQ for your application.
You can read the full security documentation [here](https://stripe.com/docs/security).

## Configure the image for your payment form
The Stripe payment form uses an image of your organisation to display a personalised form for your application.
By default, the application comes with a openSUSE icon, but you can display the image of your organisation in place of that
by putting the URL of your organisation's image in your corresponding `.env` file as follows:  
  `OSEM_ICON = 'your organisation's sharable image link'`

## Configure Stripe to send emails for successful transactions
Stripe can send email reciepts for every successful payment done through its gateway.
Please refer [here](https://dashboard.stripe.com/account/emails) to enable invoice emails for your users.

## Customize Stripe invoice emails for your application
You can customise your payment reciepts by adding your personalisation like organisation name, logo etc.
Please see the options for invoice personalisation [here](https://dashboard.stripe.com/account/public).
