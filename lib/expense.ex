defmodule BudgetTracker.Expense do
  @moduledoc """
  Documentation for `Expense`.
  """
  alias BudgetTracker.Expense
  defstruct(
    ammount: 0,
    title: "",
    date: Date.utc_today(),
    description: ""
  )

  def storagefile, do: "database.csv"

  @type t :: %Expense{
    ammount: float(),
    date: Date.t() | nil,
    title: String.t(),
    description: String.t()
  }

  @spec exit(String) :: {{any()}}
  def exit(message) do
    IO.puts(message)
  end
  
  @spec fetchData() :: {list()}
  def fetchData do
    if File.exists?(BudgetTracker.Expense.storagefile) do
      {:ok, file} = File.read(BudgetTracker.Expense.storagefile)
      if file == "" do []
      else
        [_ | body] = file |> String.trim |> String.split("\n")
        if is_bitstring(body) == true do
          result = body |> String.split(",")
          result = %Expense{
            ammount: String.to_float(result |> Enum.at(0)), 
            date: Date.from_iso8601(result |> Enum.at(1)) |> elem(1),
            title: result |> Enum.at(2), description: result |> Enum.at(3)
          }
          result
        else
          result = body |> Enum.map(fn row ->
            values = row |> String.split(",")
            %Expense{
              ammount: String.to_float(values |> Enum.at(0)), 
              date: Date.from_iso8601(values |> Enum.at(1)) |> elem(1),
              title: values |> Enum.at(2), description: values |> Enum.at(3)
            }
          end)
          result 
        end
      end
    else []
    end
  end
  
  @spec showExpenses() :: {{any()}}
  def showExpenses do
    result = BudgetTracker.Expense.fetchData
    IO.inspect(result)
    BudgetTracker.Expense.application
  end

  @spec calculateExpenses(list()) :: {{any()}}
  def calculateExpenses(commandlist) do
    if length(commandlist) == 1 do
      CommandDocs.expense    
    else
      data = BudgetTracker.Expense.fetchData
      if length(commandlist) == 2 do
        if Regex.match?(~r/--month=\d+$/, Enum.at(commandlist, 1)) == true do
          value = Regex.split(~r/=/, Enum.at(commandlist, 1), trim: true) |> Enum.at(1)
          if Regex.match?(~r/\d+$/, value) == true do
            total = data 
              |> Enum.filter(fn x -> x.date.month == String.to_integer(value) end)
              |> Enum.reduce(0, fn x, y -> 
                if y == 0 do x.ammount else x.ammount + y.ammount end
              end)
            IO.puts("#{IO.ANSI.yellow()}Total since last #{value} months: #{IO.ANSI.light_cyan}#{total}#{IO.ANSI.white}")
          else
            IO.puts("#{IO.ANSI.red()}ERROR:#{IO.ANSI.white()} The Month must be a number")
          end
        else
          if Regex.match?(~r/--days=\d+$/, Enum.at(commandlist, 1)) == true do
            value = Regex.split(~r/=/, Enum.at(commandlist, 1), trim: true) |> Enum.at(1)
            if Regex.match?(~r/\d+$/, value) == true do
              total = data 
                |> Enum.filter(fn x -> Date.diff(Date.utc_today, x.date) >= String.to_integer(value) end)
                |> Enum.reduce(0, fn x, y -> 
                if y == 0 do x.ammount else x.ammount + y.ammount end 
              end)
              IO.puts("#{IO.ANSI.yellow} Total since last #{value} days: #{IO.ANSI.light_cyan}#{total}#{IO.ANSI.white}")
            end
          end
        end
      end
    end
    BudgetTracker.Expense.application
  end

  @spec saveData() :: {{any()}}
  def saveData do
    get_date_input = fn _ ->
      date_inp = Date.from_iso8601(IO.gets("#{IO.ANSI.magenta}Enter date: #{IO.ANSI.white}") |> String.trim) |> elem(1)
      if date_inp == :invalid_format do Date.utc_today()
      else date_inp end
    end
    expense = %Expense{
      ammount: Float.parse(IO.gets("#{IO.ANSI.magenta}Enter ammount: #{IO.ANSI.white}") |> String.trim) |> elem(0),
      date: get_date_input.(nil),
      title: String.trim(IO.gets("#{IO.ANSI.magenta}Enter title: #{IO.ANSI.white}")),
      description:  String.trim(IO.gets("#{IO.ANSI.magenta}Enter description: #{IO.ANSI.white}"))
    }
    [_ | values] = Map.values(expense)
    if (File.exists?(BudgetTracker.Expense.storagefile) == false) do
      {:ok, file} = File.open(BudgetTracker.Expense.storagefile, [:write])
      csv_header = "ammount,date,title,description"
      IO.binwrite(file, csv_header <> "\n" <> Enum.reduce(values, "", fn x, y -> 
        if y == "" do x
        else "#{y},#{x}" end
      end) <> "\n")
      File.close(file)
    else
      {:ok, content} = File.read(BudgetTracker.Expense.storagefile)
      if content == "" do
        {:ok, file} = File.open(BudgetTracker.Expense.storagefile, [:write])
        csv_header = "ammount,date,title,description"
        IO.binwrite(file, csv_header <> "\n" <> Enum.reduce(values, "", fn x, y ->
          if y == "" do x
          else "#{y},#{x}" end
        end) <> "\n")
        File.close(file)
      else
        {:ok, file} = File.open(BudgetTracker.Expense.storagefile, [:write])
        IO.binwrite(file, content <> Enum.reduce(values, "", fn x, y -> 
          if y == "" do x
          else "#{y},#{x}" end
        end) <> "\n")
      end
    end
    IO.puts("#{IO.ANSI.green()}Data saved succesfully!#{IO.ANSI.white()}")
    BudgetTracker.Expense.application
  end

  @spec parse_command(String.t()) :: {{any()}}
  def parse_command(command) do
    tokenized = Regex.split(~r/ /,command, trim: true)
    case tokenized |> Enum.at(0) do
      "expense" -> BudgetTracker.Expense.calculateExpenses(tokenized)
      _ -> IO.puts("#{IO.ANSI.red}ERROR:#{IO.ANSI.white} invalid command #{tokenized |> Enum.at(0)}")
    end
    BudgetTracker.Expense.application
  end

  @spec application(String.t()) :: {{any()}}
  def application(command \\ IO.gets("#{IO.ANSI.magenta}>>>#{IO.ANSI.white} ")) do
    case String.trim(command) do
      "exit" -> BudgetTracker.Expense.exit("Closing application Good bye!!")
      "help" ->  CommandDocs.help
      "add-new" -> BudgetTracker.Expense.saveData
      "list-expenses" -> BudgetTracker.Expense.showExpenses
      _ -> BudgetTracker.Expense.parse_command(String.trim(command))
        # application runner (end)
    end
  end
end


defmodule Main do
  def start do
    BudgetTracker.Expense.application()
  end
end

