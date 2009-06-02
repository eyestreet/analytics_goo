require 'uri'
require 'cgi'
require 'net/http'
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
  # for this is false so that there are no rails dependencies on the gem.
  def self.config(type, analytics = {}, rails_core_mixins = false)
    begin
      s = type.to_s + "_adapter"
      adapter = "AnalyticsGoo::" + s.camelize
      tracker = adapter.constantize.new(analytics)
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
    def analytics_goo
      if defined?(ANALYTICS_TRACKER)
        ANALYTICS_TRACKER
      else
        nil
      end
    end
  end
end

