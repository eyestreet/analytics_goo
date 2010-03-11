# AnalyticsGoo

AnalyticsGoo is a gem (or plugin) that provides server side non-javascript tracking using google analytics. The original version tried to mock-up the tracking for use with the UA-* web property ids. The problem with going that route was that all tracking occurs under a single IP address. I have made changes so that it now support google's new MO-* mobile site tracking that allows you to pass the remote IP address via a parameter. The initial intent was to make this look like a logger object. With a single instance that can be used throughout the system; however that is no longer what is needed for our system. We actually need a new version for each request, so the code is still changing.

## Install

gem install eyestreet-analytics_goo


## Newer usage pattern
   Initially I made an adapter pattern thinking that we would support multiple analytics packages. So far I only need Google Analytics:

      tracker =  AnalyticsGoo::GoogleAnalyticsAdapter.new(:analytics_id => "MO-11685745-3",
                                                      :domain => "shor.tswit.ch",
                                                      :remote_address => "75.103.6.17",
                                                      :user_agent => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6",
                                                      :http_accept_language => "en-us,en;q=0.5")
      tracker.track_page_view("/testFoo/myPage.html")




## Example
   The simple usage is the following:
   
        tracker = AnalyticsGoo.config(:google_analytics, 
                                      :analytics_id => "MO-11685745-3", 
                                      :domain => "demo.eyestreet.com")

        tracker.track_page_view("/foo")

The first parameter passed to the config initializes the desired analytics adapter. Currently we only support
Google Analytics. The subsequent hash provide a name for the account, the analytics id, and a domain.

## Rails Usage

In your environment.rb add the following:

  config.gem "analytics_goo", :lib => "analytics_goo"
  

You can call things  in the same way as above, or you can mix in some additional rails specific functionality that is shown below.
In an intializer like config/initializers/analytics_goo.rb or in your appropriate environment.rb file

        AnalyticsGoo.config(:google_analytics, :analytics_id => "MO-11685745-3", 
                                               :domain => "demo.eyestreet.com", 
                                               :rails_core_mixins => true, 
                                               :environment => "production")

* analytics type - Currently we only support :google_analytics

The analytics option hash takes the following:

* :analytics_id
* :domain
* :rails_core_mixins - Defaults to false. If set to true then you get an accessor method on rails core classes for analytics_goo
* :environment - The RAILS_ENV environment that the analytics code should be called in. In all other environments it is a noop.

Then in your models, controllers, and mailers you can do the following:

    user = User.find(:first)
    user.analytics_goo.track_page_view("/found_my_first_user")

## Testing

Check test/test_helper.rb to make sure you have the required gems installed.

  rake test
  or
  autotest

# Credits

AnalyticsGoo is maintained by [Rob Christie](mailto:rob.christie@eyestreet.com) and is funded by [EyeStreet Software](http://www.eyestreet.com).


Copyright (c) 2009 rwc9u, Eyestreet Software released under the MIT license
