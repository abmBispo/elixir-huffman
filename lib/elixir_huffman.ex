defmodule ElixirHuffman do
  alias ElixirHuffman.{
    Node,
    Leaf
  }

  def lorem do
    """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus sollicitudin ipsum dignissim lacus rutrum, nec
    malesuada leo ultricies. Sed egestas, arcu vel vestibulum ultricies, purus felis consequat ipsum, nec tincidunt mi
    magna in nulla. Pellentesque eu purus sapien. Praesent vel venenatis nulla. Quisque et libero interdum, aliquam augue
    pulvinar, laoreet lacus. Phasellus at vulputate mi. Donec sagittis ipsum sed quam tristique aliquet. Phasellus feugiat
    malesuada nisl non vulputate. Praesent mollis odio eget turpis rhoncus, at blandit enim fringilla. Aenean ac eleifend
    est, non facilisis ex. Duis in dolor quis turpis consequat facilisis nec at dolor. Etiam eget justo eget sem convallis
    accumsan. Cras dignissim tellus neque, nec imperdiet magna aliquet ac. Aliquam semper eget purus et convallis.
    Etiam molestie vel nunc non fermentum. Sed maximus dolor vitae tortor cursus mollis. Morbi fringilla viverra malesuada.
    Proin finibus lacinia lorem, eget dictum leo eleifend sed. Praesent molestie euismod arcu, eu tristique libero venenatis
    vel. Vestibulum at libero in velit ullamcorper porta. Pellentesque sagittis scelerisque ante et ultrices. Quisque a tellus
    at augue facilisis convallis. Praesent semper, enim ac molestie faucibus, mauris nunc elementum felis, eget porta
    justo magna at metus. Integer non efficitur enim. Sed vel lacus facilisis quam consectetur lacinia in sit amet erat.
    Aliquam sed erat tempus, luctus metus at, pulvinar justo. Aliquam erat volutpat. Curabitur et orci sed nisl bibendum
    scelerisque ut vel odio. Phasellus consequat nunc ligula, et vehicula lectus euismod tristique.
    Pellentesque fermentum velit et libero suscipit congue. Aenean gravida blandit lorem, eget bibendum nibh ultrices a.
    Fusce odio neque, suscipit vel nibh non, auctor finibus diam. Sed aliquet enim neque, quis scelerisque metus rutrum sed.
    Fusce blandit tellus elit, non laoreet turpis semper ut. Cras vulputate purus in nisi faucibus ullamcorper. Aenean quis
    urna a risus elementum porttitor. Quisque vulputate scelerisque justo facilisis posuere. Orci varius natoque penatibus et
    magnis dis parturient montes, nascetur ridiculus mus.
    Curabitur tortor tortor, malesuada sit amet viverra ut, pulvinar at leo. Phasellus metus neque, vulputate congue finibus
    quis, vehicula ac neque. Aenean eget lectus mi. Nam sagittis laoreet ante, consectetur venenatis lacus egestas sit amet.
    Fusce sit amet malesuada nibh. Nunc odio magna, efficitur eget auctor vel, aliquam eu nisi. Aenean nisi odio, fermentum
    id ligula eget, venenatis varius ante. Nullam non turpis lectus. Suspendisse eu odio placerat, congue nisl sollicitudin,
    cursus tellus. Curabitur vel nisi est. Fusce faucibus ipsum at nibh pulvinar rutrum. Aenean non fermentum ligula. Integer
    ultrices feugiat leo.
    Quisque ac condimentum dui, et congue urna. Phasellus lacus ipsum, pharetra ut leo in, placerat tristique tortor. Donec
    nec nisl aliquam, tempus nisl sit amet, sodales lectus. Orci varius natoque penatibus et magnis dis parturient montes,
    nascetur ridiculus mus. Donec eleifend eros nunc, eget gravida nisi aliquam id. In hac habitasse platea dictumst. Nam a
    sodales urna, non gravida risus.
    """
  end

  def encode(text \\ "cheesecake") do
    graphemes = String.graphemes(text)

    frequencies =
      graphemes
      |> Enum.reduce(%{}, fn char, map ->
        Map.update(map, char, 1, fn val -> val + 1 end)
      end)

    queue =
      frequencies
      |> Enum.sort_by(fn {_, freq} -> freq end)
      |> Enum.map(fn {value, freq} -> {%Leaf{value: value}, freq} end)

    huffman_tree = build_tree(queue)
    dictionary = huffman_dictionary(huffman_tree)
    {convert(graphemes, dictionary), huffman_tree}
  end

  defp build_tree([{root, _freq}]),
    do: root

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

  defp huffman_dictionary(huffman_tree),
    do: huffman_dictionary(huffman_tree, %{}, <<>>)

  defp huffman_dictionary(%Leaf{value: grapheme}, encoded_grapheme, encoded),
    do: Map.merge(encoded_grapheme, %{grapheme => encoded})

  defp huffman_dictionary(%Node{left: left, right: right}, graphemes_dictionary, encoded) do
    left_branch =
      huffman_dictionary(left, graphemes_dictionary, <<encoded::bitstring, 0::size(1)>>)

    right_branch =
      huffman_dictionary(right, graphemes_dictionary, <<encoded::bitstring, 1::size(1)>>)

    Map.merge(left_branch, right_branch)
  end

  defp convert(graphemes, dictionary) do
    Enum.reduce(graphemes, <<>>, fn grapheme, converted_text ->
      <<converted_text::bitstring, dictionary[grapheme]::bitstring>>
    end)
  end

  def decode(encoded, huffman_tree),
    do: read_tree(encoded, huffman_tree, huffman_tree, "")

  defp read_tree(<<0::size(1), rest::bitstring>>, root, %Node{left: left}, decoded),
    do: read_tree(rest, root, left, decoded)

  defp read_tree(<<1::size(1), rest::bitstring>>, root, %Node{right: right}, decoded),
    do: read_tree(rest, root, right, decoded)

  defp read_tree(encoded, root, %Leaf{value: value}, decoded),
    do: read_tree(encoded, root, root, decoded <> value)

  defp read_tree(<<>>, _, _, decoded),
    do: decoded
end
