defmodule ClickhouseMetrics.UserAgentParserTest do
  use ExUnit.Case

  alias ClickhouseMetrics.UserAgentParser

  test "parse/1 correctly parses user agent string with full version info" do
    ua_string = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
    parsed = UserAgentParser.parse(ua_string)

    assert parsed.browser == "Chrome 114.0"
    assert parsed.os == "Windows 10"
  end

  test "parse/1 correctly handles user agent string with only major version" do
    ua_string = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Safari/537.36"
    parsed = UserAgentParser.parse(ua_string)

    assert parsed.browser == "Safari"
    assert parsed.os == "Mac OS X 10.15"
  end

  test "parse/1 correctly handles user agent string with no version info" do
    ua_string = "UnknownBrowser/Unknown"
    parsed = UserAgentParser.parse(ua_string)

    assert parsed.browser == "Unknown"
    assert parsed.os == "Unknown"
  end

  test "parse/1 handles nil user agent string gracefully" do
    parsed = UserAgentParser.parse("")

    assert parsed.browser == "Unknown"
    assert parsed.os == "Unknown"
  end
end
