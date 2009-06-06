require 'uri'
require 'cgi'
require 'net/http'
require 'activesupport'
require 'analytics_goo/google_analytics_adapter'

module AnalyticsGoo
  # generic adapter not found exception
  class AnalyticsAdapterNotFound < StandardError
  end


  # Factory for returning the appropriate analytics object. The <tt>type</tt> is
  # a symbol that defines the type of analytics tracker you want to create. Currently,
  # the only acceptable value is :google_analytics. The <tt>analytics</tt> hash holds
  # the required keys of analytics_id and the domain of the adapter that you are configuring.
  # Setting the key <tt>rails_core_mixins</tt> to
  # true will mixin an accessor for this object into the core rails framework classes (active_record, action_controller and action_mailer). The default
  # for this is false so that there are no rails dependencies on the gem. The key <tt>environment</tt> by default is set to "production". The
  # rails mixin functionality checks this value against its RAILS_ENV then it calls out to the analytics only if the value is nil or matches.
  def self.config(type, analytics = {})
    begin
      s = type.to_s + "_adapter"
      adapter = "AnalyticsGoo::" + s.camelize
      analytics[:environment] = "production" if analytics[:environment].nil?
      if analytics[:rails_core_mixins] == true
        analytics[:noop] = (RAILS_ENV != analytics[:environment])
        tracker = adapter.constantize.new(analytics)
        for framework in ([ :active_record, :action_controller, :action_mailer ])
          framework.to_s.camelize.constantize.const_get("Base").send :include, AnalyticsGoo::InstanceMethods
        end
        silence_warnings { Object.const_set "ANALYTICS_TRACKER", tracker }
      else
        tracker = adapter.constantize.new(analytics)
      end
      tracker
    rescue StandardError
      raise AnalyticsAdapterNotFound
    end
  end

  module InstanceMethods
    # any methods here will apply to instances
    def analytics_goo
      if defined?(ANALYTICS_TRACKER)
          ANALYTICS_TRACKER
      else
        nil
      end
    end
  end
end

