require File.expand_path('../helper', __FILE__)

module AppOptics::Services
  class OpsGenieTest < AppOptics::Services::TestCase
    def setup
      @settings = { :customer_key => "my api key" }
      @stub_url = URI.parse("https://api.opsgenie.com/v1/json/appoptics").request_uri
      @stubs = Faraday::Adapter::Test::Stubs.new
    end

    def test_v2_alert
      payload = new_alert_payload.dup
      svc = service(:alert, @settings, payload)
      @stubs.post @stub_url do |env|
        [200, {}, '']
      end
      svc.receive_alert
    end

    def test_add_triggered_by_test_tag
      payload = new_alert_payload.dup
      payload[:triggered_by_user_test] = true
      svc = service(:alert, @settings, payload)
      @stubs.post @stub_url do |env|
        assert_equal("triggered_by_user_test",env[:body][:tags])
        [200, {}, '']
      end
      svc.receive_alert
    end

    def test_append_test_tag_to_already_existing
      payload = new_alert_payload.dup
      payload[:triggered_by_user_test] = true
      local_settings = @settings.dup
      local_settings[:tags] = 'test_tag'
      svc = service(:alert, local_settings, payload)
      @stubs.post @stub_url do |env|
        assert_equal("test_tag,triggered_by_user_test",env[:body][:tags])
        [200, {}, '']
      end
      svc.receive_alert
    end

    def service(*args)
      super AppOptics::Services::Service::OpsGenie, *args
    end
  end
end
