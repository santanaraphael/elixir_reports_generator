defmodule GenReport do
  alias GenReport.Constants
  alias GenReport.Parser

  def build(filenames) when is_list(filenames) do
    filenames
    |> Task.async_stream(&build/1)
    |> Enum.reduce(report_acc(), fn {:ok, new_report}, old_report ->
      merge_reports(new_report, old_report)
    end)
  end

  def build(filename) do
    Parser.parse_file(filename)
    |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
  end

  def build() do
    {:error, "Insira o nome de um arquivo"}
  end

  def report_acc do
    all_hours = Enum.into(Constants.freelancers(), %{}, &{&1, 0})

    hours_per_month =
      Constants.month_names()
      |> Enum.into(%{}, &{&1, 0})
      |> then(fn months_enum -> Enum.into(Constants.freelancers(), %{}, &{&1, months_enum}) end)

    hours_per_year =
      Constants.years()
      |> Enum.into(%{}, &{&1, 0})
      |> then(fn years_enum -> Enum.into(Constants.freelancers(), %{}, &{&1, years_enum}) end)

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  defp sum_values([name, hours, _day, month, year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    %{
      "all_hours" => sum_all_hours(all_hours, name, hours),
      "hours_per_month" => sum_hours_per_month(hours_per_month, name, month, hours),
      "hours_per_year" => sum_hours_per_year(hours_per_year, name, year, hours)
    }
  end

  defp sum_all_hours(all_hours, name, hours) do
    Map.put(all_hours, name, all_hours[name] + hours)
  end

  defp sum_hours_per_month(hours_per_month, name, month, hours) do
    Map.put(hours_per_month[name], month, hours_per_month[name][month] + hours)
    |> then(fn updated_map ->
      Map.put(
        hours_per_month,
        name,
        updated_map
      )
    end)
  end

  defp sum_hours_per_year(hours_per_year, name, year, hours) do
    Map.put(hours_per_year[name], year, hours_per_year[name][year] + hours)
    |> then(fn updated_map ->
      Map.put(
        hours_per_year,
        name,
        updated_map
      )
    end)
  end

  defp merge_reports(
         %{
           "all_hours" => new_all_hours,
           "hours_per_month" => new_hours_per_month,
           "hours_per_year" => new_hours_per_year
         },
         %{
           "all_hours" => old_all_hours,
           "hours_per_month" => old_hours_per_month,
           "hours_per_year" => old_hours_per_year
         }
       ) do
    %{
      "all_hours" => merge_maps(new_all_hours, old_all_hours),
      "hours_per_month" => merge_maps(new_hours_per_month, old_hours_per_month),
      "hours_per_year" => merge_maps(new_hours_per_year, old_hours_per_year)
    }
  end

  # Got this solution on:
  # https://stackoverflow.com/questions/38864001/elixir-how-to-deep-merge-maps

  defp merge_maps(left, right) do
    Map.merge(left, right, &deep_resolve/3)
  end

  # Key exists in both maps, and both values are maps as well.
  # These can be merged recursively.
  defp deep_resolve(_key, %{} = left, %{} = right) do
    merge_maps(left, right)
  end

  # Key exists in both maps, but at least one of the values is
  # NOT a map. We fall back to standard merge behavior, preferring
  # the value on the right.
  defp deep_resolve(_key, left, right) do
    left + right
  end
end
