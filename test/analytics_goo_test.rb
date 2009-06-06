require 'test_helper'
require 'analytics_goo'

class AnalyticsGooTest < ActiveSupport::TestCase

  context "AnalyticsGoo " do
    setup do
      @analytics_config = { :analytics_id => "UA-2202604-2",:domain => "test.local" }
    end
    context "contains a GoogleAnalyticsAdapter which when passed initialization data" do
      should "be a valid class" do
        assert AnalyticsGoo::GoogleAnalyticsAdapter.new(@analytics_config)
      end
    end
    context "contains a GoogleAnalyticsAdapter when instantiated with the config method" do
      should "be a valid class" do
        assert AnalyticsGoo.config(:google_analytics, @analytics_config)
      end
    end
    should "raise an exception when instantiated with an invalid adapter" do
      assert_raise AnalyticsGoo::AnalyticsAdapterNotFound do
        AnalyticsGoo.config(:moogle_analytics, @analytics_config)
      end
    end
    context "can pass along an environment variable that" do
      setup do
        @analytics_config[:environment] = "test"
      end
     should "be passed along to the instantiated class" do
        assert_equal "test", AnalyticsGoo.config(:google_analytics, @analytics_config).env
      end
    end
  end

  context "AnalyticsGoo " do
    setup do
      @analytics_config = { :analytics_id => "UA-2202604-2",:domain => "test.local"}
      @ga = AnalyticsGoo::GoogleAnalyticsAdapter.new(@analytics_config)
      @ga.utmdt = "This is the page title"
      @ga.utmfl = "9.0 r124"
    end
    context "when initialized with an analytics id" do
      should "return that id" do
        assert_equal "UA-2202604-2", @ga.utmac
      end
    end
    context "when initialized with a domain" do
      should "return that domain" do
        assert_equal "test.local", @ga.domain
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
        assert_equal "UA-2202604-2", @ga.utmac
      end
      should "have a utmhn equal to the host name" do
        assert_equal "test.local", @ga.domain
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
        assert_equal "0x0", @ga.utmsr
      end
      should "have a utmsc equal to the screen color depth" do
        assert_equal "0-bit", @ga.utmsc
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
  end
  context "Rails Analyics" do
    setup do
      @ga2 = AnalyticsGoo::GoogleAnalyticsAdapter.new(:analytics_id => "UA-3536616-5",:domain => "demo.mobilediscovery.com")
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
      @ga3 = AnalyticsGoo::GoogleAnalyticsAdapter.new(:analytics_id => "UA-3536616-5",:domain => "demo.mobilediscovery.com")
    end
    context "makes a request for an image on the google analytics server" do
      setup do
        @resp = @ga3.track_page_view("/testFoo/myPage.html")
      end
      should "be a valid response" do
        assert @resp.is_a?(Net::HTTPOK)
      end
    end
  end
end
