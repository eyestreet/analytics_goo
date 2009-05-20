require File.join(File.dirname(__FILE__), "lib", "rails_analytics")

# add our functionality to rails core classes
for framework in ([ :active_record, :action_controller, :action_mailer ])
  framework.to_s.camelize.constantize.const_get("Base").send :include, RailsAnalytics::InstanceMethods
end

