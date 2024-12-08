This is the SSL certificate that you need to run some https/ connection with thirth parties, like Postmark.

# Why?

There is a long standing issue in Ruby where the *net/http* library by default does **not** check the validity of an SSL certificate during a TLS handshake. Rather than deal with the underlying problem (a missing certificate authority, a self-signed certificate, etc.) one tends to see [bad](http://stackoverflow.com/questions/1555006/how-do-i-tell-rubys-openssl-library-to-ignore-a-self-signed-certificate-error) [hacks](http://www.ruby-forum.com/topic/129530) [everywhere](http://www.peterkrantz.com/2007/open-uri-cert-verification/). This can lead to [problems](http://www.rubyinside.com/how-to-cure-nethttps-risky-default-https-behavior-4010.html) down the road.

From what I can see the OpenSSL library that [Rails Installer](http://railsinstaller.org) delivers has no certificate authorities defined. So, let's go fetch some from the [curl](http://curl.haxx.se/ca/) website. And since this is for ruby, why don't we download and install the file with a ruby script?

# Installation

## The Ruby Way! (Fun)

This assumes your have already installed the [Rails Installer](http://railsinstaller.org) for Windows.

Download the ruby script to your *Desktop* folder from [https://gist.github.com/raw/867550/win_fetch_cacerts.rb](https://gist.github.com/raw/867550/win_fetch_cacerts.rb). Then in your command prompt, execute the ruby script:

    ruby "%USERPROFILE%\Desktop\win_fetch_cacerts.rb"

Now make ruby aware of your certificate authority bundle by setting `SSL_CERT_FILE`. To set this in your current command prompt session, type:

    set SSL_CERT_FILE=C:\RailsInstaller\cacert.pem

To make this a permanent setting, add this in your [control panel](http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/environment_variables.mspx?mfr=true).

## The Manual Way (Boring)

Download the `cacert.pem` file from [http://curl.haxx.se/ca/cacert.pem](http://curl.haxx.se/ca/cacert.pem). Save this file to `C:\RailsInstaller\cacert.pem`.

Now make ruby aware of your certificate authority bundle by setting `SSL_CERT_FILE`. To set this in your current command prompt session, type:

    set SSL_CERT_FILE=C:\RailsInstaller\cacert.pem

To make this a permanent setting, add this in your [control panel](http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/environment_variables.mspx?mfr=true).