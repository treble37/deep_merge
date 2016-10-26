defmodule DeepMergeTest do
  use ExUnit.Case
  doctest DeepMerge
  import DeepMerge

  test "deep_merge/2 with different keyword list & list combinations" do
    assert deep_merge([a: [b: []], f: 5], [a: [b: [c: 2]]]) ==
           [f: 5, a: [b: [c: 2]]]
    assert deep_merge([a: [b: [c: 2]], f: 5], [a: [b: []]]) ==
           [f: 5, a: [b: [c: 2]]]
    assert deep_merge([a: [b: [c: 2]], f: 5], [a: [b: [1, 2, 3]]]) ==
           [f: 5, a: [b: [1, 2, 3]]]
    assert deep_merge([a: [b: [1, 2, 3]], f: 5], [a: [b: [c: 2]]]) ==
           [f: 5, a: [b: [c: 2]]]
    assert deep_merge([a: [b: []], f: 5], [a: [b: []]]) ==
           [f: 5, a: [b: []]]
  end

  defmodule User do
    defstruct [:attrs]
  end

  test "deep_merge/2 doesn't attempt to merge structs" do
    original = %{a: %User{attrs: %{b: 1}}}
    override = %{a: %User{attrs: %{c: 2}}}
    assert deep_merge(original, override) == override
  end

  test "deep_merge/2 merges Structs with the Resolver protocol implemented" do
    original = %{a: %MyStruct{attrs: %{b: 1}}}
    override = %{a: %MyStruct{attrs: %{c: 2}}}
    assert deep_merge(original, override) ==
      %{a: %MyStruct{attrs: %{b: 1, c: 2}}}
  end

  test "deep_merge/2 merges Structs with protocol implemented top level" do
    original = %MyStruct{attrs: %{b: 1, c: 0}}
    override = %MyStruct{attrs: %{c: 2, e: 4}}
    assert deep_merge(original, override) ==
      %MyStruct{attrs: %{b: 1, c: 2, e: 4}}
  end

  test "deep_merge/2 doesn't merge structs without the protocol implemented" do
    original = %{a: %MyStruct{attrs: %{b: 1}}}
    override = %{a: %User{attrs: %{c: 2}}}
    assert deep_merge(original, override) == override
  end

  test "deep_merge/2 doesn't attempt to merge maps and structs" do
    with_map    = %{a: %{attrs: %{b: 1}}}
    with_struct = %{a: %User{attrs: %{c: 2}}}

    assert deep_merge(with_map, with_struct) == with_struct
    assert deep_merge(with_struct, with_map) == with_map
  end
end
