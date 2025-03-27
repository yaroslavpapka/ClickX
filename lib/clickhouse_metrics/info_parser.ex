defmodule ClickhouseMetrics.UserAgentParser do
  def parse(ua_string) do
    parsed = UAParser.parse(ua_string)

    %{
      browser: format_version(parsed.family, parsed.version),
      os: format_version(parsed.os.family, parsed.os.version),
    }
  end

  defp format_version(family, nil), do: family || "Unknown"
  defp format_version(family, %UAParser.Version{major: nil, minor: nil}), do: family || "Unknown"
  defp format_version(family, %UAParser.Version{major: major, minor: nil}), do: "#{family} #{major}"
  defp format_version(family, %UAParser.Version{major: major, minor: minor}), do: "#{family} #{major}.#{minor}"

end
