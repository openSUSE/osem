# Integrate your Stripe account to accept your user's payments
All the information that you need to setup your Stripe account into OSEM.
If you have any problems with installing don't hesitate to [contact us](https://github.com/openSUSE/osem#contact)

## Configure Stripe into the application
To configure Stripe into your application all you need to do is add the private and publishable keys into the Rails environment.

You can add the your keys in `dotenv.example` and in `config/secrets.yml` into these variables:

If you are using the application in development mode your config should look like this:  
  `STRIPE_PUBLISHABLE_KEY = 'pk_test_random123example456'`  
  `STRIPE_SECRET_KEY = 'sk_test_random123example456'`

Otherwise, while in production mode, it should look like:  
  `STRIPE_PUBLISHABLE_KEY = 'pk_live_random123example456'`  
  `STRIPE_SECRET_KEY = 'sk_live_random123example456'`

## Configure image for your iFrame payment form
The stripe payment form uses an image of your organisation to display a personalised iFrame form for your application.
by default, the application comes with a SUSE icon, but, you can display the image of your organisation in place of that
by replacing the image of your organisation at `app/assets/images/OSEM_ICON.jpg` to an image of your organisation.

## Configure Stripe to send custom emails for your organisation
Stripe sends email reciepts for every successful payment done through its gateway.
You can also customise your payment reciepts by adding your personalisation like organisation name, logo etc.

You can see the options for personalisation [here](https://dashboard.stripe.com/account/public).
