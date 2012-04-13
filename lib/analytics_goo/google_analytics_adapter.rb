
# AnalyticsGoo
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

module AnalyticsGoo
  class GoogleAnalyticsAdapter
    attr_accessor :domain, :analytics_id, :env, :noop, :page_title, :remote_address,
                  :referrer, :user_agent, :http_accept_language, :campaign, :source,
                  :medium, :term, :content


    def initialize(ac)
      # sets the environment that this should be run in
      @analytics_id = ac[:analytics_id]
      @domain = ac[:domain]
      @env = ac[:environment]
      @noop = ac[:noop] || false
      @page_title  = ac[:page_title] || ""
      @referrer = ac[:referrer] || "-"
      @remote_address = ac[:remote_address]
      @user_agent = ac[:user_agent] || ""
      @http_accept_language = ac[:http_accept_language] || ""
      @campaign =  ac[:campaign] || ""
      @source = ac[:source] || ""
      @medium = ac[:medium] || ""
      @term = ac[:term] || ""
      @content = ac[:content] || ""
    end

    GA_DOMAIN = "www.google-analytics.com"
    GA_IMAGE = "__utm.gif"

    def urchin_url(ssl = false)
      protocol = (ssl == true) ? "https":"http"
      "#{protocol}://#{GA_DOMAIN}/#{GA_IMAGE}"
    end

    # utmac   Account String. Appears on all requests.    utmac=UA-2202604-2
    def utmac
      self.analytics_id
    end

    # utmhn
    #   Host Name, which is a URL-encoded string.   utmhn=x343.gmodules.com
    def utmhn
      self.domain
    end

    # utmcs
    #   Language encoding for the browser. Some browsers don't set this, in which case it is set to "-"
    #   utmcs=ISO-8859-1
    def utmcs
      "UTF-8"
    end

    # utmje
    #   Indicates if browser is Java-enabled. 1 is true.  utmje=1
    def utmje
      "1"
    end

    # utmn
    #   Unique ID generated for each GIF request to prevent caching of the GIF image.   utmn=1142651215
    def utmn
      ActiveSupport::SecureRandom.random_number(9999999999).to_s
    end

    # utmsc
    #   Screen color depth  utmsc=24-bit
    def utmsc
      "0-bit"
    end

    # utmsr
    #   Screen resolution   utmsr=2400x1920&
    def utmsr
      "0x0"
    end

    # utmul
    #   Browser language.   utmul=pt-br
    def utmul
      "en-us"
    end

    # utmwv
    #   Tracking code version   utmwv=1
    def utmwv
      "4.4sj"
    end

    # utmp
    #   Page request of the current page.   utmp=/testDirectory/myPage.html
    #     def utmp
    #       self.path
    #     end

    # utmr
    #   Referral, complete URL.   utmr=http://www.example.com/aboutUs/index.php?var=selected
    def utmr
      self.referrer
    end

    # utmip
    # Remote IP address
    def utmip
      return '' if self.remote_address.blank?
      # Capture the first three octects of the IP address and replace the forth
      # with 0, e.g. 124.455.3.123 becomes 124.455.3.0
      ip = self.remote_address.to_s.gsub!(/([^.]+\.[^.]+\.[^.]+\.)[^.]+/,"\\1") + "0"
      ip
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
      "__utma%3D999.999.999.999.999.1%3B"
    end

    def utmdt
      self.page_title
    end

    def utm_campaign
      self.campaign
    end

    def utm_source
      self.source
    end


    def utm_medium
      self.medium
    end

    def utm_term
      self.term
    end

    def utm_content
      self.content
    end

    # send a request to get the image from google
    def track_page_view(path)
      res = ""
      unless @noop == true
        res = track_it(path)
      end
      res
    end

    protected
    def track_it(path)
      #TODO - cleanup
      utm_uri = "/__utm.gif?" +
                "utmwv="  + self.utmwv +
                "&utmn="  + self.utmn +
                "&utmhn=" + CGI.escape(self.utmhn) +
                "&utmr="  + CGI.escape(self.utmr) +
                "&utmp="  + CGI.escape(path) +
                "&utmac=" + self.utmac +
                "&utmcc=" + self.utmcc +
                "&utmvid="+ self.utmvid +
                "&utmip=" + self.utmip
      utm_uri << "&utmdt=#{CGI.escape(self.utmdt)}"               unless self.utmdt.blank?
      utm_uri << "&utm_campaign=#{CGI.escape(self.utm_campaign)}" unless self.utm_campaign.blank?
      utm_uri << "&utm_source=#{CGI.escape(self.utm_source)}"     unless self.utm_source.blank?
      utm_uri << "&utm_medium=#{CGI.escape(self.utm_medium)}"     unless self.utm_medium.blank?
      utm_uri << "&utm_term=#{CGI.escape(self.utm_term)}"         unless self.utm_term.blank?
      Net::HTTP.start(GA_DOMAIN) {|http|
        http.request_get(utm_uri, {"User-Agent" => self.user_agent, "Accept-Language" => self.http_accept_language})
      }
    end

    def utmcc_cookie
      ActiveSupport::SecureRandom.random_number(89999999) + 10000000
    end

    def utmcc_random
      ActiveSupport::SecureRandom.random_number(1147483647) + 1000000000
    end

    def utmcc_time
      Time.new.to_i
    end

    def utmvid
      "0x" + ActiveSupport::SecureRandom.hex[0,16]
    end
  end
end
