# AnalyticsGoo

AnalyticsGoo is a gem (or plugin) that provides server side non-javascript tracking using google analytics. 

## Install

gem install eyestreet-analytics_goo

## Example
   The simple usage is the following:
   
        tracker = AnalyticsGoo.config(:google_analytics, 
                                      :name => :test,
                                      :analytics_id => "UA-3536616-5", 
                                      :domain => "demo.eyestreet.com")

        tracker.track_page_view("/foo")

The first parameter passed to the config initializes the desired analytics adapter. Currently we only support
Google Analytics. The subsequent hash provide a name for the account, the analytics id, and a domain.

## Rails Usage

In your environment.rb add the following:

  config.gem "analytics_goo", :lib => "analytics_goo"
  

You can call things  in the same way as above, or you can mix in some additional rails specific functionality that is shown below.
In an intializer like config/initializers/analytics_goo.rb or in your appropriate environment.rb file

        AnalyticsGoo.config(:google_analytics, 
                            { :name => :test, :analytics_id => "UA-3536616-5", :domain => "demo.eyestreet.com" }, 
                            true, "production")

* analytics type - Currently we only support :google_analytics
* analytics configuration - Name, account id, and domain
* rails_core_mixins - Defaults to false. If set to true then you get an accessor method on rails core classes for analytics_goo
* environment - The RAILS_ENV environment that the analytics code should be called in. In all other environments it is a noop.

Then in your models, controllers, and mailers you can do the following:

    user = User.find(:first)
    user.track_page_view("/found_my_first_user")

## Testing

Check test/test_helper.rb to make sure you have the required gems installed.

  rake test
  or
  autotest

# Credits

AnalyticsGoo is maintained by [Rob Christie](mailto:rob.christie@eyestreet.com) and is funded by [EyeStreet Software](http://www.eyestreet.com).


Copyright (c) 2009 rwc9u, Eyestreet Software released under the MIT license
