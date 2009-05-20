# RailsAnalytics
# The following came from :
#  http://code.google.com/apis/analytics/docs/tracking/gaTrackingTroubleshooting.html

# The following parameters are currently not implemented but do not affect basic usage.
# utme  X10 Data Parameter  Value is encoded.

# utmipc
#   Product Code. This is the sku code for a given product.
#   utmipc=989898ajssi
# utmipn
#   Product Name, which is a URL-encoded string.  utmipn=tee%20shirt
# utmipr
#   Unit Price. Set at the item level. Value is set to numbers only in U.S. currency format.
#   utmipr=17100.32
# utmiqt
#   Quantity.   utmiqt=4
# utmiva
#   Variations on an item. For example: large, medium, small, pink, white, black, green. String is URL-encoded.
#   utmiva=red;
# utmt
#   A special type variable applied to events, transactions, items and user-defined variables.  utmt=Dog%20Owner
# utmtci
#   Billing City  utmtci=San%20Diego
# utmtco
#   Billing Country   utmtco=United%20Kingdom
# utmtid
#   Order ID, URL-encoded string.   utmtid=a2343898
# utmtrg
#   Billing region, URL-encoded string.   utmtrg=New%20Brunswick
# utmtsp
#   Shipping cost. Values as for unit and price.  utmtsp=23.95
# utmtst
#   Affiliation. Typically used for brick and mortar applications in ecommerce.   utmtst=google%20mtv%20store
# utmtto
#   Total. Values as for unit and price.  utmtto=334.56
# utmttx
#   Tax. Values as for unit and price.  utmttx=29.16

module RailsAnalytics
  class GoogleAnalyticsAdapter
    attr_accessor :utmcc_cookie, :utmcc_random, :utmcc_time, :utmhid, :config

    def initialize(ac)
      @utmcc_cookie = ActiveSupport::SecureRandom.random_number(89999999) + 10000000
      @utmcc_random = ActiveSupport::SecureRandom.random_number(1147483647) + 1000000000
      @utmcc_time = Time.new.to_i
      @utmhid = ActiveSupport::SecureRandom.random_number(999999999)
      # holds a hash of analytics accounts
      @config = {}
      @config[ac.name]=ac
    end

    GA_DOMAIN = "www.google-analytics.com"
    #    GA_DOMAIN = "dev.www.mobilediscovery.com"
    GA_IMAGE = "__utm.gif"

    def urchin_url(ssl = false)
      protocol = (ssl == true) ? "https":"http"
      "#{protocol}://#{GA_DOMAIN}/#{GA_IMAGE}"
    end

    # utmac   Account String. Appears on all requests.    utmac=UA-2202604-2
    def utmac(name)
      self.config[name].analytics_id
    end

    # utmhn
    #   Host Name, which is a URL-encoded string.   utmhn=x343.gmodules.com
    #  def utmhn
    #       self.domain
    #     end

    # utmfl
    #   Flash Version   utmfl=9.0%20r48&
    def utmfl
      "9.0 r124"
    end

    # utmcs
    #   Language encoding for the browser. Some browsers don't set this, in which case it is set to "-"
    #   utmcs=ISO-8859-1
    def utmcs
      "UTF-8"
    end

    # utmdt
    #   Page title, which is a URL-encoded string.  utmdt=analytics%20page%20test
    def utmdt
      "This is the page title"
    end

    # utmje
    #   Indicates if browser is Java-enabled. 1 is true.  utmje=1
    def utmje
      "1"
    end

    # utmn
    #   Unique ID generated for each GIF request to prevent caching of the GIF image.   utmn=1142651215
    def utmn
      ActiveSupport::SecureRandom.random_number(9999999999)
    end

    # utmsc
    #   Screen color depth  utmsc=24-bit
    def utmsc
      "24-bit"
    end

    # utmsr
    #   Screen resolution   utmsr=2400x1920&
    def utmsr
      "2400x1920"
    end

    # utmul
    #   Browser language.   utmul=pt-br
    def utmul
      "en-us"
    end

    # utmwv
    #   Tracking code version   utmwv=1
    def utmwv
      "4.3"
    end

    # utmp
    #   Page request of the current page.   utmp=/testDirectory/myPage.html
    #     def utmp
    #       self.path
    #     end

    # utmr
    #   Referral, complete URL.   utmr=http://www.example.com/aboutUs/index.php?var=selected
    def utmr
      "-"
    end


    # may not be needed

    # utmcn   Starts a new campaign session. Either utmcn or utmcr is present on any given request. Changes the campaign tracking data; but does not start a new session
    #   utmcn=1
    def utmcn
      "1"
    end

    # utmcr
    #   Indicates a repeat campaign visit. This is set when any subsequent clicks occur on the same link. Either utmcn or utmcr is present on any given request.
    #   utmcr=1
    def utmcr
      "1"
    end

    # utmcc
    #   Cookie values. This request parameter sends all the cookies requested from the page.
    #   utmcc=__utma%3D117243.1695285.22%3B%2B __utmz%3D117945243.1202416366.21.10. utmcsr%3Db%7C utmccn%3D(referral)%7C utmcmd%3Dreferral%7C utmcct%3D%252Fissue%3B%2B
    def utmcc
      "__utma%3D#{self.utmcc_cookie}.#{self.utmcc_random}.#{self.utmcc_time}.#{self.utmcc_time}.#{self.utmcc_time}.10%3B%2B__utmz%3D#{self.utmcc_cookie}.#{self.utmcc_time}.1.1.utmcsr%3D(direct)%7Cutmccn%3D(direct)%7Cutmcmd%3D(none)%3B"
    end

    #domain
    def domain(name)
      self.config[name].domain
    end


    # send a request to get the image from google
    def track(path, name=nil)
      res = []
      if name.nil?
        @config.each do |name,value|
          res << track_it(path, name)
        end
      else
        res << track_it(path, name)
      end
      res
    end

    protected
    def track_it(path, name)
      Net::HTTP.get_response(GA_DOMAIN,"/__utm.gif?utmwv=#{self.utmwv}&utmn=#{self.utmn}&utmhn=#{self.domain(name)}&utmcs=#{self.utmcs}&utmsr=#{self.utmsr}&utmsc=#{self.utmsc}&utmul=#{self.utmul}&utmje=#{self.utmje}&utmfl=#{URI::escape(self.utmfl)}&utmdt=#{URI::escape(self.utmdt)}&utmhid=#{self.utmhid}&utmr=#{self.utmr}&utmp=#{path}&utmac=#{self.utmac(name)}&utmcc=#{self.utmcc}")
    end
  end
end
