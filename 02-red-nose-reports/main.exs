defmodule ReportChecker do
    def count_safe_reports(file_path) do
        ReportChecker.read_stages(file_path)
        |> Enum.count(&ReportChecker.is_stage_safe/1)
    end

    def count_safe_reports_with_damper(file_path) do
        ReportChecker.read_stages(file_path)
        |> Enum.count(&ReportChecker.is_stage_safe_with_damper/1)
    end

    def read_stages(file_path) do
        case File.read(file_path) do
        {:ok, content} ->
            content
            |> String.split("\n", trim: true)
            |> Enum.map(&ReportChecker.split_to_integers/1)
        {:error, reason} ->
            IO.puts("Failed to read file: #{inspect(reason)}")
        end
    end

    def is_stage_safe(stage) when is_list(stage) do
        case stage do
        [] -> true
        [_] -> true
        _ -> 
            Enum.chunk_every(stage, 2, 1, :discard) # sliding window
            |> Enum.map(fn
              [l, r] when l < r and (r - l) < 4 -> :ascending
              [l, r] when l > r and (l - r) < 4 -> :descending
              _ -> :fail
            end)
            |> Enum.chunk_every(2, 1, :discard)
            |> Enum.any?(fn [l, r] -> l == :fail or l != r end)
            |> Kernel.not
        end
    end

    def is_stage_safe_with_damper(stage) when is_list(stage) do
        error = ReportChecker.find_error(stage)
        if error == nil do
            true
        else
            # This is sooo bad...
            #
            stage |> List.delete_at(error)
            |> ReportChecker.is_stage_safe
            ||
            stage |> List.delete_at(error + 1)
            |> ReportChecker.is_stage_safe
            ||
            stage |> List.delete_at(error + 2)
            |> ReportChecker.is_stage_safe
        end
    end

    def find_error(stage) when is_list(stage) do
        case stage do
        [] -> true
        [_] -> true
        _ -> 
            Enum.chunk_every(stage, 2, 1, :discard) # sliding window
            |> Enum.map(fn
              [l, r] when l < r and (r - l) < 4 -> :ascending
              [l, r] when l > r and (l - r) < 4 -> :descending
              _ -> :fail
            end)
            |> Enum.chunk_every(2, 1, :discard)
            |> Enum.find_index(fn [l, r] -> l == :fail or l != r end)
        end
    end

    def split_to_integers(input) do
      input
      |> String.trim()                      # Remove any leading/trailing whitespace
      |> String.split(~r/\s+/, trim: true)  # Split on whitespace
      |> Enum.map(&String.to_integer/1)     # Convert each part to an integer
    end
end

safe_reports = ReportChecker.count_safe_reports(System.argv)
IO.puts("Safe #{safe_reports}")

safe_reports = ReportChecker.count_safe_reports_with_damper(System.argv)
IO.puts("Safe with damper #{safe_reports}")