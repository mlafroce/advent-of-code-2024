defmodule HistorianList do
    def get_sorted_lists(file_path) do
        {left_list, right_list} = HistorianList.read_lists(file_path)
        left_list = Enum.sort(left_list)
        right_list = Enum.sort(right_list)
        {left_list, right_list}
    end

    def read_lists(file_path) do
        case File.read(file_path) do
        {:ok, content} ->
            content
            |> String.split("\n", trim: true)
            |> Enum.map(&HistorianList.split_to_integers/1)
            |> Enum.reduce({[], []}, fn
                {:ok, left, right}, {acc_l, acc_r} -> {[left | acc_l], [right | acc_r]}
                {:error, _}, {acc_l, acc_r} -> {acc_l, acc_r}           # Skip invalid inputs
              end)

        {:error, reason} ->
            IO.puts("Failed to read file: #{inspect(reason)}")
      end
  end

  def sum_distances(sorted_left, sorted_right) do
    Enum.zip([sorted_left, sorted_right])
    |> Enum.reduce(0, fn {l, r}, acc ->
        acc + abs(l - r)
      end)
  end

  def weighted_sum(left, right) do
    occurrences = Enum.reduce(right, %{}, fn key, acc ->
      Map.update(acc, key, 1, fn old_value -> old_value + 1 end)
    end)
    Enum.reduce(left, 0, fn l_value, acc ->
      acc + Map.get(occurrences, l_value, 0) * l_value
    end)
  end

  def split_to_integers(input) do
    input
      |> String.trim()                      # Remove any leading/trailing whitespace
      |> String.split(~r/\s+/, trim: true)  # Split on whitespace
      |> Enum.map(&String.to_integer/1)     # Convert each part to an integer
      |> case do
        [left, right] -> {:ok, left, right}
        _ -> {:error, "Invalid format"}
      end
    end
end

{sorted_left, sorted_right} = HistorianList.get_sorted_lists("input-01.txt")

distance = HistorianList.sum_distances(sorted_left, sorted_right)

IO.puts("Distance: #{distance}")

weighted_sum = HistorianList.weighted_sum(sorted_left, sorted_right)
IO.puts("Weighted sum: #{weighted_sum}")
