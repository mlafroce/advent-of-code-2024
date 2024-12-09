defmodule CeresSearch do
    def count_xmas(file_path) do
        CeresSearch.read_lines(file_path)
        |> CeresSearch.count_in_matrix()
    end

    def count_cross_mas(file_path) do
        CeresSearch.read_lines(file_path)
        |> CeresSearch.count_cross()
    end

    def read_lines(file_path) do
        case File.read(file_path) do
        {:ok, content} ->
            content
            |> String.split("\r\n", trim: true)
        {:error, reason} ->
            IO.puts("Failed to read file: #{inspect(reason)}")
        end
    end

    def count_in_matrix(rows) do
        CeresSearch.count_in_rows(rows) +
        CeresSearch.count_in_cols(rows) +
        CeresSearch.count_in_diag(rows)
    end

    def count_in_rows(rows) do
        rows
        |> Enum.reduce(0, &CeresSearch.count_in_string/2)
    end

    def count_in_cols(rows) do
        width = String.length(Enum.at(rows, 0))
        0..width - 1
        |> Enum.map(fn col ->
            rows
            |> Enum.reduce("", fn row, acc ->
               acc <> String.at(row, col)
               end)
            end)
        |> Enum.reduce(0, &CeresSearch.count_in_string/2)
    end

    def count_in_diag(rows) do
        width = String.length(Enum.at(rows, 0))
        height = length(rows)
        gen_diags_up(width, height) ++
        gen_diags_down(width, height)
        |> Enum.map(fn diag ->
            diag
            |> Enum.reduce("", fn {x, y}, acc ->
               row = Enum.at(rows, y)
               acc <> String.at(row, x)
               end)
            end)
        |> Enum.reduce(0, &CeresSearch.count_in_string/2)
    end

    def gen_diags_up(width, height) do
        0..(width+height)
        |> Enum.map(fn sum ->
           0..sum
           |> Enum.map(fn t -> {t, sum - t} end)
           |> Enum.filter(fn {x, y} -> x < width and y < height end)
           end)
    end

    def gen_diags_down(width, height) do
        -height..width
        |> Enum.map(fn x_orig ->
           0..height
           |> Enum.map(fn t -> {t + x_orig, t} end)
           |> Enum.filter(fn {x, y} -> x >= 0 and x < width and y < height end)
           end)
    end

    def count_in_string(str, acc) do
        acc + length(String.split(str, "XMAS")) +
        length(String.split(str, "SAMX")) - 2
    end

    def count_cross(rows) do
        width = String.length(Enum.at(rows, 0))
        height = length(rows)
        0 .. height - 3 |> Enum.reduce(0, fn y, acc ->
            row_count = 0 .. width - 3
            |> Enum.reduce(0, fn x, row_acc ->
                row_acc + CeresSearch.count_cell(x, y, rows)
            end)
            acc + row_count
        end)
    end

    def count_cell(x, y, rows) do
        cell_str = 0 .. 2 |> Enum.reduce("", fn i, acc ->
            acc <> String.slice(Enum.at(rows, y + i), x..x+2)
        end)
        if check_cross(cell_str), do: 1, else: 0
    end 
    #cell = 0..3 |> Enum.map(fn  Enum.at(rows, y)
    #        acc <> String.at(row, x) 
    #        end)

    def check_cross(str) do
        cross = String.at(str,0) <> String.at(str,2) <> String.at(str,4) <> String.at(str,6) <> String.at(str,8)
        cross == "MMASS" || cross == "MSAMS" || cross == "SSAMM" || cross == "SMASM"
    end
end

count = CeresSearch.count_xmas(System.argv)
IO.puts("Count #{count}")
count = CeresSearch.count_cross_mas(System.argv)
IO.puts("Count #{count}")
