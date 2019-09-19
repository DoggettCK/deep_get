defmodule DeepGetTest do
  use ExUnit.Case
  doctest DeepGet

  describe "deep_get/2" do
    test "nil object returns an empty list" do
      assert DeepGet.deep_get(nil, [:some, :path]) == []
    end

    test "object with nil path returns an empty list" do
      assert DeepGet.deep_get(%{some: [%{path: 1}, %{path: 2}]}, nil) == []
    end

    test "object with empty path returns an empty list" do
      assert DeepGet.deep_get(%{some: [%{path: 1}, %{path: 2}]}, []) == []
    end

    test "ignores values that don't contain the next part of the path" do
      assert DeepGet.deep_get(%{some: %{path: "value"}}, [:a]) == []
    end

    test "gets values from a map given a single key" do
      assert DeepGet.deep_get(%{some: %{path: "value"}}, :some) == [%{path: "value"}]
    end

    test "gets values from a map given a string key" do
      assert DeepGet.deep_get(%{"some" => %{"path" => "value"}}, "some") == [%{"path" => "value"}]
    end

    test "gets values from a map given a list of keys" do
      assert DeepGet.deep_get(%{some: %{path: "value"}}, [:some]) == [%{path: "value"}]
    end

    test "does not get values from a map given a key that starts nested deeper" do
      assert DeepGet.deep_get(%{some: %{path: "value"}}, :path) == []
    end

    test "maps a list instead of consuming the next key" do
      assert DeepGet.deep_get([%{id: 1}, %{id: 2}], :id) == [1, 2]
    end

    test "gets values from keyword lists if the key exists" do
      assert DeepGet.deep_get([a: 1, b: 2], :b) == [2]
    end

    test "does not get values from keyword lists if the key is missing" do
      assert DeepGet.deep_get([a: 1, b: 2], :c) == []
    end

    test "handles a very deeply-nested list" do
      list = [
        [[[[%{id: 1}]]]],
        [[%{id: 2}]],
        [%{id: 3}]
      ]

      assert DeepGet.deep_get(list, [:id]) == [1, 2, 3]
    end

    test "handles lists of maps of lists of maps of keyword lists" do
      # And any other arbitrary structure that can be keyed into
      list = [
        %{some: [%{path: [id: 1]}, %{path: [id: 2]}]},
        %{some: [%{path: [id: 3]}]}
      ]

      assert DeepGet.deep_get(list, [:some, :path, :id]) == [1, 2, 3]
    end

    test "handles a super complex structure" do
      list = [
        # List with multiple nested maps, maps without starting key, strings, etc...
        %{
          a: %{
            # List with multiple nested maps
            b: [
              %{c: "value 1"},
              %{c: "value 2"}
            ]
          }
        },
        "string value",
        123.45,
        %{missing: :key},
        %{
          a: %{
            b: %{
              # Different structure (b is not a list), doesn't ignore nil leaf values
              c: nil
            }
          }
        },
        %{
          a: [
            %{
              b: nil
            },
            %{
              b: [
                # List with nested map
                %{c: "value 3"}
              ]
            },
            %{
              # Keyword list
              b: [c: "value 4"]
            }
          ]
        },
        [
          # Nested keyword lists nested in the outer list
          [a: [b: [c: "value 5"]]],
          # Duplicate key in keyword list behaves according to normal rules
          [a: [b: [c: "value 6", c: "value 7"]]],
          # Level of duplicate key in keyword list doesn't matter
          [a: [b: [c: "value 7"], b: [c: "value 8"]]]
        ]
      ]

      assert DeepGet.deep_get(list, [:a, :b, :c]) ==
               ["value 1", "value 2", nil, "value 3", "value 4", "value 5", "value 6", "value 7"]
    end
  end
end
