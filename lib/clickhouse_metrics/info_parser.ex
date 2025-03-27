defmodule ClickhouseMetrics.UserAgentParser do
  def parse(ua_string) do
    parsed = UAParser.parse(ua_string)

    %{
      browser: format_version(parsed.family, parsed.version),
      os: format_version(parsed.os.family, parsed.os.version),
    }
  end

  defp format_version(family, %UAParser.Version{major: major, minor: minor}) do
    case {major, minor} do
      {nil, _} -> family
      {_, nil} -> "#{family} #{major}"
      _ -> "#{family} #{major}.#{minor}"
    end
  end


end
