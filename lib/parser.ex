defmodule GenReport.Parser do
  alias GenReport.Constants

  def parse_file(filename) do
    File.stream!(filename)
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> List.update_at(0, &String.downcase/1)
    |> List.update_at(1, &String.to_integer/1)
    |> List.update_at(2, &String.to_integer/1)
    |> List.update_at(3, &Constants.months_name_by_key/1)
    |> List.update_at(4, &String.to_integer/1)
  end
end
