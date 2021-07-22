defmodule GenReport.Constants do
  @freelancers [
    "cleiton",
    "daniele",
    "danilo",
    "diego",
    "giuliano",
    "jakeliny",
    "joseph",
    "mayk",
    "rafael",
    "vinicius"
  ]

  @month_names_map %{
    "1" => "janeiro",
    "2" => "fevereiro",
    "3" => "março",
    "4" => "abril",
    "5" => "maio",
    "6" => "junho",
    "7" => "julho",
    "8" => "agosto",
    "9" => "setembro",
    "10" => "outubro",
    "11" => "novembro",
    "12" => "dezembro"
  }

  @years [
    2016,
    2017,
    2018,
    2019,
    2020
  ]

  def freelancers do
    @freelancers
  end

  def month_names do
    Map.values(@month_names_map)
  end

  def months_name_by_key(key) do
    @month_names_map[key]
  end

  def years do
    @years
  end
end
