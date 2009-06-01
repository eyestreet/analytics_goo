require 'test_helper'
require 'rails_analytics'

class RailsAnalyticsTest < ActiveSupport::TestCase

  context "RailsAnalytics contains a GoogleAnalyticsAdapter which when passed initialization data" do
    setup do
      @analytics_config = { :name => "test",:analytics_id => "UA-2202604-2",:domain => "test.local", :type => :google_analytics }
    end
    should "be a valid class" do
      assert RailsAnalytics::GoogleAnalyticsAdapter.new(@analytics_config)
    end
  end
  context "RailsAnalytics can be initialized with two analytics accounts" do
    setup do
      @analytics_config = {"test" => { :name => "test",:analytics_id => "UA-2202604-2",:domain => "test.local", :type => :google_analytics },
                           "test2" => { :name => "test2",:analytics_id => "UA-2202604-3",:domain => "test.local", :type => :google_analytics }
                          }
    end
    should "be a valid class" do
      assert RailsAnalytics::GoogleAnalyticsAdapter.new(@analytics_config)
    end
  end
  context "Rails Analytics " do
    setup do
      @analytics_config = { :name => "test",:analytics_id => "UA-2202604-2",:domain => "test.local", :type => :google_analytics }
      @ga = RailsAnalytics::GoogleAnalyticsAdapter.new(@analytics_config)
    end
    context "when initialized with an analytics id" do
      should "return that id" do
        assert_equal "UA-2202604-2", @ga.utmac("test")
      end
    end
    context "when initialized with a domain" do
      should "return that domain" do
        assert_equal "test.local", @ga.domain("test")
      end
    end
    context "that has been initialized" do
      should "have an urchin url" do
        assert_equal "http://www.google-analytics.com/__utm.gif", @ga.urchin_url
      end
    end
    context "when included and told that the url needs to be ssl" do
      should "have an https URL" do
        assert_equal "https://www.google-analytics.com/__utm.gif", @ga.urchin_url(true)
      end
    end
    context "creates an image URL that " do
      should "have a utmac equal to the specified analytics id" do
        assert_equal "UA-2202604-2", @ga.utmac("test")
      end
      should "have a utmhn equal to the host name" do
        assert_equal "test.local", @ga.domain("test")
      end
      should "have a utmfl equal to the flash version installed" do
        assert_equal "9.0 r124", @ga.utmfl
      end
      should "have a utmcs equal to the language encoding used for the browser." do
        assert_equal "UTF-8", @ga.utmcs
      end
      should "have a utmdt equal to the Page Title of the page" do
        assert_equal "This is the page title", @ga.utmdt
      end
      should "have a utmje equal to 1" do
        assert_equal "1", @ga.utmje
      end
      should "have a utmn equal to a random number that is generated to prevent caching" do
        assert @ga.utmn != @ga.utmn
      end
      should "have a utmsr equal to the screen resolution" do
        assert_equal "2400x1920", @ga.utmsr
      end
      should "have a utmsc equal to the screen color depth" do
        assert_equal "24-bit", @ga.utmsc
      end
      should "have a utmul equal to the browser language" do
        assert_equal "en-us", @ga.utmul
      end
      should "have a utmwv equal to the tracking code version" do
        assert_equal "4.3", @ga.utmwv
      end
      should "have a utmr equal to the referring page" do
        assert_equal "-", @ga.utmr
      end
      should "have a utmcr set to 1" do
        assert_equal "1", @ga.utmcr
      end
    end
    context "has various cookie values that need to be passed encoded and passed along" do
      should "have a utmcc cookie within a certain range " do
        assert @ga.utmcc_cookie >= 10000000 && @ga.utmcc_cookie <= 99999999
      end
    end
  end
  context "Rails Analyics" do
    setup do
      @ga2 = RailsAnalytics::GoogleAnalyticsAdapter.new(:name => :test, :analytics_id => "UA-3536616-5",:domain => "demo.mobilediscovery.com",:type => :google_analytics)
      @ga2.expects(:utmcc_cookie).times(2).returns(10000001)
      @ga2.expects(:utmcc_random).returns(1147483647)
      @now = Time.now.to_i
      @ga2.expects(:utmcc_time).times(4).returns(@now)
    end
    should "return a well formed utmcc cookie" do
      assert_equal "__utma%3D10000001.1147483647.#{@now}.#{@now}.#{@now}.10%3B%2B__utmz%3D10000001.#{@now}.1.1.utmcsr%3D(direct)%7Cutmccn%3D(direct)%7Cutmcmd%3D(none)%3B", @ga2.utmcc
    end
  end
  # TODO: mock this test. Currently it actually does do a request. Was using this to verify that it actually was working.
  context "An analytics tracking event" do
    setup do
      @ga3 = RailsAnalytics::GoogleAnalyticsAdapter.new(:name => :test, :analytics_id => "UA-3536616-5",:domain => "demo.mobilediscovery.com",:type => :google_analytics)
    end
    context "makes a request for an image on the google analytics server" do
      setup do
        @resp = @ga3.track("/testFoo/myPage.html")
      end
      should "be a valid response" do
        assert @resp[0].is_a?(Net::HTTPOK)
      end
    end
  end
end
