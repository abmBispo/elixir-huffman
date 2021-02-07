defmodule ElixirHuffman do
  alias ElixirHuffman.{
    Node,
    Leaf
  }

  def encode(text \\ "cheesecake") do
    graphemes = String.graphemes(text)

    frequencies =
      graphemes
      |> Enum.reduce(%{}, fn char, map ->
        Map.update(map, char, 1, fn val -> val + 1 end)
      end)

    queue =
      frequencies
      |> Enum.sort_by(fn {_char, frequency} ->
        frequency
      end)
      |> Enum.map(fn {value, frequency} ->
        {
          %Leaf{value: value},
          frequency
        }
      end)

    huffman_tree = build_tree(queue)

    dictionary = huffman_dictionary(huffman_tree)

    convert(graphemes, dictionary)
  end

  defp build_tree([{root, _freq}]), do: root

  defp build_tree(queue) do
    [{node_a, freq_a} | queue] = queue
    [{node_b, freq_b} | queue] = queue

    new_node = %Node{
      left: node_a,
      right: node_b
    }

    total = freq_a + freq_b
    queue = [{new_node, total}] ++ queue

    queue
    |> Enum.sort_by(fn {_node, frequency} -> frequency end)
    |> build_tree()
  end

  defp huffman_dictionary(huffman_tree = %Node{}) do
    huffman_dictionary(huffman_tree, %{}, "")
  end

  defp huffman_dictionary(huffman_tree = %Node{}, encoded_graphemes, encoded_string) do
    left_branch = huffman_dictionary(huffman_tree.left, encoded_graphemes, encoded_string <> "0")
    right_branch = huffman_dictionary(huffman_tree.right, encoded_graphemes, encoded_string <> "1")
    Map.merge(left_branch, right_branch)
  end

  defp huffman_dictionary(%Leaf{value: grapheme}, encoded_grapheme, encoded_string) do
    Map.merge(encoded_grapheme, %{grapheme => encoded_string})
  end

  defp convert(graphemes, dictionary) do
    Enum.reduce(graphemes, "", fn grapheme, converted_text ->
      converted_text <> dictionary[grapheme]
    end)
  end
end
