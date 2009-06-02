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
  # the name, analytics_id, and domain of the adapter that you are configuring. You can also
  # pass in a hash of hashes with multiple accounts. Setting <tt>rails_core_mixins</tt> to
  # true will mixin an accessor for this object into the core rails framework classes (active_record, action_controller and action_mailer). The default
  # for this is false so that there are no rails dependencies on the gem. The <tt>env</tt> by default is set to "production". The
  # rails mixin functionality checks this value against its RAILS_ENV then it calls out to the analytics only if the value is nil or matches.
  def self.config(type, analytics = {}, rails_core_mixins = false, env = "production")
    begin
      s = type.to_s + "_adapter"
      adapter = "AnalyticsGoo::" + s.camelize
      tracker = adapter.constantize.new(analytics, env)
      if rails_core_mixins
        for framework in ([ :active_record, :action_controller, :action_mailer ])
          framework.to_s.camelize.constantize.const_get("Base").send :include, AnalyticsGoo::InstanceMethods
        end
        silence_warnings { Object.const_set "ANALYTICS_TRACKER", tracker }
      end
      tracker
    rescue StandardError
      raise AnalyticsAdapterNotFound
    end
  end

  module InstanceMethods
    # any methods here will apply to instances
    def track_page_view(path, name=nil)
      if defined?(ANALYTICS_TRACKER)
        unless ANALYTICS_TRACKER.env != nil && ANALYTICS_TRACKER.env != RAILS_ENV
          ANALYTICS_TRACKER.track_page_view(path,name)
        end
      else
        nil
      end
    end
  end
end

