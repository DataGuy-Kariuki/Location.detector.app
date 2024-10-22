## Deployment: Replace with your actual account info
library(rsconnect)

# Set your account info
rsconnect::setAccountInfo(
   name='kamwanaanalyst',
   token='F2BECBC274AB97308196FFE5102B6C63',
   secret='Thjz9T/h9u3BTvOvxaeNkmEyBwc6N4xX7kzBl9Ah'
)

# Deploy to shinyapps.io with a valid application name
rsconnect::deployApp(
   appDir = 'C:/Users/XaviourAluku.BERRY/Documents/Course.sell/courses/map',
   appName = 'MyValidAppName'  # Change this to a valid name
)
