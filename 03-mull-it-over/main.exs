defmodule Mull do
    def sum_mul(file_path) do
        Mull.read_tokens(file_path)
        |> Enum.reduce(0, fn
            {x, y}, acc -> acc + x * y
            :do, acc -> acc
            :dont, acc -> acc
        end)
    end

    def sum_mul_filtered(file_path) do
        Mull.read_tokens(file_path)
        |> Enum.reduce({0, true}, fn
            {x, y}, {acc, true} -> {acc + x * y, true}
            {_, _}, {acc, false} -> {acc, false}
            :do, {acc, _} -> {acc, true}
            :dont, {acc, _} -> {acc, false}
        end)
    end

    def read_tokens(file_path) do
        case File.read(file_path) do
        {:ok, content} ->
            Regex.scan(~r/do\(\)|don't\(\)|mul\((\d+),(\d+)\)/, content)
            |> Enum.map(fn 
                [_, x, y] -> {String.to_integer(x), String.to_integer(y)}
                ["do()"] -> :do
                ["don't()"] -> :dont
            end)
        {:error, reason} ->
            IO.puts("Failed to read file: #{inspect(reason)}")
        end
    end
end

sum = Mull.sum_mul(System.argv)
{sum_filtered, _} = Mull.sum_mul_filtered(System.argv)
IO.puts("Mul sum: #{sum}")
IO.puts("Filtered mul sum: #{sum_filtered}")