defmodule GenReport do
  alias GenReport.Constants
  alias GenReport.Parser

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
end
