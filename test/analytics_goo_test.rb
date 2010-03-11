require 'test_helper'
require 'analytics_goo'

class AnalyticsGooTest < ActiveSupport::TestCase

  context "AnalyticsGoo " do
    setup do
      @analytics_config = { :analytics_id => "MO-11685745-3",:domain => "test.local" }
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
      @analytics_config = { :analytics_id => "MO-11685745-3",:domain => "test.local", :page_title => "This is the page title"}
      @ga = AnalyticsGoo::GoogleAnalyticsAdapter.new(@analytics_config)
    end
    context "when initialized with an analytics id" do
      should "return that id" do
        assert_equal "MO-11685745-3", @ga.utmac
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
        assert_equal "MO-11685745-3", @ga.utmac
      end
      should "have a utmhn equal to the host name" do
        assert_equal "test.local", @ga.domain
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
        assert_equal "4.4sj", @ga.utmwv
      end
      should "have a utmr equal to the referring page" do
        assert_equal "-", @ga.utmr
      end
      should "have a utmcr set to 1" do
        assert_equal "1", @ga.utmcr
      end
    end
  end
  context "Rails Analytics" do
    setup do
      @ga2 = AnalyticsGoo::GoogleAnalyticsAdapter.new(:analytics_id => "MO-11685745-3",:domain => "shor.tswit.ch", :remote_address => "75.103.6.17")
      # @ga2.expects(:utmcc_cookie).times(2).returns(10000001)
      # @ga2.expects(:utmcc_random).returns(1147483647)
      # @now = Time.now.to_i
      # @ga2.expects(:utmcc_time).times(4).returns(@now)
    end
    should "return a well formed utmcc cookie that is stubbed to the value provided in google analytic mobile tracker docs" do
      assert_equal "__utma%3D999.999.999.999.999.1%3B", @ga2.utmcc
    end
  end
  # TODO: mock this test. Currently it actually does do a request. Was using this to verify that it actually was working.
  context "An analytics tracking event" do
    setup do
      @ga3 = AnalyticsGoo::GoogleAnalyticsAdapter.new(:analytics_id => "MO-11685745-3",
                                                      :domain => "shor.tswit.ch",
                                                      :remote_address => "75.103.6.17",
                                                      :user_agent => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6",
                                                      :http_accept_language => "en-us,en;q=0.5")
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
  context "An analytics tracking event using the adapter class" do
    setup do
      @test_ad = AnalyticsGoo::GoogleAnalyticsAdapter.new(:analytics_id => "MO-11685745-3",
                                                          :domain => "shor.tswit.ch",
                                                          :remote_address => "127.0.0.1",
                                                          :user_agent => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6",
                                                          :http_accept_language => "en-us,en;q=0.5")
      @ga4 = AnalyticsGoo::AnalyticsAdapter.new(@test_ad)
    end
    context "makes a request for an image on the google analytics server" do
      setup do
        path = "/__utm.gif?utmwv=4.4sj&utmn=1277734430&utmhn=shor.tswit.ch&utmr=-&utmp=%2Fadmin%2F1&utmac=MO-11685745-3&utmcc=__utma%3D999.999.999.999.999.1%3B&utmvid=0x5719fb3b1e05e909&utmip=127.0.0.0"
        header_hash =  {'User-Agent' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6', 'Accept-Language' => 'en-us,en;q=0.5'}
        @test_ad.expects(:utmn).returns("1277734430")
        @test_ad.expects(:utmvid).returns("0x5719fb3b1e05e909")
        # mock the underlying HTTP object
        ht = Net::HTTP.new("127.0.0.1")
        ht.expects(:request_get).with(path, header_hash)

        Net::HTTP.expects(:start).with(AnalyticsGoo::GoogleAnalyticsAdapter::GA_DOMAIN).yields(ht).returns(Net::HTTPOK.new("1.2","OK",nil))
        @resp = @ga4.track_page_view("/admin/1")
      end
      should "be a valid response" do
        assert @resp.is_a?(Net::HTTPOK)
      end
    end
  end
end
