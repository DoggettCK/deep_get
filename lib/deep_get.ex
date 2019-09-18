defmodule DeepGet do
  @moduledoc """
  `DeepGet` allows you to take an object (map/struct/keyword list/list) or list
  of them, nested to an arbitrary level, and extract the values corresponding
  to a list of keys.
  """

  @doc """
  Fetches a list of all objects under a struct/map/keyword list/list matching
  the list of keys provided.

  If `object` is a list, it will retain the key at the level it is currently
  working on, and check all map-like/keyable objects in the list for the next
  key.

  The end result is a flattened list of values for every item in the
  deeply-nested structure that matched the full key path.

  ## Examples
      iex> %{ids: [%{id: 1}, %{id: 2}]} |> DeepGet.deep_get([:ids, :id])
      [1, 2]

      iex> [%{name: %{first: "Alice"}}, %{name: %{first: "Bob"}}] |> DeepGet.deep_get([:name, :first])
      ["Alice", "Bob"]
  """
  def deep_get(nil, _path), do: []
  def deep_get(_object, []), do: []

  def deep_get(object, path) when is_list(path) do
    object
    |> do_deep_get(path, [])
    |> List.flatten()
    |> Enum.reverse()
  end

  def deep_get(object, path) do
    # Wrap a single key in a list and call the public function
    deep_get(object, [path])
  end

  defp do_deep_get([], _path, results) do
    # No need to add an empty list to a list that's going to get flattened
    results
  end

  defp do_deep_get(object, [], results) do
    # Reached the end of the path, so add whatever object we're in to the list
    [object | results]
  end

  defp do_deep_get(%{} = map, path, results) do
    [current | remaining_path] = path

    if Map.has_key?(map, current) do
      nested_results =
        map
        |> Map.get(current)
        |> do_deep_get(remaining_path, [])

      [nested_results | results]
    else
      # If the map/struct doesn't have the key, it can't have any of the
      # sub-keys, so just pop back up the stack
      results
    end
  end

  defp do_deep_get(list, path, results) when is_list(list) do
    if Keyword.keyword?(list) do
      [current | remaining_path] = path

      if Keyword.has_key?(list, current) do
        nested_results =
          list
          |> Keyword.get(current)
          |> do_deep_get(remaining_path, [])

        [nested_results | results]
      else
        results
      end
    else
      nested_results =
        list
        |> Enum.map(&do_deep_get(&1, path, []))
        |> Enum.reverse()

      [nested_results | results]
    end
  end

  defp do_deep_get(_non_map_or_list, _path, results) do
    # Still have path remaining, but nothing that can accept a key
    results
  end
end
