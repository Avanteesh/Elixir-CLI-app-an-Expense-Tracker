defmodule CommandDocs do
  @doc """
    utilities for help
  """

  def help do
    IO.puts("#{IO.ANSI.yellow()}Welcome to Expense Tracker app!\n#{IO.ANSI.white()}")
    IO.puts("Here are the commands for you!")
    IO.puts("#{IO.ANSI.light_cyan} add-new (adds new expenses ) #{IO.ANSI.white()}")
    IO.puts("#{IO.ANSI.light_cyan} list-expenses (show all the expenses) #{IO.ANSI.white}")
    IO.puts("#{IO.ANSI.light_cyan} expense (calculate total expense!) #{IO.ANSI.white}")
    # next recursive call for further inputs!
    BudgetTracker.Expense.application
  end

  def expense do
    IO.puts("Use 'expense' command")
    IO.puts("utils: ")
    IO.puts("\t --month='enter a month'  - #{IO.ANSI.yellow}fetches total expenses of the month of current year!#{IO.ANSI.white()}")
    IO.puts("\t --day='enter a month'   - #{IO.ANSI.yellow}fetches total expenses of the month of specified year #{IO.ANSI.white()}")
  end
end

