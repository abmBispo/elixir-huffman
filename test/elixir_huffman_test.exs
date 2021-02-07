defmodule ElixirHuffmanTest do
  use ExUnit.Case

  test "Encode/Decode lorem" do
    lorem = ElixirHuffman.lorem()
    {compressed_lorem, tree} = ElixirHuffman.encode(lorem)
    decoded_lorem = ElixirHuffman.decode(compressed_lorem, tree)

    assert lorem == decoded_lorem
  end
end
